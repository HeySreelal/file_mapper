import 'dart:async';
import 'dart:io';

class TreePrinter {
  final List<String> ignorePatterns;
  final bool showSizes;

  TreePrinter({required this.ignorePatterns, this.showSizes = false});

  Future<void> printDirectoryTree(
    Directory directory, {
    String prefix = '',
  }) async {
    // List to store entries, sorted to ensure consistent output
    List<FileSystemEntity> entries;

    try {
      entries = await directory.list().toList();

      // Sort entries to make output more readable
      entries.sort((a, b) => a.path.compareTo(b.path));
    } catch (e) {
      print('Error accessing directory: $e');
      return;
    }

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isLast = i == entries.length - 1;

      // Determine the appropriate connector
      final connector = isLast ? '└── ' : '├── ';

      // Skip entries matching ignore patterns
      if (shouldSkipEntry(entry)) continue;

      // Get the relative path from the current directory
      final relativePath = entry.path.replaceFirst(
        directory.path + Platform.pathSeparator,
        '',
      );

      // Calculate size if required
      String sizeInfo = '';
      if (showSizes) {
        sizeInfo = await _getSizeInfo(entry);
      }

      // Print the current entry
      print('$prefix$connector$relativePath$sizeInfo');

      // Recursively process directories
      if (entry is Directory) {
        await printDirectoryTree(
          entry,
          prefix: prefix + (isLast ? '    ' : '│   '),
        );
      }
    }
  }

  bool shouldSkipEntry(FileSystemEntity entry) {
    final fileName = entry.path.split(Platform.pathSeparator).last;

    return ignorePatterns.any((pattern) => fileName.contains(pattern)) ||
        fileName.startsWith('.');
  }

  Future<String> _getSizeInfo(FileSystemEntity entity) async {
    try {
      if (entity is File) {
        final size = await entity.length();
        return ' (${_formatSize(size)})';
      } else if (entity is Directory) {
        final size = await _calculateDirectorySize(entity);
        return ' (${_formatSize(size)})';
      }
    } catch (e) {
      // Silently handle errors when calculating size
      return ' (unknown size)';
    }
    return '';
  }

  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;

    try {
      final completer = Completer<int>();
      final lister = directory.list(recursive: true);

      final subscription = lister.listen(
        (entity) async {
          if (entity is File) {
            try {
              totalSize += await entity.length();
            } catch (_) {
              // Ignore errors for individual files
            }
          }
        },
        onDone: () => completer.complete(totalSize),
        onError: (e) => completer.complete(totalSize),
        cancelOnError: false,
      );

      // Set a timeout of 2 seconds to avoid hanging on large directories
      return await completer.future.timeout(
        Duration(seconds: 2),
        onTimeout: () {
          subscription.cancel();
          return totalSize;
        },
      );
    } catch (_) {
      return totalSize;
    }
  }

  String _formatSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];

    if (bytes == 0) return '0 B';

    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}

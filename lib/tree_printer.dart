import 'dart:async';
import 'dart:io';

import 'cli_parser.dart';
import 'console_colors.dart';

/// Represents a file or directory node in the file system tree.
///
/// Contains information about the file or directory including its name,
/// path, size, and any child nodes (for directories).
class FileNode {
  /// The name of the file or directory.
  final String name;

  /// The full path to the file or directory.
  final String path;

  /// Whether this node represents a directory.
  final bool isDirectory;

  /// Child nodes if this is a directory.
  final List<FileNode> children;

  /// Size of the file in bytes, or total size of all files in a directory.
  int size;

  /// Creates a new [FileNode] instance.
  ///
  /// [name] The name of the file or directory.
  /// [path] The full path to the file or directory.
  /// [isDirectory] Whether this node represents a directory.
  /// [size] Size of the file in bytes (default: 0).
  /// [children] Child nodes if this is a directory (default: empty list).
  FileNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,
    List<FileNode>? children,
  }) : children = children ?? [];

  @override
  String toString() => '$name (${isDirectory ? 'dir' : 'file'}, $size bytes)';
}

/// Prints a directory tree structure to the console with formatting.
///
/// This class builds a representation of files and directories in a tree
/// format, with options for sorting, filtering, and displaying file sizes.
class TreePrinter {
  /// Patterns to ignore when processing files and directories.
  final List<String> ignorePatterns;

  /// Whether to show file and directory sizes.
  final bool showSizes;

  /// Criteria to use for sorting files and directories.
  final SortBy sortBy;

  /// Direction to sort files and directories.
  final SortDirection sortDirection;

  /// Maximum directory depth to display (null means unlimited).
  final int? maxLevel;

  /// Whether to suppress error messages.
  final bool suppressErrors;

  /// Creates a new [TreePrinter] with the specified options.
  ///
  /// [ignorePatterns] Patterns to ignore when processing files and directories.
  /// [showSizes] Whether to show file and directory sizes (default: false).
  /// [sortBy] Criteria to use for sorting files and directories (default: name).
  /// [sortDirection] Direction to sort files and directories (default: ascending).
  /// [maxLevel] Maximum directory depth to display (default: null, which means unlimited).
  /// [suppressErrors] Whether to suppress error messages (default: false).
  TreePrinter({
    required this.ignorePatterns,
    this.showSizes = false,
    this.sortBy = SortBy.name,
    this.sortDirection = SortDirection.ascending,
    this.suppressErrors = false,
    this.maxLevel,
  });

  /// Prints the directory tree starting from the specified directory.
  ///
  /// Builds a tree representation of the directory structure and prints it
  /// to the console, followed by summary information.
  ///
  /// [directory] The directory to start from.
  /// [prefix] Prefix string to use for indentation (default: empty string).
  Future<void> printDirectoryTree(
    Directory directory, {
    String prefix = '',
  }) async {
    try {
      final rootNode = await _buildFileTree(directory, currentLevel: 0);

      _sortNodes(rootNode.children);

      final totalFiles = _countFiles(rootNode);
      final totalDirs = _countDirs(rootNode);
      final totalSize = rootNode.size;

      _printTree(rootNode, prefix: '');

      print('\n${ConsoleColors.bold}Summary:${ConsoleColors.reset}');
      print(
        '${ConsoleColors.info('Total files:')} ${ConsoleColors.success(totalFiles.toString())}',
      );
      print(
        '${ConsoleColors.info('Total directories:')} ${ConsoleColors.success(totalDirs.toString())}',
      );
      if (showSizes) {
        print(
          '${ConsoleColors.info('Total size:')} ${ConsoleColors.success(_formatSize(totalSize))}',
        );
      }
    } catch (e) {
      if (!suppressErrors) {
        print(ConsoleColors.error('Error processing directory tree: $e'));
      }
    }
  }

  /// Determines if a file system entry should be skipped based on ignore patterns.
  ///
  /// [entry] The file system entry to check.
  /// Returns true if the entry should be skipped, false otherwise.
  bool shouldSkipEntry(FileSystemEntity entry) {
    final fileName = entry.path.split(Platform.pathSeparator).last;

    return ignorePatterns.any((pattern) => fileName.contains(pattern)) ||
        fileName.startsWith('.');
  }

  /// Log error message if error suppression is disabled
  ///
  /// [message] The error message to log
  void _logError(String message) {
    if (!suppressErrors) {
      print(ConsoleColors.error(message));
    }
  }

  /// Checks if an error should cause us to skip directory traversal
  ///
  /// [error] The exception that occurred
  /// Returns true if we should skip traversal
  bool _shouldSkipTraversal(Object error) {
    if (error is PathAccessException && error.osError != null) {
      // Permission errors (e.g., "Operation not permitted")
      return error.osError!.errorCode == 1 ||
          error.osError!.errorCode == 13; // EACCES
    } else if (error is FileSystemException && error.osError != null) {
      // Filename too long or other filesystem errors
      return error.osError!.errorCode == 63 || // ENAMETOOLONG
          error.osError!.errorCode == 36 || // ENAMETOOLONG on some systems
          error.osError!.errorCode == 2; // ENOENT
    } else if (error is PathNotFoundException && error.osError != null) {
      final codes = [2, 63];
      return codes.contains(error.osError!.errorCode);
    }
    return false;
  }

  int _countFiles(FileNode node) {
    int count = 0;
    for (final child in node.children) {
      if (!child.isDirectory) {
        count++;
      } else {
        count += _countFiles(child);
      }
    }
    return count;
  }

  int _countDirs(FileNode node) {
    int count = 0;
    for (final child in node.children) {
      if (child.isDirectory) {
        count++;
        count += _countDirs(child);
      }
    }
    return count;
  }

  Future<FileNode> _buildFileTree(
    Directory directory, {
    required int currentLevel,
  }) async {
    final dirName = directory.path.split(Platform.pathSeparator).last;

    final rootNode = FileNode(
      name: dirName.isEmpty ? directory.path : dirName,
      path: directory.path,
      isDirectory: true,
    );

    if (maxLevel != null && currentLevel >= maxLevel!) {
      return rootNode;
    }

    try {
      final List<FileSystemEntity> entries = [];

      try {
        entries.addAll(await directory.list().toList());
      } catch (e) {
        if (_shouldSkipTraversal(e)) {
          return rootNode;
        } else {
          // For other errors, propagate them
          rethrow;
        }
      }

      final List<FileNode> children = [];
      for (final entry in entries) {
        if (shouldSkipEntry(entry)) continue;

        final fileName = entry.path.split(Platform.pathSeparator).last;

        if (entry is File) {
          try {
            final size = await entry.length();
            children.add(
              FileNode(
                name: fileName,
                path: entry.path,
                isDirectory: false,
                size: size,
              ),
            );
          } catch (e) {
            if (!suppressErrors) {
              _logError('Error getting size of file ${e.toString()}');
            }
            // Add the file with size 0 to maintain tree structure
            children.add(
              FileNode(
                name: fileName,
                path: entry.path,
                isDirectory: false,
                size: -1, // We'll show as unknown.
              ),
            );
          }
        } else if (entry is Directory) {
          try {
            final dirNode = await _buildFileTree(
              entry,
              currentLevel: currentLevel + 1,
            );
            children.add(dirNode);
          } catch (e) {
            if (_shouldSkipTraversal(e)) {
              // Add directory with no children
              _logError('Skipped directory ${entry.path}: ${e.toString()}');
              children.add(
                FileNode(name: fileName, path: entry.path, isDirectory: true),
              );
            } else if (!suppressErrors) {
              // For other errors, log and continue if not suppressing
              _logError(
                'Error processing directory ${entry.path}: ${e.toString()}',
              );
              children.add(
                FileNode(name: fileName, path: entry.path, isDirectory: true),
              );
            }
          }
        }
      }

      for (final child in children.where((node) => node.isDirectory)) {
        _sortNodes(child.children);
      }

      rootNode.children.addAll(children);

      rootNode.size = rootNode.children.fold(0, (sum, node) => sum + node.size);

      return rootNode;
    } catch (e) {
      _logError('Error building file tree for $dirName: ${e.toString()}');
      return rootNode;
    }
  }

  void _sortNodes(List<FileNode> nodes) {
    if (nodes.isEmpty) return;

    int Function(FileNode, FileNode) compareFunction;

    switch (sortBy) {
      case SortBy.size:
        compareFunction = (a, b) {
          final sizeComparison = a.size.compareTo(b.size);
          return sizeComparison != 0
              ? sizeComparison
              : a.name.compareTo(b.name);
        };
        break;

      case SortBy.name:
        compareFunction = (a, b) => a.name.compareTo(b.name);
        break;
    }

    if (sortDirection == SortDirection.descending) {
      nodes.sort((a, b) => compareFunction(b, a));
    } else {
      nodes.sort(compareFunction);
    }

    for (final node in nodes.where((node) => node.isDirectory)) {
      _sortNodes(node.children);
    }
  }

  void _printTree(FileNode node, {String prefix = ''}) {
    if (node.children.isEmpty) return;

    for (int i = 0; i < node.children.length; i++) {
      final child = node.children[i];
      final isLast = i == node.children.length - 1;
      final connector = isLast ? '└── ' : '├── ';

      String sizeInfo = '';
      if (showSizes) {
        sizeInfo = ' ${ConsoleColors.size(_formatSize(child.size))}';
      }

      if (child.isDirectory) {
        final dirName = '${child.name}/';
        print('$prefix$connector${ConsoleColors.directory(dirName)}$sizeInfo');

        _printTree(child, prefix: prefix + (isLast ? '    ' : '│   '));
      } else {
        print('$prefix$connector${ConsoleColors.file(child.name)}$sizeInfo');
      }
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

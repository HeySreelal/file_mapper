import 'dart:async';
import 'dart:io';

import 'cli_parser.dart';
import 'console_colors.dart'; // Import console colors

/// Node class to represent a file or directory in the tree
class FileNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;
  int size;

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

class TreePrinter {
  final List<String> ignorePatterns;
  final bool showSizes;
  final SortBy sortBy;
  final SortDirection sortDirection;
  final int? maxLevel;

  TreePrinter({
    required this.ignorePatterns,
    this.showSizes = false,
    this.sortBy = SortBy.name,
    this.sortDirection = SortDirection.ascending,
    this.maxLevel,
  });

  Future<void> printDirectoryTree(
    Directory directory, {
    String prefix = '',
  }) async {
    try {
      // Build a complete representation of the file tree with depth control
      final rootNode = await _buildFileTree(directory, currentLevel: 0);

      // Sort the root level children based on criteria
      _sortNodes(rootNode.children);

      // Print summary information
      final totalFiles = _countFiles(rootNode);
      final totalDirs = _countDirs(rootNode);
      final totalSize = rootNode.size;

      _printTree(rootNode, prefix: '');

      // Print summary footer
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
      print(ConsoleColors.error('Error processing directory tree: $e'));
    }
  }

  /// Count total number of files
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

  /// Count total number of directories
  int _countDirs(FileNode node) {
    int count = 0;
    for (final child in node.children) {
      if (child.isDirectory) {
        count++; // Count this directory
        count += _countDirs(child); // Count subdirectories
      }
    }
    return count;
  }

  /// Builds a complete file tree with calculated sizes, respecting maxLevel
  Future<FileNode> _buildFileTree(
    Directory directory, {
    required int currentLevel,
  }) async {
    final dirName = directory.path.split(Platform.pathSeparator).last;

    // Create the root node
    final rootNode = FileNode(
      name: dirName.isEmpty ? directory.path : dirName,
      path: directory.path,
      isDirectory: true,
    );

    // If we've reached the maximum depth and it's not unlimited, don't process children
    if (maxLevel != null && currentLevel >= maxLevel!) {
      return rootNode;
    }

    try {
      // Get all entries in the directory
      final entries = await directory.list().toList();

      // Process each entry
      final List<FileNode> children = [];
      for (final entry in entries) {
        // Skip entries matching ignore patterns
        if (shouldSkipEntry(entry)) continue;

        final fileName = entry.path.split(Platform.pathSeparator).last;

        if (entry is File) {
          // Process file
          final size = await entry.length();
          children.add(
            FileNode(
              name: fileName,
              path: entry.path,
              isDirectory: false,
              size: size,
            ),
          );
        } else if (entry is Directory) {
          // Process directory recursively with incremented level
          final dirNode = await _buildFileTree(
            entry,
            currentLevel: currentLevel + 1,
          );
          children.add(dirNode);
        }
      }

      // Sort children within each subdirectory
      for (final child in children.where((node) => node.isDirectory)) {
        _sortNodes(child.children);
      }

      // Add all children to root node
      rootNode.children.addAll(children);

      // Calculate total size for the directory
      rootNode.size = rootNode.children.fold(0, (sum, node) => sum + node.size);

      return rootNode;
    } catch (e) {
      print(ConsoleColors.error('Error building file tree for $dirName: $e'));
      return rootNode;
    }
  }

  /// Sort nodes based on specified criteria and direction
  void _sortNodes(List<FileNode> nodes) {
    if (nodes.isEmpty) return;

    // Compare function based on sort criteria
    int Function(FileNode, FileNode) compareFunction;

    switch (sortBy) {
      case SortBy.size:
        compareFunction = (a, b) {
          final sizeComparison = a.size.compareTo(b.size);
          // For same size, fall back to name comparison
          return sizeComparison != 0
              ? sizeComparison
              : a.name.compareTo(b.name);
        };
        break;

      case SortBy.name:
        compareFunction = (a, b) => a.name.compareTo(b.name);
        break;
    }

    // Apply sort direction
    if (sortDirection == SortDirection.descending) {
      nodes.sort(
        (a, b) => compareFunction(b, a),
      ); // Reverse the comparison for descending
    } else {
      nodes.sort(compareFunction);
    }

    // Recursively sort children of directories
    for (final node in nodes.where((node) => node.isDirectory)) {
      _sortNodes(node.children);
    }
  }

  /// Prints the tree starting from the given node
  void _printTree(FileNode node, {String prefix = ''}) {
    if (node.children.isEmpty) return;

    for (int i = 0; i < node.children.length; i++) {
      final child = node.children[i];
      final isLast = i == node.children.length - 1;
      final connector = isLast ? '└── ' : '├── ';

      // Calculate size info if needed
      String sizeInfo = '';
      if (showSizes) {
        sizeInfo = ' ${ConsoleColors.size(_formatSize(child.size))}';
      }

      // Print the current entry
      if (child.isDirectory) {
        // Directory with trailing slash
        final dirName = '${child.name}/';
        print('$prefix$connector${ConsoleColors.directory(dirName)}$sizeInfo');

        // Recursively process directory
        _printTree(child, prefix: prefix + (isLast ? '    ' : '│   '));
      } else {
        // Regular file
        print('$prefix$connector${ConsoleColors.file(child.name)}$sizeInfo');
      }
    }
  }

  bool shouldSkipEntry(FileSystemEntity entry) {
    final fileName = entry.path.split(Platform.pathSeparator).last;

    return ignorePatterns.any((pattern) => fileName.contains(pattern)) ||
        fileName.startsWith('.');
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

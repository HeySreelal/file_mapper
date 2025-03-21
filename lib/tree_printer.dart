import 'dart:async';
import 'dart:io';

import 'cli_parser.dart';

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

  TreePrinter({
    required this.ignorePatterns,
    this.showSizes = false,
    this.sortBy = SortBy.name,
    this.sortDirection = SortDirection.ascending,
  });

  Future<void> printDirectoryTree(
    Directory directory, {
    String prefix = '',
  }) async {
    try {
      // Build a complete representation of the file tree
      final rootNode = await _buildFileTree(directory);

      // Sort the root level children based on criteria
      _sortNodes(rootNode.children);
      _printTree(rootNode, prefix: '');
    } catch (e) {
      print('Error processing directory tree: $e');
    }
  }

  /// Builds a complete file tree with calculated sizes
  Future<FileNode> _buildFileTree(Directory directory) async {
    final dirName = directory.path.split(Platform.pathSeparator).last;

    // Create the root node
    final rootNode = FileNode(
      name: dirName.isEmpty ? directory.path : dirName,
      path: directory.path,
      isDirectory: true,
    );

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
          // Process directory recursively
          final dirNode = await _buildFileTree(entry);
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
      print('Error building file tree for $dirName: $e');
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
        sizeInfo = ' (${_formatSize(child.size)})';
      }

      // Print the current entry
      print('$prefix$connector${child.name}$sizeInfo');

      // Recursively process directories
      if (child.isDirectory) {
        _printTree(child, prefix: prefix + (isLast ? '    ' : '│   '));
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

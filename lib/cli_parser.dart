import 'dart:io';
import 'package:args/args.dart';

// Enum for sort criteria
enum SortBy { name, size }

// Enum for sort direction
enum SortDirection { ascending, descending }

class CliOptions {
  final bool showSizes;
  final bool showHelp;
  final List<String> ignorePatterns;
  final SortBy sortBy;
  final SortDirection sortDirection;

  CliOptions({
    required this.showSizes,
    required this.showHelp,
    required this.ignorePatterns,
    required this.sortBy,
    required this.sortDirection,
  });
}

class CliParser {
  /// Parses command line arguments and returns structured options
  static CliOptions parse(List<String> args) {
    final parser =
        ArgParser()
          ..addFlag(
            'size',
            abbr: 's',
            help: 'Show file and directory sizes',
            negatable: false,
            defaultsTo: false,
          )
          ..addFlag(
            'help',
            abbr: 'h',
            help: 'Show help information',
            negatable: false,
            defaultsTo: false,
          )
          ..addMultiOption(
            'ignore',
            abbr: 'i',
            help: 'Patterns to ignore (can be used multiple times)',
            defaultsTo: <String>[],
          )
          ..addOption(
            'sort-by',
            help: 'Sort entries by (name, size)',
            defaultsTo: 'name',
            allowed: ['name', 'size'],
            allowedHelp: {
              'name': 'Sort entries by name',
              'size': 'Sort entries by size (requires --size flag)',
            },
          )
          ..addOption(
            'sort-direction',
            help: 'Sort direction (asc, desc)',
            defaultsTo: 'asc',
            allowed: ['asc', 'desc'],
            allowedHelp: {
              'asc': 'Sort in ascending order',
              'desc': 'Sort in descending order',
            },
          );

    try {
      final results = parser.parse(args);

      // Parse sort by
      SortBy sortBy;
      switch (results['sort-by'] as String) {
        case 'size':
          sortBy = SortBy.size;
          break;
        case 'name':
        default:
          sortBy = SortBy.name;
          break;
      }

      // Parse sort direction
      SortDirection sortDirection;
      switch (results['sort-direction'] as String) {
        case 'desc':
          sortDirection = SortDirection.descending;
          break;
        case 'asc':
        default:
          sortDirection = SortDirection.ascending;
          break;
      }

      return CliOptions(
        showSizes: results['size'] as bool,
        showHelp: results['help'] as bool,
        ignorePatterns: results['ignore'] as List<String>,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
    } catch (e) {
      // In case of invalid arguments, show help and exit
      _printUsage(parser);
      exit(1);
    }
  }

  /// Prints usage information
  static void printHelp() {
    final parser =
        ArgParser()
          ..addFlag(
            'size',
            abbr: 's',
            help: 'Show file and directory sizes',
            negatable: false,
          )
          ..addFlag(
            'help',
            abbr: 'h',
            help: 'Show help information',
            negatable: false,
          )
          ..addMultiOption(
            'ignore',
            abbr: 'i',
            help: 'Patterns to ignore (can be used multiple times)',
          )
          ..addOption(
            'sort-by',
            help: 'Sort entries by (name, size)',
            allowed: ['name', 'size'],
            allowedHelp: {
              'name': 'Sort entries by name',
              'size': 'Sort entries by size (requires --size flag)',
            },
          )
          ..addOption(
            'sort-direction',
            help: 'Sort direction (asc, desc)',
            allowed: ['asc', 'desc'],
            allowedHelp: {
              'asc': 'Sort in ascending order',
              'desc': 'Sort in descending order',
            },
          );

    _printUsage(parser);
  }

  static void _printUsage(ArgParser parser) {
    print('Usage: file_mapper [options]');
    print('');
    print('Options:');
    print(parser.usage);
  }
}

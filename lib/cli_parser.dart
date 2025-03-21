import 'dart:io';
import 'package:args/args.dart';
import 'console_colors.dart';

/// Defines sorting criteria options for directory entries
enum SortBy {
  /// Sort entries by name
  name,

  /// Sort entries by size
  size,
}

/// Defines sorting direction options
enum SortDirection {
  /// Sort in ascending order (A-Z, smallest to largest)
  ascending,

  /// Sort in descending order (Z-A, largest to smallest)
  descending,
}

/// Holds the parsed command-line options for the application
class CliOptions {
  /// Whether to display file and directory sizes
  final bool showSizes;

  /// Whether to display help information
  final bool showHelp;

  /// List of patterns to ignore when traversing directories
  final List<String> ignorePatterns;

  /// The criteria to sort directory entries by
  final SortBy sortBy;

  /// The direction to sort directory entries
  final SortDirection sortDirection;

  /// Maximum directory depth to traverse (null for unlimited)
  final int? maxLevel;

  /// Whether to suppress error messages
  final bool suppressErrors;

  /// Creates a new [CliOptions] instance with the specified parameters
  CliOptions({
    required this.showSizes,
    required this.showHelp,
    required this.ignorePatterns,
    required this.sortBy,
    required this.sortDirection,
    required this.suppressErrors,
    this.maxLevel,
  });
}

/// Parses and manages command-line arguments for the file mapper application
class CliParser {
  /// Parses command line arguments and returns structured options
  ///
  /// Takes a list of command-line [args] and transforms them into a structured
  /// [CliOptions] object. Handles validation and defaults for all options.
  ///
  /// If invalid arguments are provided, displays an error message and exits.
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
          ..addFlag(
            'quiet',
            abbr: 'q',
            help: 'Suppress error messages',
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
          )
          ..addOption(
            'level',
            abbr: 'l',
            help: 'Maximum directory depth to display',
            valueHelp: 'n',
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

      // Parse max level
      int? maxLevel;
      final levelOption = results['level'];
      if (levelOption != null) {
        try {
          maxLevel = int.parse(levelOption as String);
          if (maxLevel < 0) {
            print(
              ConsoleColors.warning(
                'Warning: Level must be non-negative. Using unlimited depth.',
              ),
            );
            maxLevel = null;
          }
        } catch (e) {
          print(
            ConsoleColors.warning(
              'Warning: Invalid level value. Using unlimited depth.',
            ),
          );
        }
      }

      return CliOptions(
        showSizes: results['size'] as bool,
        showHelp: results['help'] as bool,
        ignorePatterns: results['ignore'] as List<String>,
        sortBy: sortBy,
        sortDirection: sortDirection,
        suppressErrors: results['quiet'] as bool,
        maxLevel: maxLevel,
      );
    } catch (e) {
      // In case of invalid arguments, show help and exit
      print(ConsoleColors.error('Error: Invalid arguments provided.'));
      _printUsage(parser);
      exit(1);
    }
  }

  /// Displays help and usage information for the application
  ///
  /// Prints a formatted help message showing all available options,
  /// their descriptions, and example commands.
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
          ..addFlag(
            'quiet',
            abbr: 'q',
            help: 'Suppress error messages',
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
          )
          ..addOption(
            'level',
            abbr: 'l',
            help: 'Maximum directory depth to display',
            valueHelp: 'n',
          );

    _printUsage(parser);
  }

  /// Prints the usage information using the provided parser
  ///
  /// Helper method to print formatted usage information including
  /// all available options, their descriptions, and usage examples.
  static void _printUsage(ArgParser parser) {
    print(
      '\n${ConsoleColors.bold}${ConsoleColors.green}File Mapper - Directory Visualization Tool${ConsoleColors.reset}\n',
    );
    print(
      '${ConsoleColors.bold}Usage:${ConsoleColors.reset} file_mapper [options]\n',
    );
    print('${ConsoleColors.bold}Options:${ConsoleColors.reset}');

    // Process each option for colorized output
    final options = parser.options.values.toList();
    for (final option in options) {
      // Format option name
      String optionText = '';
      if (option.abbr != null) {
        optionText +=
            '${ConsoleColors.cyan}-${option.abbr}${ConsoleColors.reset}, ';
      }
      optionText +=
          '${ConsoleColors.cyan}--${option.name}${ConsoleColors.reset}';

      // Add value help if present
      if (option.valueHelp != null) {
        optionText +=
            ' ${ConsoleColors.yellow}<${option.valueHelp}>${ConsoleColors.reset}';
      }

      // Add help text
      final helpText = option.help ?? '';
      print('  $optionText');
      print('      ${ConsoleColors.info(helpText)}');

      // Add allowed values if present
      if (option.allowed != null && option.allowed!.isNotEmpty) {
        print(
          '      ${ConsoleColors.italic}Allowed values:${ConsoleColors.reset}',
        );

        // Show allowed values with their help text if available
        final allowedHelp = option.allowedHelp;
        for (final value in option.allowed!) {
          final valueHelp =
              allowedHelp != null && allowedHelp.containsKey(value)
                  ? allowedHelp[value]
                  : null;

          if (valueHelp != null) {
            print(
              '        ${ConsoleColors.yellow}$value${ConsoleColors.reset}: ${ConsoleColors.info(valueHelp)}',
            );
          } else {
            print(
              '        ${ConsoleColors.yellow}$value${ConsoleColors.reset}',
            );
          }
        }
      }

      // Add a blank line between options for better readability
      print('');
    }

    // Add examples section
    print('${ConsoleColors.bold}Examples:${ConsoleColors.reset}');
    print(
      '  ${ConsoleColors.gray}# Show directory tree with file sizes${ConsoleColors.reset}',
    );
    print('  file_mapper --size\n');

    print(
      '  ${ConsoleColors.gray}# Show directory tree with max depth of 2${ConsoleColors.reset}',
    );
    print('  file_mapper --level 2\n');

    print(
      '  ${ConsoleColors.gray}# Ignore node_modules and .git directories${ConsoleColors.reset}',
    );
    print('  file_mapper --ignore node_modules --ignore .git\n');

    print(
      '  ${ConsoleColors.gray}# Suppress error messages${ConsoleColors.reset}',
    );
    print('  file_mapper --quiet\n');

    print(
      ConsoleColors.info(
        'For more information, visit: https://github.com/HeySreelal/file_mapper${ConsoleColors.reset}\n',
      ),
    );
  }
}

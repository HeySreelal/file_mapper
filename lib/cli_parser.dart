import 'dart:io';
import 'package:args/args.dart';

class CliOptions {
  final bool showSizes;
  final bool showHelp;
  final List<String> ignorePatterns;

  CliOptions({
    required this.showSizes,
    required this.showHelp,
    required this.ignorePatterns,
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
          );

    try {
      final results = parser.parse(args);

      return CliOptions(
        showSizes: results['size'] as bool,
        showHelp: results['help'] as bool,
        ignorePatterns: results['ignore'] as List<String>,
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

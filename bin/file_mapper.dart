import 'dart:io';
import 'package:file_mapper/file_mapper.dart';

void main(List<String> args) async {
  // Parse command line arguments
  final cliOptions = CliParser.parse(args);

  // Show help if requested
  if (cliOptions.showHelp) {
    CliParser.printHelp();
    exit(0);
  }

  // Load or create configuration
  final configManager = ConfigManager();
  final config = await configManager.loadConfig();

  // Combine ignore patterns from config and command line
  final ignorePatterns = [
    ...config.ignorePatterns,
    ...cliOptions.ignorePatterns,
  ];

  // Create tree printer with combined settings including maxLevel
  final treePrinter = TreePrinter(
    ignorePatterns: ignorePatterns,
    showSizes: cliOptions.showSizes,
    sortBy: cliOptions.sortBy,
    sortDirection: cliOptions.sortDirection,
    maxLevel: cliOptions.maxLevel,
  );

  // Print directory tree starting from current directory
  final rootDirectory = Directory.current;
  print('Directory: ${rootDirectory.path}\n');

  // If level parameter is specified, inform the user
  if (cliOptions.maxLevel != null) {
    print(
      'Displaying directory structure with maximum depth: ${cliOptions.maxLevel}.',
    );
    if (cliOptions.showSizes) {
      print(
        'Directory sizes might not be accurate as we count to the specified depth only..\n',
      );
    }
  }

  await treePrinter.printDirectoryTree(rootDirectory);
}

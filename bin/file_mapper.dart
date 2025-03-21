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

  // Create tree printer with combined settings
  final treePrinter = TreePrinter(
    ignorePatterns: ignorePatterns,
    showSizes: cliOptions.showSizes,
  );

  // Print directory tree starting from current directory
  final rootDirectory = Directory.current;
  print('Directory: ${rootDirectory.path}\n');
  await treePrinter.printDirectoryTree(rootDirectory);
}

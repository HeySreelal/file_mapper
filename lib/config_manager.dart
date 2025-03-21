import 'dart:convert';
import 'dart:io';

/// Configuration class for the file mapper tool.
///
/// Contains settings such as patterns to ignore when mapping files and directories.
class FileMapperConfig {
  /// List of glob patterns for files and directories to ignore.
  final List<String> ignorePatterns;

  /// Creates a new FileMapperConfig with the specified ignore patterns.
  ///
  /// [ignorePatterns] - List of glob patterns for files/directories to skip.
  FileMapperConfig({required this.ignorePatterns});

  /// Converts the configuration to a JSON-serializable map.
  ///
  /// Returns a map containing all configuration properties.
  Map<String, dynamic> toJson() => {'ignorePatterns': ignorePatterns};

  /// Creates a FileMapperConfig instance from a JSON map.
  ///
  /// [json] - The map containing configuration data.
  ///
  /// Returns a new FileMapperConfig initialized with values from the map.
  /// Falls back to default patterns if none are provided.
  factory FileMapperConfig.fromJson(Map<String, dynamic> json) {
    return FileMapperConfig(
      ignorePatterns:
          (json['ignorePatterns'] as List?)?.map((e) => e as String).toList() ??
          defaultIgnorePatterns,
    );
  }

  /// Creates a FileMapperConfig with default settings.
  ///
  /// Returns a new FileMapperConfig initialized with default ignore patterns.
  factory FileMapperConfig.defaultConfig() {
    return FileMapperConfig(ignorePatterns: defaultIgnorePatterns);
  }

  /// Default patterns to ignore when mapping files and directories.
  static const List<String> defaultIgnorePatterns = [
    '.git',
    '.idea',
    '.vscode',
    'node_modules',
    'build',
    'out',
    'dist',
    '.dart_tool',
    '.packages',
    '.pub-cache',
    '.flutter-plugins',
    '.flutter-plugins-dependencies',
  ];
}

/// Manages loading and saving of configuration for the file mapper tool.
class ConfigManager {
  /// Path to the configuration file.
  final String configFilePath;

  /// Creates a new ConfigManager.
  ///
  /// Initializes with the default configuration file path.
  ConfigManager() : configFilePath = _getConfigFilePath();

  /// Gets the default config file path in the user's home directory.
  static String _getConfigFilePath() {
    final home =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return '$home${Platform.pathSeparator}.file_mapper_config.json';
  }

  /// Loads the configuration from file.
  ///
  /// Creates a default configuration file if none exists.
  /// [notifyIfCreated] - Whether to print a message if a new config file was created.
  ///
  /// Returns a [FileMapperConfig] object containing the loaded or default configuration.
  Future<FileMapperConfig> loadConfig({bool notifyIfCreated = true}) async {
    final configFile = File(configFilePath);

    // If config doesn't exist, create it with defaults
    if (!await configFile.exists()) {
      final defaultConfig = FileMapperConfig.defaultConfig();
      await saveConfig(defaultConfig);

      if (notifyIfCreated) {
        print('Created default configuration file at: $configFilePath');
        print('You can edit this file to customize ignore patterns.');
      }

      return defaultConfig;
    }

    try {
      final jsonContent = await configFile.readAsString();
      final jsonMap = jsonDecode(jsonContent) as Map<String, dynamic>;
      return FileMapperConfig.fromJson(jsonMap);
    } catch (e) {
      print('Error reading config file: $e');
      print('Using default configuration instead.');
      return FileMapperConfig.defaultConfig();
    }
  }

  /// Saves the configuration to the config file.
  ///
  /// [config] - The configuration to save.
  Future<void> saveConfig(FileMapperConfig config) async {
    final configFile = File(configFilePath);
    final jsonContent = jsonEncode(config.toJson());

    await configFile.writeAsString(jsonContent, flush: true);
  }
}

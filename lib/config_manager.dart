import 'dart:io';
import 'dart:convert';

class FileMapperConfig {
  final List<String> ignorePatterns;

  FileMapperConfig({required this.ignorePatterns});

  Map<String, dynamic> toJson() => {'ignorePatterns': ignorePatterns};

  factory FileMapperConfig.fromJson(Map<String, dynamic> json) {
    return FileMapperConfig(
      ignorePatterns:
          (json['ignorePatterns'] as List?)?.map((e) => e as String).toList() ??
          defaultIgnorePatterns,
    );
  }

  factory FileMapperConfig.defaultConfig() {
    return FileMapperConfig(ignorePatterns: defaultIgnorePatterns);
  }

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

class ConfigManager {
  final String configFilePath;

  ConfigManager() : configFilePath = _getConfigFilePath();

  /// Gets the default config file path in the user's home directory
  static String _getConfigFilePath() {
    final home =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return '$home${Platform.pathSeparator}.file_mapper_config.json';
  }

  /// Loads the configuration from file, or creates default if not exists
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

  /// Saves the configuration to file
  Future<void> saveConfig(FileMapperConfig config) async {
    final configFile = File(configFilePath);
    final jsonContent = jsonEncode(config.toJson());

    await configFile.writeAsString(jsonContent, flush: true);
  }
}

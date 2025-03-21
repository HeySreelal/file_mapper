import 'package:file_mapper/cli_parser.dart';
import 'package:test/test.dart';

void main() {
  group('CliParser Tests', () {
    test('should parse empty arguments with default values', () {
      final options = CliParser.parse([]);

      expect(options.showSizes, false);
      expect(options.showHelp, false);
      expect(options.ignorePatterns, isEmpty);
      expect(options.sortBy, SortBy.name);
      expect(options.sortDirection, SortDirection.ascending);
      expect(options.maxLevel, isNull);
    });

    test('should parse size flag', () {
      final options = CliParser.parse(['--size']);

      expect(options.showSizes, true);
    });

    test('should parse help flag', () {
      final options = CliParser.parse(['--help']);

      expect(options.showHelp, true);
    });

    test('should parse abbreviated flags', () {
      final options = CliParser.parse(['-s', '-h']);

      expect(options.showSizes, true);
      expect(options.showHelp, true);
    });

    test('should parse ignore patterns', () {
      final options = CliParser.parse([
        '--ignore',
        'node_modules',
        '--ignore',
        '.git',
      ]);

      expect(options.ignorePatterns, ['node_modules', '.git']);
    });

    test('should parse abbreviated ignore patterns', () {
      final options = CliParser.parse(['-i', 'build', '-i', 'dist']);

      expect(options.ignorePatterns, ['build', 'dist']);
    });

    test('should parse sort-by option with name', () {
      final options = CliParser.parse(['--sort-by', 'name']);

      expect(options.sortBy, SortBy.name);
    });

    test('should parse sort-by option with size', () {
      final options = CliParser.parse(['--sort-by', 'size']);

      expect(options.sortBy, SortBy.size);
    });

    test('should parse sort-direction option with ascending', () {
      final options = CliParser.parse(['--sort-direction', 'asc']);

      expect(options.sortDirection, SortDirection.ascending);
    });

    test('should parse sort-direction option with descending', () {
      final options = CliParser.parse(['--sort-direction', 'desc']);

      expect(options.sortDirection, SortDirection.descending);
    });

    test('should parse level option', () {
      final options = CliParser.parse(['--level', '3']);

      expect(options.maxLevel, 3);
    });

    test('should parse abbreviated level option', () {
      final options = CliParser.parse(['-l', '2']);

      expect(options.maxLevel, 2);
    });

    test('should parse multiple options combined', () {
      final options = CliParser.parse([
        '--size',
        '--ignore',
        'node_modules',
        '--sort-by',
        'size',
        '--sort-direction',
        'desc',
        '--level',
        '3',
      ]);

      expect(options.showSizes, true);
      expect(options.ignorePatterns, ['node_modules']);
      expect(options.sortBy, SortBy.size);
      expect(options.sortDirection, SortDirection.descending);
      expect(options.maxLevel, 3);
    });
  });
}

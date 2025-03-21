import 'package:test/test.dart';
import 'package:file_mapper/console_colors.dart';

void main() {
  group('ConsoleColors Tests', () {
    test('colorize should wrap text with color code and reset', () {
      final colored = ConsoleColors.colorize('test', ConsoleColors.red);
      expect(colored, equals('${ConsoleColors.red}test${ConsoleColors.reset}'));
    });

    test('directory should format with bold yellow', () {
      final text = ConsoleColors.directory('folder');
      expect(
        text,
        equals(
          '${ConsoleColors.bold}${ConsoleColors.yellow}folder${ConsoleColors.reset}',
        ),
      );
    });

    test('file should format with white', () {
      final text = ConsoleColors.file('sample.txt');
      expect(
        text,
        equals('${ConsoleColors.white}sample.txt${ConsoleColors.reset}'),
      );
    });

    test('size should format with gray', () {
      final text = ConsoleColors.size('1.5 MB');
      expect(text, equals('${ConsoleColors.gray}1.5 MB${ConsoleColors.reset}'));
    });

    test('info should format with gray', () {
      final text = ConsoleColors.info('Information');
      expect(
        text,
        equals('${ConsoleColors.gray}Information${ConsoleColors.reset}'),
      );
    });

    test('error should format with red', () {
      final text = ConsoleColors.error('Error message');
      expect(
        text,
        equals('${ConsoleColors.red}Error message${ConsoleColors.reset}'),
      );
    });

    test('success should format with green', () {
      final text = ConsoleColors.success('Success message');
      expect(
        text,
        equals('${ConsoleColors.green}Success message${ConsoleColors.reset}'),
      );
    });

    test('warning should format with yellow', () {
      final text = ConsoleColors.warning('Warning message');
      expect(
        text,
        equals('${ConsoleColors.yellow}Warning message${ConsoleColors.reset}'),
      );
    });
  });
}

/// Class to handle colored console output using ANSI escape codes
class ConsoleColors {
  // Foreground colors
  static const String reset = '\x1B[0m';
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String gray = '\x1B[90m';

  // Text styles
  static const String bold = '\x1B[1m';
  static const String italic = '\x1B[3m';
  static const String underline = '\x1B[4m';

  /// Wraps text with a color and resets after
  static String colorize(String text, String color) {
    return '$color$text$reset';
  }

  /// Specific coloring functions for file types
  static String directory(String text) {
    return colorize(text, bold + yellow);
  }

  static String file(String text) {
    return colorize(text, white);
  }

  static String size(String text) {
    return colorize(text, gray);
  }

  static String info(String text) {
    return colorize(text, gray);
  }

  static String error(String text) {
    return colorize(text, red);
  }

  static String success(String text) {
    return colorize(text, green);
  }

  static String warning(String text) {
    return colorize(text, yellow);
  }
}

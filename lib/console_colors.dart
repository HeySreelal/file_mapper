/// Utility class for colored console output using ANSI escape codes
class ConsoleColors {
  /// ANSI escape code to reset all colors and styles
  static const String reset = '\x1B[0m';

  /// ANSI escape code for black foreground text
  static const String black = '\x1B[30m';

  /// ANSI escape code for red foreground text
  static const String red = '\x1B[31m';

  /// ANSI escape code for green foreground text
  static const String green = '\x1B[32m';

  /// ANSI escape code for yellow foreground text
  static const String yellow = '\x1B[33m';

  /// ANSI escape code for blue foreground text
  static const String blue = '\x1B[34m';

  /// ANSI escape code for magenta foreground text
  static const String magenta = '\x1B[35m';

  /// ANSI escape code for cyan foreground text
  static const String cyan = '\x1B[36m';

  /// ANSI escape code for white foreground text
  static const String white = '\x1B[37m';

  /// ANSI escape code for gray foreground text
  static const String gray = '\x1B[90m';

  /// ANSI escape code for bold text style
  static const String bold = '\x1B[1m';

  /// ANSI escape code for italic text style
  static const String italic = '\x1B[3m';

  /// ANSI escape code for underlined text style
  static const String underline = '\x1B[4m';

  /// Wraps text with a color code and resets style after the text
  ///
  /// [text] The text to colorize
  /// [color] The ANSI color code to apply
  ///
  /// Returns the colorized text string
  static String colorize(String text, String color) {
    return '$color$text$reset';
  }

  /// Formats text as a directory name with bold yellow styling
  ///
  /// [text] The directory name to format
  ///
  /// Returns the formatted directory name string
  static String directory(String text) {
    return colorize(text, bold + yellow);
  }

  /// Formats text as a file name with white styling
  ///
  /// [text] The file name to format
  ///
  /// Returns the formatted file name string
  static String file(String text) {
    return colorize(text, white);
  }

  /// Formats text as size information with gray styling
  ///
  /// [text] The size information to format
  ///
  /// Returns the formatted size string
  static String size(String text) {
    return colorize(text, gray);
  }

  /// Formats text as general information with gray styling
  ///
  /// [text] The information text to format
  ///
  /// Returns the formatted information string
  static String info(String text) {
    return colorize(text, gray);
  }

  /// Formats text as an error message with red styling
  ///
  /// [text] The error message to format
  ///
  /// Returns the formatted error string
  static String error(String text) {
    return colorize(text, red);
  }

  /// Formats text as a success message with green styling
  ///
  /// [text] The success message to format
  ///
  /// Returns the formatted success string
  static String success(String text) {
    return colorize(text, green);
  }

  /// Formats text as a warning message with yellow styling
  ///
  /// [text] The warning message to format
  ///
  /// Returns the formatted warning string
  static String warning(String text) {
    return colorize(text, yellow);
  }
}

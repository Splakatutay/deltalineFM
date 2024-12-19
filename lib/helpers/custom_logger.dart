
class CustomLogger {
  static final CustomLogger _instance = CustomLogger._internal();

  factory CustomLogger() {
    return _instance;
  }

  CustomLogger._internal();

  void log(String message, {String? tag}) {
    final now = DateTime.now();
    final formattedMessage = '$now ${tag ?? 'LOG'}: $message';
    print(formattedMessage);

    // Optional: Write logs to a file
//    _writeLogToFile(formattedMessage);
  }

  // void _writeLogToFile(String message) {
  //   final logFile = File('logs.txt');
  //   logFile.writeAsStringSync('$message\n', mode: FileMode.append, flush: true);
  // }

  void info(String message) => log(message, tag: 'INFO');
  void warning(String message) => log(message, tag: 'WARNING');
  void error(String message) => log(message, tag: 'ERROR');
}

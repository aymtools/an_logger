import 'dart:async';

import 'logger_convert.dart';

enum LogLevel {
  VERBOSE,
  DEBUG,
  INFO,
  WARN,
  ERROR,
  ASSERT,
}

extension LogLevelExt on LogLevel {
  operator >(LogLevel other) => this.index > other.index;

  operator >=(LogLevel other) => this.index >= other.index;

  operator <(LogLevel other) => this.index < other.index;

  operator <=(LogLevel other) => this.index <= other.index;
}

class LogEvent {
  final LogLevel level;
  final String tag;
  final String? msg;
  final dynamic err;
  final StackTrace? stackTrace;
  final DateTime time;
  final Zone zone;
  final Object? source;

  LogEvent(
    this.level,
    this.tag, {
    this.msg,
    this.err,
    this.stackTrace,
    Zone? zone,
    this.source,
  })  : this.zone = zone ?? Zone.current,
        this.time = DateTime.now();

  bool get isNotEmptyMessage =>
      msg != null || err != null || stackTrace != null;

  String get messages {
    String msgInfo = '';
    if (msg != null && msg!.isNotEmpty) {
      msgInfo += '$msg\n';
    }
    if (err != null) {
      msgInfo += '$err\n';
    }
    if (stackTrace != null) {
      msgInfo += '$stackTrace\n';
    }
    if (msgInfo.isNotEmpty) {
      msgInfo = msgInfo.substring(0, msgInfo.length - 1);
    }
    return msgInfo;
  }
}

abstract class LoggerPrinter {
  void printEvent(LogLevel level, String tag, LogEvent event);
}

class Logger {
  Logger._();

  static final Logger instance = Logger._();

  static Logger get logger => instance;

  static Logger get log => instance;

  final Map<Type, LoggerPrinter> _printers = {};

  LogLevel _logLevel = LogLevel.ERROR;

  set logLevel(LogLevel level) => _logLevel = level;

  void addPrinter(LoggerPrinter printer) =>
      _printers[printer.runtimeType] = printer;

  // void unregisterPrinter(LoggerPrinter printer) =>
  //     _printers.removeWhere((_, p) => p == printer);
  //
  // void unregisterPrinterForType<T>() => _printers.remove(T);

  void v({String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      _checkLevelAndPrint(LogLevel.VERBOSE,
          tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  void d({String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      _checkLevelAndPrint(LogLevel.DEBUG,
          tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  void i({String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      _checkLevelAndPrint(LogLevel.INFO,
          tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  void w({String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      _checkLevelAndPrint(LogLevel.WARN,
          tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  void e({String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      _checkLevelAndPrint(LogLevel.ERROR,
          tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  void wtf({String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      _checkLevelAndPrint(LogLevel.ASSERT,
          tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  void _checkLevelAndPrint(LogLevel level,
      {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) {
    if (level < _logLevel) return;
    if (_printers.isEmpty) return;
    tag ??= 'AnLogger';
    final event = LogEvent(level, tag,
        msg: msg is String ? msg : _convertMsg(msg),
        err: err,
        stackTrace: stackTrace,
        source: msg);
    if (event.isNotEmptyMessage) {
      _printMsg(level, tag, event);
    }
  }

  void _printMsg(LogLevel level, String tag, LogEvent event) {
    _printers.values.forEach((e) => e.printEvent(level, tag, event));
  }

  static String? _convertMsg(Object? msg) {
    if (msg == null) return null;
    if (msg is String) return msg;
    return LoggerConvert.instance.convert(msg);
  }
}

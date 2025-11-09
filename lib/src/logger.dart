import 'logger_convert.dart';

// ignore_for_file: constant_identifier_names
/// 日志等级
///
enum LogLevel {
  VERBOSE,
  DEBUG,
  INFO,
  WARN,
  ERROR,
  ASSERT,
}

extension LogLevelExt on LogLevel {
  bool operator >(LogLevel other) => index > other.index;

  bool operator >=(LogLevel other) => index >= other.index;

  bool operator <(LogLevel other) => index < other.index;

  bool operator <=(LogLevel other) => index <= other.index;
}

/// 一个日志事件
class LogEvent {
  /// 等级
  final LogLevel level;

  /// 标识
  final String tag;

  /// 消息
  final String? msg;

  /// 错误
  final dynamic err;

  /// 错误栈
  final StackTrace? stackTrace;

  ///  时间
  final DateTime time;

  /// 自定义源 一般不参与日志的输出
  final Object? source;

  LogEvent(
    this.level,
    this.tag, {
    this.msg,
    this.err,
    this.stackTrace,
    this.source,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  /// 是否是空消息
  bool get isNotEmptyMessage =>
      msg != null || err != null || stackTrace != null;

  ///  获取消息体内容
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

/// 自定义一个日志打印
abstract class LoggerPrinter {
  void printEvent(LogLevel level, String tag, LogEvent event);
}

/// 使用的对象
//不支持跨isolate使用
@pragma('vm:isolate-unsendable')
class Logger {
  Logger._();

  static Logger _instance = Logger._();

  /// instance
  static Logger get instance => _instance;

  /// logger
  static Logger get logger => _instance;

  /// log
  static Logger get log => _instance;

  final Map<Type, LoggerPrinter> _printers = {};

  LogLevel _logLevel = LogLevel.ERROR;

  ///  设置默认的拦截 level
  set logLevel(LogLevel level) => _logLevel = level;

  /// 添加一个自定义的日志打印器
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

  void print(LogLevel level,
          {String? tag,
          Object? msg,
          dynamic err,
          StackTrace? stackTrace,
          DateTime? time}) =>
      _checkLevelAndPrint(level,
          tag: tag, msg: msg, err: err, stackTrace: stackTrace, time: time);

  void _checkLevelAndPrint(LogLevel level,
      {String? tag,
      Object? msg,
      dynamic err,
      StackTrace? stackTrace,
      DateTime? time}) {
    if (level < _logLevel) return;
    if (_printers.isEmpty) return;
    tag ??= 'AnLogger';
    final event = LogEvent(level, tag,
        msg: msg is String ? msg : _convertMsg(msg),
        err: err,
        stackTrace: stackTrace,
        source: msg,
        time: time);
    if (event.isNotEmptyMessage) {
      _printMsg(level, tag, event);
    }
  }

  void _printMsg(LogLevel level, String tag, LogEvent event) {
    for (var e in _printers.values) {
      e.printEvent(level, tag, event);
    }
  }

  static String? _convertMsg(Object? msg) {
    if (msg == null) return null;
    if (msg is String) return msg;
    return LoggerConvert.instance.convert(msg);
  }
}

/// 定义通信token
abstract class IsolateLoggerToken {
  void backgroundPrint(LogLevel level, String tag, Object? msg, dynamic err,
      StackTrace? stackTrace, DateTime time);
}

//不支持跨isolate使用
@pragma('vm:isolate-unsendable')
class BackgroundIsolateLogger extends Logger {
  BackgroundIsolateLogger._() : super._();

  late void Function(LogLevel level, String tag, Object? msg, dynamic err,
      StackTrace? stackTrace, DateTime time) _backgroundPrint;

  static void init(IsolateLoggerToken token) {
    assert(
        Logger.instance.runtimeType == Logger, 'init can only be called once');
    BackgroundIsolateLogger logger = BackgroundIsolateLogger._();
    logger._backgroundPrint = token.backgroundPrint;
    Logger._instance = logger;
  }

  @override
  set logLevel(LogLevel level) {
    throw UnsupportedError('Background isolates do not support logLevel(). ');
  }

  @override
  void addPrinter(LoggerPrinter printer) {
    throw UnsupportedError('Background isolates do not support addPrinter(). ');
  }

  @override
  void _checkLevelAndPrint(LogLevel level,
      {String? tag,
      Object? msg,
      dynamic err,
      StackTrace? stackTrace,
      DateTime? time}) {
    _backgroundPrint(level, tag ?? 'BackgroundIsolateLogger', msg, err,
        stackTrace, time ?? DateTime.now());
  }
}

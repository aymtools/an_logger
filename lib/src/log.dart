import 'logger.dart';
import 'logger_convert.dart';

class Log {
  Log._();

  static set logLevel(LogLevel level) => Logger.logger.logLevel = level;

  static void registerPrinter(LoggerPrinter printer) =>
      Logger.logger.registerPrinter(printer);

  static void unregisterPrinter(LoggerPrinter printer) =>
      Logger.logger.unregisterPrinter(printer);

  static void unregisterPrinterForType<T>() =>
      Logger.logger.unregisterPrinterForType<T>();

  static void registerCustomConvert(LoggerConvertBase convert) =>
      LoggerConvert.instance.registerConvert(convert);

  static void unregisterCustomConvert(LoggerConvertBase convert) =>
      LoggerConvert.instance.unregisterConvert(convert);

  static void v(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger
          .v(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void d(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger
          .d(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void i(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger
          .i(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void w(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger
          .w(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void e(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger
          .e(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void wtf(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger.wtf(
          tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static String? _convertMsg(Object? msg) {
    if (msg == null) return null;
    if (msg is String) return msg;
    return LoggerConvert.instance.convert(msg);
  }
}

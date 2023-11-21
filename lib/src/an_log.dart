import 'an_logger.dart';
import 'an_logger_convert.dart';

class AnLog {
  AnLog._();

  static set logLevel(LogLevel level) => AnLogger.logger.logLevel = level;

  static void registerPrinter(AnLoggerPrinter printer) =>
      AnLogger.logger.registerPrinter(printer);

  static void unregisterPrinter(AnLoggerPrinter printer) =>
      AnLogger.logger.unregisterPrinter(printer);

  static void unregisterPrinterForType<T>() =>
      AnLogger.logger.unregisterPrinterForType<T>();

  static void registerCustomConvert(LogConvert convert) =>
      AnLogConvert.instance.registerConvert(convert);

  static void unregisterCustomConvert(LogConvert convert) =>
      AnLogConvert.instance.unregisterConvert(convert);

  static void v(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      AnLogger.logger
          .v(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void d(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      AnLogger.logger
          .d(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void i(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      AnLogger.logger
          .i(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void w(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      AnLogger.logger
          .w(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void e(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      AnLogger.logger
          .e(tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static void wtf(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      AnLogger.logger.wtf(
          tag: tag, msg: _convertMsg(msg), err: err, stackTrace: stackTrace);

  static String? _convertMsg(Object? msg) {
    if (msg == null) return null;
    if (msg is String) return msg;
    return AnLogConvert.instance.convert(msg);
  }
}

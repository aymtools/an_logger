import 'logger.dart';
import 'logger_convert.dart';

/// 日志
class Log {
  Log._();

  ///  设置默认的拦截 level
  static set logLevel(LogLevel level) => Logger.logger.logLevel = level;

  /// 添加一个自定义的日志打印器
  static void addPrinter(LoggerPrinter printer) =>
      Logger.logger.addPrinter(printer);

  /// 添加一个自定义的 对象转换器
  static void addCustomConvert(LoggerConvertBase convert) =>
      LoggerConvert.instance.addConvert(convert);

  /// v
  static void v(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger.v(tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  static void d(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger.d(tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  static void i(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger.i(tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  static void w(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger.w(tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  static void e(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger.e(tag: tag, msg: msg, err: err, stackTrace: stackTrace);

  static void wtf(
          {String? tag, Object? msg, dynamic err, StackTrace? stackTrace}) =>
      Logger.logger.wtf(tag: tag, msg: msg, err: err, stackTrace: stackTrace);
}

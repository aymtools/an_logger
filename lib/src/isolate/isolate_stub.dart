import 'package:an_logger/src/logger.dart';

/// 定义一个允许跨Isolate的日志转发 token
/// 仅在io 平台下才支持
class RootIsolateLoggerToken implements IsolateLoggerToken {
  RootIsolateLoggerToken._();

  static RootIsolateLoggerToken get instance => throw UnimplementedError();

  @override
  void backgroundPrint(LogLevel level, String tag, Object? msg, err,
      StackTrace? stackTrace, DateTime time) {}
}

extension BackgroundIsolateLoggerTokenExt on Logger {
  /// 获取 root的token 只可以在 root isolate中使用
  ///  仅在io 平台下才支持
  RootIsolateLoggerToken get rootIsolateToken => throw UnimplementedError();
}

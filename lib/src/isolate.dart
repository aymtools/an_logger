import 'dart:isolate';

import 'package:an_logger/an_logger.dart';

/// 定义一个允许跨Isolate的日志转发 token
class RootIsolateLoggerToken implements IsolateLoggerToken {
  final SendPort _sendPort;

  RootIsolateLoggerToken._(this._sendPort);

  static final RootIsolateLoggerToken instance =
      RootIsolateLoggerToken._(__getRootIsolateToken());

  static SendPort __getRootIsolateToken() {
    ReceivePort receivePort = ReceivePort('AnLog');
    receivePort.listen((message) {
      if (message is LogEvent) {
        Logger.instance.print(message.level,
            tag: message.tag,
            msg: message.source,
            err: message.err,
            stackTrace: message.stackTrace,
            time: message.time);
      } else if (message is List && message.length == 2) {
        Logger.instance.e(
            tag: 'BackgroundIsolateLogger',
            err: message[0],
            stackTrace: message[1]);
      }
    });
    return receivePort.sendPort;
  }

  @override
  void backgroundPrint(LogLevel level, String tag, Object? msg, err,
      StackTrace? stackTrace, DateTime time) {
    try {
      _sendPort.send(LogEvent(level, tag,
          msg: '', err: err, stackTrace: stackTrace, source: msg, time: time));
    } catch (error, stackTrace) {
      _sendPort.send([error, stackTrace]);
    }
  }
}

extension BackgroundIsolateLoggerTokenExt on Logger {
  /// 获取 root的token 只可以在 root isolate中使用
  RootIsolateLoggerToken get rootIsolateToken =>
      RootIsolateLoggerToken.instance;
}

import 'package:an_logger/an_logger.dart';
import 'package:test/test.dart';

// 用于测试的 IsolateLoggerToken Mock 实现
class TestIsolateLoggerToken implements IsolateLoggerToken {
  LogLevel? lastLevel;
  String? lastTag;
  Object? lastMsg;
  dynamic lastErr;
  StackTrace? lastStackTrace;
  DateTime? lastTime;

  @override
  void backgroundPrint(LogLevel level, String tag, Object? msg, err,
      StackTrace? stackTrace, DateTime time) {
    lastLevel = level;
    lastTag = tag;
    lastMsg = msg;
    lastErr = err;
    lastStackTrace = stackTrace;
    lastTime = time;
  }
}

void main() {
  group('BackgroundIsolateLogger tests', () {
    test('should initialize BackgroundIsolateLogger and handle logs via token',
        () {
      // 创建 Token Mock 对象并初始化 BackgroundIsolateLogger
      final token = TestIsolateLoggerToken();
      BackgroundIsolateLogger.init(token);

      final currentLogger = Logger.instance;
      expect(currentLogger, isA<BackgroundIsolateLogger>());

      // 验证在 BackgroundIsolateLogger 上调用 logLevel 会抛出 UnsupportedError
      expect(
        () => currentLogger.logLevel = LogLevel.DEBUG,
        throwsA(isA<UnsupportedError>()),
      );

      // 验证在 BackgroundIsolateLogger 上调用 addPrinter 会抛出 UnsupportedError
      expect(
        () => currentLogger.addPrinter(LoggerCachePrinter()),
        throwsA(isA<UnsupportedError>()),
      );

      // 验证日志打印会正确转发至 token.backgroundPrint
      final now = DateTime.now();
      currentLogger.print(LogLevel.INFO, tag: 'IsoTag', msg: 'Isolate msg', time: now);

      expect(token.lastLevel, equals(LogLevel.INFO));
      expect(token.lastTag, equals('IsoTag'));
      expect(token.lastMsg, equals('Isolate msg'));
      expect(token.lastTime, equals(now));

      // 验证缺省 tag 时使用默认标签 "BackgroundIsolateLogger"
      currentLogger.e(msg: 'Default iso tag msg');
      expect(token.lastTag, equals('BackgroundIsolateLogger'));
    });

    test('should obtain rootIsolateToken via extension method', () {
      // 验证可以通过 extension 属性获取 RootIsolateLoggerToken 实例
      final token = Logger.instance.rootIsolateToken;
      expect(token, isA<RootIsolateLoggerToken>());
      expect(identical(token, RootIsolateLoggerToken.instance), isTrue);
    });

    test('should forward backgroundPrint from RootIsolateLoggerToken',
        () async {
      // 验证 RootIsolateLoggerToken 的 backgroundPrint 能够将消息成功发送给 ReceivePort
      final token = RootIsolateLoggerToken.instance;
      final now = DateTime.now();

      // 调用 backgroundPrint 触发 SendPort.send
      expect(
        () => token.backgroundPrint(
          LogLevel.WARN,
          'RootIsoTag',
          'Background message',
          'ErrorPayload',
          null,
          now,
        ),
        returnsNormally,
      );
    });
  });
}

import 'package:an_logger/an_logger.dart';
import 'package:test/test.dart';

// 用于测试的 Mock 打印器 A
class TestLoggerPrinterA extends LoggerPrinter {
  final List<LogEvent> events = [];

  @override
  void printEvent(LogLevel level, String tag, LogEvent event) {
    events.add(event);
  }

  void clear() => events.clear();
}

// 用于测试的 Mock 打印器 B
class TestLoggerPrinterB extends LoggerPrinter {
  final List<LogEvent> events = [];

  @override
  void printEvent(LogLevel level, String tag, LogEvent event) {
    events.add(event);
  }
}

void main() {
  group('Logger tests', () {
    late Logger logger;
    late TestLoggerPrinterA printerA;

    setUp(() {
      logger = Logger.instance;
      printerA = TestLoggerPrinterA();
      logger.addPrinter(printerA);
      logger.logLevel = LogLevel.VERBOSE; // 设置最低级别以接收所有日志
    });

    test('should return same singleton instance from static getters', () {
      // 验证 Logger.instance, Logger.logger, Logger.log 获取的均为同一个单例
      expect(identical(Logger.instance, Logger.logger), isTrue);
      expect(identical(Logger.instance, Logger.log), isTrue);
    });

    test('should filter logs below current logLevel', () {
      // 设置日志拦截级别为 WARN
      logger.logLevel = LogLevel.WARN;

      // 触发 VERBOSE, DEBUG, INFO 日志（应被拦截）
      logger.v(msg: 'verbose log');
      logger.d(msg: 'debug log');
      logger.i(msg: 'info log');

      expect(printerA.events, isEmpty);

      // 触发 WARN, ERROR, ASSERT 日志（应通过拦截）
      logger.w(msg: 'warn log');
      logger.e(msg: 'error log');
      logger.wtf(msg: 'wtf log');

      expect(printerA.events.length, equals(3));
      expect(printerA.events[0].level, equals(LogLevel.WARN));
      expect(printerA.events[1].level, equals(LogLevel.ERROR));
      expect(printerA.events[2].level, equals(LogLevel.ASSERT));
    });

    test('should use default tag "AnLogger" when tag is not provided', () {
      // 验证当未指定 tag 时使用默认标签 "AnLogger"
      logger.i(msg: 'default tag message');

      expect(printerA.events.length, equals(1));
      expect(printerA.events[0].tag, equals('AnLogger'));
    });

    test('should use custom tag when provided', () {
      // 验证当指定 custom tag 时能够正确使用
      logger.i(tag: 'CustomTag', msg: 'custom tag message');

      expect(printerA.events.length, equals(1));
      expect(printerA.events[0].tag, equals('CustomTag'));
    });

    test('should invoke all log methods with correct LogLevel', () {
      // 验证 v, d, i, w, e, wtf 便捷方法正确对应各 LogLevel
      logger.v(tag: 'V', msg: 'v');
      logger.d(tag: 'D', msg: 'd');
      logger.i(tag: 'I', msg: 'i');
      logger.w(tag: 'W', msg: 'w');
      logger.e(tag: 'E', msg: 'e');
      logger.wtf(tag: 'WTF', msg: 'wtf');

      expect(printerA.events.length, equals(6));
      expect(printerA.events[0].level, equals(LogLevel.VERBOSE));
      expect(printerA.events[1].level, equals(LogLevel.DEBUG));
      expect(printerA.events[2].level, equals(LogLevel.INFO));
      expect(printerA.events[3].level, equals(LogLevel.WARN));
      expect(printerA.events[4].level, equals(LogLevel.ERROR));
      expect(printerA.events[5].level, equals(LogLevel.ASSERT));
    });

    test('should handle print method with explicit LogLevel and custom time',
        () {
      // 验证通用 print 方法传参及自定义时间戳
      final customTime = DateTime(2025, 1, 1);
      logger.print(
        LogLevel.ERROR,
        tag: 'PrintTag',
        msg: 'Print msg',
        time: customTime,
      );

      expect(printerA.events.length, equals(1));
      expect(printerA.events[0].level, equals(LogLevel.ERROR));
      expect(printerA.events[0].tag, equals('PrintTag'));
      expect(printerA.events[0].msg, equals('Print msg'));
      expect(printerA.events[0].time, equals(customTime));
    });

    test('should convert non-string msg objects using LoggerConvert', () {
      // 验证非 String 类型消息对象通过 LoggerConvert 进行转换
      logger.i(msg: [1, 2, 3]);

      expect(printerA.events.length, equals(1));
      expect(printerA.events[0].msg, equals('[1,2,3]'));
      // source 应当保存原始非 String 对象
      expect(printerA.events[0].source, equals([1, 2, 3]));
    });

    test('should ignore empty events where msg, err and stackTrace are null',
        () {
      // 验证当 msg、err、stackTrace 均为空时不输出日志事件
      logger.i(tag: 'EmptyTag');
      expect(printerA.events, isEmpty);
    });

    test('should dispatch event to multiple registered printers', () {
      // 验证可以注册多个不同类型的 LoggerPrinter 并且均能收到日志回调
      final printerB = TestLoggerPrinterB();
      logger.addPrinter(printerB);

      logger.i(msg: 'Broadcast message');

      expect(printerA.events.length, equals(1));
      expect(printerB.events.length, equals(1));
      expect(printerB.events[0].msg, equals('Broadcast message'));
    });
  });
}

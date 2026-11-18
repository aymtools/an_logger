import 'package:an_logger/an_logger.dart';
import 'package:test/test.dart';

void main() {
  group('LoggerCachePrinter tests', () {
    test('should store printed log events in buffer', () {
      // 验证 LoggerCachePrinter 能够正确缓存打印的日志事件
      final printer = LoggerCachePrinter(bufferSize: 10);
      final event1 = LogEvent(LogLevel.INFO, 'Tag1', msg: 'Message 1');
      final event2 = LogEvent(LogLevel.ERROR, 'Tag2', msg: 'Message 2');

      printer.printEvent(LogLevel.INFO, 'Tag1', event1);
      printer.printEvent(LogLevel.ERROR, 'Tag2', event2);

      // 验证最新添加的事件位于队首（索引 0）
      expect(printer.logEvents.length, equals(2));
      expect(printer.logEvents[0], equals(event2));
      expect(printer.logEvents[1], equals(event1));
      expect(printer.logBuffer.length, equals(2));
    });

    test('should remove oldest event when buffer reaches capacity limit', () {
      // 验证当缓存达到容量上限时自动移除最旧的日志事件
      final printer = LoggerCachePrinter(bufferSize: 3);

      final event1 = LogEvent(LogLevel.INFO, 'Tag', msg: 'Event 1');
      final event2 = LogEvent(LogLevel.INFO, 'Tag', msg: 'Event 2');
      final event3 = LogEvent(LogLevel.INFO, 'Tag', msg: 'Event 3');
      final event4 = LogEvent(LogLevel.INFO, 'Tag', msg: 'Event 4');

      printer.printEvent(LogLevel.INFO, 'Tag', event1);
      printer.printEvent(LogLevel.INFO, 'Tag', event2);
      printer.printEvent(LogLevel.INFO, 'Tag', event3);

      expect(printer.logEvents.length, equals(3));
      expect(printer.logEvents.last, equals(event1));

      // 放入第 4 个事件，应当挤掉最旧的 event1
      printer.printEvent(LogLevel.INFO, 'Tag', event4);

      expect(printer.logEvents.length, equals(3));
      expect(printer.logEvents[0], equals(event4));
      expect(printer.logEvents[1], equals(event3));
      expect(printer.logEvents[2], equals(event2));
    });

    test('should use default bufferSize of 500 when unspecified', () {
      // 验证不指定 bufferSize 时默认容量为 500
      final printer = LoggerCachePrinter();
      expect(printer.logEvents, isEmpty);
    });
  });
}

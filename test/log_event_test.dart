import 'package:an_logger/an_logger.dart';
import 'package:test/test.dart';

void main() {
  group('LogEvent tests', () {
    test('should initialize default properties correctly', () {
      // 验证 LogEvent 的构造函数默认属性与传入属性
      final now = DateTime.now();
      final event = LogEvent(
        LogLevel.INFO,
        'TestTag',
        msg: 'Hello World',
        time: now,
      );

      expect(event.level, equals(LogLevel.INFO));
      expect(event.tag, equals('TestTag'));
      expect(event.msg, equals('Hello World'));
      expect(event.time, equals(now));
      expect(event.err, isNull);
      expect(event.stackTrace, isNull);
      expect(event.source, isNull);
    });

    test('should default to current time if time is not provided', () {
      // 验证当未提供 time 时自动使用当前时间
      final before = DateTime.now();
      final event = LogEvent(LogLevel.INFO, 'TestTag');
      final after = DateTime.now();

      expect(
        event.time.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        event.time.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('should return correct status for isNotEmptyMessage', () {
      // 检查当 msg、err、stackTrace 均为空时，isNotEmptyMessage 返回 false
      final emptyEvent = LogEvent(LogLevel.DEBUG, 'Tag');
      expect(emptyEvent.isNotEmptyMessage, isFalse);

      // 检查当设置 msg 时，isNotEmptyMessage 返回 true
      final msgEvent = LogEvent(LogLevel.DEBUG, 'Tag', msg: 'test');
      expect(msgEvent.isNotEmptyMessage, isTrue);

      // 检查当设置 err 时，isNotEmptyMessage 返回 true
      final errEvent =
          LogEvent(LogLevel.DEBUG, 'Tag', err: Exception('error'));
      expect(errEvent.isNotEmptyMessage, isTrue);

      // 检查当设置 stackTrace 时，isNotEmptyMessage 返回 true
      final stackEvent =
          LogEvent(LogLevel.DEBUG, 'Tag', stackTrace: StackTrace.current);
      expect(stackEvent.isNotEmptyMessage, isTrue);
    });

    test('should format messages property properly', () {
      // 验证无任何消息内容时返回空字符串
      final emptyEvent = LogEvent(LogLevel.INFO, 'Tag');
      expect(emptyEvent.messages, isEmpty);

      // 验证 msg 为空字符串时返回空字符串
      final emptyMsgEvent = LogEvent(LogLevel.INFO, 'Tag', msg: '');
      expect(emptyMsgEvent.messages, isEmpty);

      // 验证仅包含 msg 时的字符串格式
      final singleMsgEvent = LogEvent(LogLevel.INFO, 'Tag', msg: 'Log text');
      expect(singleMsgEvent.messages, equals('Log text'));

      // 验证同时包含 msg 与 err 时的换行拼接格式
      final errEvent = LogEvent(
        LogLevel.ERROR,
        'Tag',
        msg: 'Operation failed',
        err: 'CustomError',
      );
      expect(errEvent.messages, equals('Operation failed\nCustomError'));

      // 验证包含 msg、err 和 stackTrace 时的换行拼接格式
      final trace = StackTrace.current;
      final fullEvent = LogEvent(
        LogLevel.ERROR,
        'Tag',
        msg: 'Error occurred',
        err: 'DiskFull',
        stackTrace: trace,
      );
      expect(fullEvent.messages, equals('Error occurred\nDiskFull\n$trace'));
    });
  });
}

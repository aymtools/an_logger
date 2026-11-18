import 'package:an_logger/an_logger.dart';
import 'package:test/test.dart';

void main() {
  group('LogLevel tests', () {
    test('should compare log levels correctly using extension operators', () {
      // 验证日志等级的比较运算符：>、>=、<、<=
      expect(LogLevel.DEBUG > LogLevel.VERBOSE, isTrue);
      expect(LogLevel.VERBOSE > LogLevel.DEBUG, isFalse);

      expect(LogLevel.INFO >= LogLevel.INFO, isTrue);
      expect(LogLevel.INFO >= LogLevel.DEBUG, isTrue);
      expect(LogLevel.DEBUG >= LogLevel.INFO, isFalse);

      expect(LogLevel.VERBOSE < LogLevel.ASSERT, isTrue);
      expect(LogLevel.ASSERT < LogLevel.VERBOSE, isFalse);

      expect(LogLevel.WARN <= LogLevel.WARN, isTrue);
      expect(LogLevel.WARN <= LogLevel.ERROR, isTrue);
      expect(LogLevel.ERROR <= LogLevel.WARN, isFalse);
    });

    test('should maintain correct enum index order', () {
      // 验证 LogLevel 枚举的索引位置顺序
      expect(LogLevel.VERBOSE.index, equals(0));
      expect(LogLevel.DEBUG.index, equals(1));
      expect(LogLevel.INFO.index, equals(2));
      expect(LogLevel.WARN.index, equals(3));
      expect(LogLevel.ERROR.index, equals(4));
      expect(LogLevel.ASSERT.index, equals(5));
    });
  });
}

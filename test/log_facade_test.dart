import 'package:an_logger/an_logger.dart';
import 'package:test/test.dart';

// 用于测试 Log 静态类的 Mock 打印器
class LogFacadeTestPrinter extends LoggerPrinter {
  final List<LogEvent> events = [];

  @override
  void printEvent(LogLevel level, String tag, LogEvent event) {
    events.add(event);
  }
}

// 用于测试的自定义类型及转换器
class Customer {
  final String id;
  Customer(this.id);
}

class CustomerConvert extends LoggerConvertBase<Customer> {
  @override
  String convert(Customer obj, LoggerConvertContext context) {
    return 'Customer(${obj.id})';
  }
}

void main() {
  group('Log facade tests', () {
    late LogFacadeTestPrinter printer;

    setUp(() {
      printer = LogFacadeTestPrinter();
      Log.addPrinter(printer);
      Log.logLevel = LogLevel.VERBOSE;
    });

    test('should update logger level via Log.logLevel', () {
      // 验证通过 Log.logLevel 设置拦截级别
      Log.logLevel = LogLevel.ERROR;

      Log.d(msg: 'debug message');
      expect(printer.events, isEmpty);

      Log.e(msg: 'error message');
      expect(printer.events.length, equals(1));
      expect(printer.events[0].level, equals(LogLevel.ERROR));
    });

    test('should register custom convert via Log.addCustomConvert', () {
      // 验证通过 Log.addCustomConvert 注册自定义类型转换器
      Log.addCustomConvert(CustomerConvert());

      Log.i(msg: Customer('C1001'));

      expect(printer.events.length, equals(1));
      expect(printer.events[0].msg, equals('Customer(C1001)'));
    });

    test('should delegate v, d, i, w, e, wtf calls to Logger instance', () {
      // 验证 Log 的各种级别静态方法均正确转发参数给 Logger
      final trace = StackTrace.current;
      final exception = Exception('Test Exception');

      Log.v(tag: 'TagV', msg: 'Verbose msg');
      Log.d(tag: 'TagD', msg: 'Debug msg');
      Log.i(tag: 'TagI', msg: 'Info msg');
      Log.w(tag: 'TagW', msg: 'Warn msg');
      Log.e(tag: 'TagE', msg: 'Error msg', err: exception, stackTrace: trace);
      Log.wtf(tag: 'TagWTF', msg: 'WTF msg');

      expect(printer.events.length, equals(6));

      expect(printer.events[0].level, equals(LogLevel.VERBOSE));
      expect(printer.events[0].tag, equals('TagV'));
      expect(printer.events[0].msg, equals('Verbose msg'));

      expect(printer.events[4].level, equals(LogLevel.ERROR));
      expect(printer.events[4].tag, equals('TagE'));
      expect(printer.events[4].err, equals(exception));
      expect(printer.events[4].stackTrace, equals(trace));

      expect(printer.events[5].level, equals(LogLevel.ASSERT));
    });
  });
}

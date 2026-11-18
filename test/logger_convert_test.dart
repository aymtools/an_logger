import 'package:an_logger/an_logger.dart';
import 'package:test/test.dart';

// 用于测试的自定义数据类型
class User {
  final String name;
  final int age;
  User(this.name, this.age);
}

// 用于测试的自定义转换器
class UserConvert extends LoggerConvertBase<User> {
  @override
  String convert(User obj, LoggerConvertContext context) {
    return 'User(name: ${context.convert(obj.name)}, age: ${context.convert(obj.age)})';
  }
}

// 高优先级字符串转换器，用于测试多转换器优先级
class HighPriorityStringConvert extends LoggerConvertBase<String> {
  @override
  String convert(String obj, LoggerConvertContext context) => 'CUSTOM:$obj';
}

void main() {
  group('LoggerConvert tests', () {
    late LoggerConvert convertInstance;

    setUp(() {
      convertInstance = LoggerConvert.instance;
    });

    test('should convert null value to "null"', () {
      // 验证 null 对象转换为 "null" 字符串
      final result = convertInstance.convert(null);
      expect(result, equals('null'));
    });

    test('should convert string object with enclosing quotes', () {
      // 验证字符串类型的转换结果带双引号
      final result = convertInstance.convert('hello world');
      expect(result, equals('"hello world"'));
    });

    test('should convert list objects correctly', () {
      // 验证空列表转换
      expect(convertInstance.convert([]), equals('[]'));

      // 验证包含数字和字符串元素的列表转换
      final listResult = convertInstance.convert([1, 'a', true]);
      expect(listResult, equals('[1,"a",true]'));

      // 验证嵌套列表的转换
      final nestedListResult = convertInstance.convert([
        [1, 2],
        ['x', 'y']
      ]);
      expect(nestedListResult, equals('[[1,2],["x","y"]]'));
    });

    test('should convert map objects correctly', () {
      // 验证空 Map 转换
      expect(convertInstance.convert({}), equals('{}'));

      // 验证普通 Map 转换
      final mapResult = convertInstance.convert({'name': 'Alice', 'age': 20});
      expect(mapResult, equals('{"name":"Alice","age":20}'));

      // 验证嵌套 Map 转换
      final nestedMapResult = convertInstance.convert({
        'user': {'id': 1}
      });
      expect(nestedMapResult, equals('{"user":{"id":1}}'));
    });

    test('should fallback to toString for unhandled types', () {
      // 验证对于未注册专门转换器的基本类型或自定义对象使用 toString() 兜底
      expect(convertInstance.convert(123), equals('123'));
      expect(convertInstance.convert(3.14), equals('3.14'));
    });

    test('should support adding and applying custom converters', () {
      // 注册自定义 User 对象的转换器
      convertInstance.addConvert(UserConvert());

      final user = User('Bob', 25);
      final result = convertInstance.convert(user);

      // 验证自定义转换器生效，并且内部对属性也递归调用了转换器
      expect(result, equals('User(name: "Bob", age: 25)'));
    });

    test('should give higher priority to newly added converters', () {
      // 验证后加入的转换器比先加入的转换器具有更高优先级 (lastWhere 规则)
      convertInstance.addConvert(HighPriorityStringConvert());
      expect(convertInstance.convert('test'), equals('CUSTOM:test'));
    });
  });
}

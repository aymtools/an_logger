abstract class LoggerConvertBase<T> {
  bool canUse(Object obj) => obj is T;

  String convert(T obj, LoggerConvertContext context);
}

abstract class LoggerConvertContext {
  String convert(Object? obj);
}

class LoggerConvertString extends LoggerConvertBase<String> {
  @override
  String convert(String obj, LoggerConvertContext context) => '\"$obj\"';
}

class LoggerConvertList extends LoggerConvertBase<List> {
  @override
  String convert(List obj, LoggerConvertContext context) {
    if (obj.isEmpty) return '[]';
    var temp = obj.map((e) => context.convert(e)).reduce((v, e) => '$v,$e');
    return '[$temp]';
  }
}

class LoggerConvertMap extends LoggerConvertBase<Map> {
  @override
  String convert(Map obj, LoggerConvertContext context) {
    if (obj.isEmpty) return '{}';
    var temp = obj
        .map((k, v) => MapEntry(context.convert(k), context.convert(v)))
        .entries
        .map((e) => '${e.key}:${e.value}')
        .reduce((v, e) => '$v,$e');
    return '{$temp}';
  }
}

class LoggerConvert extends LoggerConvertContext {
  final Set<LoggerConvertBase> converts = {};

  LoggerConvert._() {
    this.registerConvert(LoggerConvertString());
    this.registerConvert(LoggerConvertMap());
    this.registerConvert(LoggerConvertList());
  }

  static final LoggerConvert instance = LoggerConvert._();

  void registerConvert(LoggerConvertBase convert) {
    converts.add(convert);
  }

  void unregisterConvert(LoggerConvertBase convert) {
    converts.remove(convert);
  }

  String convert(Object? obj) {
    //null需要特殊定义
    if (obj == null) return 'null';

    ///逆向循环 后加入的对象优先级高
    var firstConvert = converts.lastWhere((element) => element.canUse(obj),
        orElse: () => _FinalConvert.instance);
    return firstConvert.convert(obj, this);
  }
}

class _FinalConvert extends LoggerConvertBase<Object> {
  static final _FinalConvert instance = _FinalConvert();

  @override
  String convert(Object obj, LoggerConvertContext context) => obj.toString();
}

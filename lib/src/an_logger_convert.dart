abstract class LogConvert<T> {
  bool canUse(Object obj) => obj is T;

  String convert(T obj, LogConvertContext context);
}

abstract class LogConvertContext {
  String convert(Object? obj);
}

class StringConvert extends LogConvert<String> {
  @override
  String convert(String obj, LogConvertContext context) => '\"$obj\"';
}

class ListLogConvert extends LogConvert<List> {
  @override
  String convert(List obj, LogConvertContext context) {
    if (obj.isEmpty) return '[]';
    var temp = obj.map((e) => context.convert(e)).reduce((v, e) => '$v,$e');
    return '[$temp]';
  }
}

class MapLogConvert extends LogConvert<Map> {
  @override
  String convert(Map obj, LogConvertContext context) {
    if (obj.isEmpty) return '{}';
    var temp = obj
        .map((k, v) => MapEntry(context.convert(k), context.convert(v)))
        .entries
        .map((e) => '${e.key}:${e.value}')
        .reduce((v, e) => '$v,$e');
    return '{$temp}';
  }
}

class AnLogConvert extends LogConvertContext {
  final Set<LogConvert> converts = {};

  AnLogConvert._() {
    this.registerConvert(StringConvert());
    this.registerConvert(MapLogConvert());
    this.registerConvert(ListLogConvert());
  }

  static final AnLogConvert instance = AnLogConvert._();

  void registerConvert(LogConvert convert) {
    converts.add(convert);
  }

  void unregisterConvert(LogConvert convert) {
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

class _FinalConvert extends LogConvert<Object> {
  static final _FinalConvert instance = _FinalConvert();

  @override
  String convert(Object obj, LogConvertContext context) => obj.toString();
}

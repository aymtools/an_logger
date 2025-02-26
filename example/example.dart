import 'dart:isolate';

import 'package:an_logger/an_logger.dart';

void main() {
  Log.logLevel = LogLevel.VERBOSE;
  Log.addPrinter(MyPrinter());

  Log.v(tag: 'AnLog', msg: 'hello word');
  Log.d(tag: 'AnLog', msg: 'hello word', err: 'who is err ');

  Log.i(tag: 'AnLog', msg: 'hello word');
  Log.w(tag: 'AnLog', msg: 'hello word  wwwwwww');

  // try {
  //   throw Exception('err');
  // } catch (err, stackTrace) {
  //   Log.e(tag: 'AnLog', msg: 'hello word', err: 'err?', stackTrace: stackTrace);
  // }

  /// 如果你需要打印isolate中的日志时
  final token = Logger.instance.rootIsolateToken;

  /// 将token传递到isolate
  Isolate.spawn((RootIsolateLoggerToken token) {
    print('Isolate  create');
    // 在isolate通过token 初始化BackgroundIsolateLogger 后即可正常使用Log Logger
    BackgroundIsolateLogger.init(token.backgroundPrint);
    Log.d(tag: 'IsolateLog', msg: 'form isolate message');
    print('Isolate  will exit');
    Isolate.exit();
  }, token);
}

class MyPrinter extends LoggerPrinter {
  @override
  void printEvent(LogLevel level, String tag, LogEvent event) {
    ///Customize your output content, feel free to express yourself in any way.
    print('$level $tag ${event.messages}');
  }
}

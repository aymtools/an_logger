import 'package:an_logger/an_logger.dart';

void main() {
  Log.addPrinter(MyPrinter());

  Log.v(tag: 'AnLog', msg: 'hello word');
  Log.d(tag: 'AnLog', msg: 'hello word', err: 'who is err ');

  Log.i(tag: 'AnLog', msg: 'hello word');
  Log.w(tag: 'AnLog', msg: 'hello word  wwwwwww');

  Log.e(
      tag: 'AnLog',
      msg: 'hello word',
      err: 'err?',
      stackTrace: StackTrace.current);
}

class MyPrinter extends LoggerPrinter {
  @override
  void printEvent(LogLevel level, String tag, LogEvent event) {
    ///Customize your output content, feel free to express yourself in any way.
  }
}

A logging tool that can be customized to output to any location.

## Usage

```dart
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
```

See [example](https://github.com/aymtools/an_logger/blob/master/example/) for detailed test
case.

## Additional information

If you encounter issues, here are some tips for debug, if nothing helps report
to [issue tracker on GitHub](https://github.com/aymtools/an_logger/issues):

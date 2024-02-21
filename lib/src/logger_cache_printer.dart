import 'dart:collection';

import 'logger.dart';

class LoggerCachePrinter extends LoggerPrinter {
  final ListQueue<LogEvent> _buffer;

  final int _bufferSize;

  ListQueue<LogEvent> get logBuffer => _buffer;

  List<LogEvent> get logEvents => logBuffer.toList();

  LoggerCachePrinter({int bufferSize = 500})
      : this._bufferSize = bufferSize,
        this._buffer = ListQueue(bufferSize);

  @override
  void printEvent(LogLevel level, String tag, LogEvent event) {
    if (_buffer.length == _bufferSize) {
      _buffer.removeLast();
    }
    _buffer.addFirst(event);
  }
}

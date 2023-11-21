import 'dart:collection';

import 'an_logger.dart';

class CachePrinter extends AnLoggerPrinter {
  final ListQueue<LogEvent> _buffer;

  final int _bufferSize;

  ListQueue<LogEvent> get logBuffer => _buffer;

  List<LogEvent> get logEvents => logBuffer.toList();

  CachePrinter({int bufferSize = 500})
      : this._bufferSize = bufferSize,
        this._buffer = ListQueue(bufferSize);

  @override
  void printEvent(LogLevel level, String tag, LogEvent event) {
    if (_buffer.length == _bufferSize) {
      _buffer.removeFirst();
    }
    _buffer.add(event);
  }
}

import 'dart:async';

/// A utility class that delays the execution of a callback until after
/// the user has stopped calling it for a given [milliseconds] duration.
///
/// Useful for search inputs to avoid firing a request on every keystroke.
///
/// Usage:
/// ```dart
/// final _debouncer = Debouncer(milliseconds: 500);
/// _debouncer.run(() {
///   // This runs 500ms after the last call
///   fetchData(query);
/// });
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

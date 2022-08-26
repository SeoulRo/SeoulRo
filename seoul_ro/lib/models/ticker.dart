import 'dart:async';

class Ticker {
  Ticker();

  Stream<DateTime> tick() {
    return Stream<DateTime>.periodic(
        const Duration(seconds: 1), (_) => DateTime.now());
  }
}

import 'dart:async';

class SecondTicker {
  SecondTicker();

  Stream<DateTime> tick() {
    return Stream<DateTime>.periodic(
        const Duration(seconds: 1), (_) => DateTime.now());
  }
}

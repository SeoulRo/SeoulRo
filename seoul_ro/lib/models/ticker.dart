class Ticker {
  final DateTime currentTime = DateTime.now();
  Ticker();

  Stream<DateTime> tick() {
    return Stream<DateTime>.periodic(const Duration(seconds: 1),
        (x) => currentTime.add(Duration(seconds: x))).take(1);
  }
}

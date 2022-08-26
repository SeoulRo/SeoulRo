class Poller {
  const Poller();

  Stream<int> poll({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 5), (x) => ticks - x - 1);
  }
}
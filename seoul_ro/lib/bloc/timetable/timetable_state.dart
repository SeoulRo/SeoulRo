import 'package:equatable/equatable.dart';
import '../../models/spot.dart';

const String initialTitle = '당신의 서울 여행';
const List<Spot> initialSpots = <Spot>[];

class TimetableState extends Equatable {
  final String title;
  final DateTime date;
  final List<Spot> spots;

  const TimetableState(
      {this.title = initialTitle,
      required this.date,
      this.spots = initialSpots})
      : super();

  TimetableState copyWith({
    String? title,
    DateTime? date,
    List<Spot>? spots,
  }) {
    return TimetableState(
        title: title ?? this.title,
        date: date ?? this.date,
        spots: spots ?? this.spots);
  }

  @override
  String toString() {
    return 'TimeTableState: { title: $title, date: $date, spots: ${spots.length}}';
  }

  @override
  List<Object> get props => [title, date, spots];
}

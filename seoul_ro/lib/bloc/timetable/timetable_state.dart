import 'package:equatable/equatable.dart';
import '../../models/spot.dart';

const String initialTitle = '당신의 서울 여행';
const List<Spot> initialSpots = <Spot>[];

class TimetableState extends Equatable {
  final String title;
  final DateTime date;
  final List<Spot> spots;
  final bool isDateSelected;

  const TimetableState(
      {this.title = initialTitle,
      required this.date,
      this.spots = initialSpots,
      this.isDateSelected = false})
      : super();

  TimetableState copyWith({
    String? title,
    DateTime? date,
    List<Spot>? spots,
    bool? isDateSelected,
  }) {
    return TimetableState(
        title: title ?? this.title,
        date: date ?? this.date,
        spots: spots ?? this.spots,
        isDateSelected: isDateSelected ?? this.isDateSelected);
  }

  @override
  String toString() {
    return 'TimeTableState: { title: $title, date: $date, spots: ${spots.length}}';
  }

  @override
  List<Object> get props => [title, date, spots, isDateSelected];
}

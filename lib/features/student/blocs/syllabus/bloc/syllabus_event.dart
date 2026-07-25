import 'package:equatable/equatable.dart';

abstract class SyllabusEvent extends Equatable {
  const SyllabusEvent();

  @override
  List<Object?> get props => [];
}

class LoadSyllabus extends SyllabusEvent {
  const LoadSyllabus();
}

class SelectSyllabusSemester extends SyllabusEvent {
  final int semester;

  const SelectSyllabusSemester(this.semester);

  @override
  List<Object?> get props => [semester];
}

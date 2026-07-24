import 'package:equatable/equatable.dart';




abstract class TeacherProfileEvent extends Equatable {

  const TeacherProfileEvent();


  @override
  List<Object?> get props => [];

}


// Load profile
class LoadTeacherProfileEvent 
    extends TeacherProfileEvent {

  const LoadTeacherProfileEvent();

}



// Update profile
class UpdateTeacherProfileEvent 
    extends TeacherProfileEvent {

  final Map<String, dynamic> data;


  const UpdateTeacherProfileEvent(
    this.data,
  );


  @override
  List<Object?> get props => [
    data,
  ];

}
import 'package:equatable/equatable.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/models/teacher_profile_model.dart';



abstract class TeacherProfileState extends Equatable {

  const TeacherProfileState();


  @override
  List<Object?> get props => [];

}



// Initial
class TeacherProfileInitial 
    extends TeacherProfileState {}




// Loading
class TeacherProfileLoading 
    extends TeacherProfileState {}




// Loaded
class TeacherProfileLoaded 
    extends TeacherProfileState {

  final TeacherProfileModel profile;


  const TeacherProfileLoaded(
    this.profile,
  );


  @override
  List<Object?> get props => [
    profile,
  ];

}




// Updating
class TeacherProfileUpdating 
    extends TeacherProfileState {}




// Error
class TeacherProfileError 
    extends TeacherProfileState {

  final String message;


  const TeacherProfileError(
    this.message,
  );


  @override
  List<Object?> get props => [
    message,
  ];

}
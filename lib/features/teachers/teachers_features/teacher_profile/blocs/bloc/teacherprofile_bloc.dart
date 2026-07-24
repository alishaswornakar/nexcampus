import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/blocs/bloc/teacherprofile_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/blocs/bloc/teacherprofile_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/repository/teacher_profile_repository.dart';





class TeacherProfileBloc 
    extends Bloc<TeacherProfileEvent, TeacherProfileState> {


  final TeacherProfileRepository repository;



  TeacherProfileBloc(
    this.repository,
  ) : super(
        TeacherProfileInitial(),
      ) {



    on<LoadTeacherProfileEvent>(
      _loadProfile,
    );


    on<UpdateTeacherProfileEvent>(
      _updateProfile,
    );

  }




  Future<void> _loadProfile(
    LoadTeacherProfileEvent event,
    Emitter<TeacherProfileState> emit,

  ) async {


    emit(
      TeacherProfileLoading(),
    );


    try {

      final profile =
          await repository.getTeacherProfile();


      emit(
        TeacherProfileLoaded(
          profile,
        ),
      );


    } catch(e) {


      emit(
        TeacherProfileError(
          e.toString(),
        ),
      );


    }

  }





  Future<void> _updateProfile(
    UpdateTeacherProfileEvent event,
    Emitter<TeacherProfileState> emit,

  ) async {


    emit(
      TeacherProfileUpdating(),
    );


    try {


      await repository.updateTeacherProfile(
        event.data,
      );


      final profile =
          await repository.getTeacherProfile();



      emit(
        TeacherProfileLoaded(
          profile,
        ),
      );


    } catch(e) {


      emit(
        TeacherProfileError(
          e.toString(),
        ),
      );


    }

  }

}
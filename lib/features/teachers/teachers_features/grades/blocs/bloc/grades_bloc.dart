import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'grades_event.dart';
part 'grades_state.dart';

class GradesBloc extends Bloc<GradesEvent, GradesState> {
  GradesBloc() : super(GradesInitial()) {
    on<GradesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

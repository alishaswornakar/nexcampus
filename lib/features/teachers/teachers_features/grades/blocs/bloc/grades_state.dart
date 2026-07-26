part of 'grades_bloc.dart';

sealed class GradesState extends Equatable {
  const GradesState();
  
  @override
  List<Object> get props => [];
}

final class GradesInitial extends GradesState {}

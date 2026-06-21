// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'auth_event.dart';
// import 'auth_state.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   AuthBloc() : super(AuthInitial()) {
//     on<LoginRequested>(_login);
//     on<SignupRequested>(_signup);
//   }

//   Future<void> _login(
//     LoginRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());

//     try {
//       final credential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(
//         email: event.email,
//         password: event.password,
//       );

//       final uid = credential.user!.uid;

//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .get();

//       final role = doc['role'];

//       emit(AuthAuthenticated(role));
//     } catch (e) {
//       emit(AuthError("Login failed"));
//     }
//   }

//   Future<void> _signup(
//     SignupRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());

//     try {
//       final credential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//         email: event.email,
//         password: event.password,
//       );

//       final uid = credential.user!.uid;

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .set({
//         'fullName': event.fullName,
//         'email': event.email,
//         'roll': event.roll,
//         'department': event.department,
//         'semester': event.semester,
//         'role': event.role,
//       });

//       emit(AuthAuthenticated(event.role));
//     } catch (e) {
//       emit(AuthError("Signup failed"));
//     }
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/authentication/services/auth_service.dart';

import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_login);
    on<SignupRequested>(_signup);
    on<GoogleLoginRequested>(_googleLogin); 
  }

  // =========================
  // EMAIL LOGIN
  // =========================
  Future<void> _login(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final credential = await _authService.login(
        email: event.email,
        password: event.password,
      );

      final uid = credential.user!.uid;

      final role = await _authService.getUserRole(uid);

      emit(AuthAuthenticated(role));
    } catch (e) {
      emit(AuthError("Login failed. Please check credentials."));
    }
  }

  // =========================
  // SIGNUP
  // =========================
  Future<void> _signup(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final credential = await _authService.signup(
        email: event.email,
        password: event.password,
      );

      final uid = credential.user!.uid;

      await _authService.createUserProfile(
        uid: uid,
        fullName: event.fullName,
        email: event.email,
        roll: event.roll,
        department: event.department,
        semester: event.semester,
        role: event.role,
      );

      emit(AuthAuthenticated(event.role));
    } catch (e) {
      emit(AuthError("Signup failed. Try again."));
    }
  }

  // =========================
  // GOOGLE LOGIN 
  // =========================
  Future<void> _googleLogin(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null) {
        emit(AuthError("Google sign-in cancelled"));
        return;
      }

      final uid = userCredential.user!.uid;

      final role = await _authService.getUserRole(uid);

      emit(AuthAuthenticated(role));
    } catch (e) {
      emit(AuthError("Google sign-in failed"));
    }
  }
}
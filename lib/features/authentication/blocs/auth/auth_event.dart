abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String roll;
  final String department;
  final String semester;
  final String role;

  SignupRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.roll,
    required this.department,
    required this.semester,
    required this.role,
  });
}
class GoogleLoginRequested extends AuthEvent {}
// import 'package:flutter/material.dart';
// import 'package:nexcampus_app/core/constants/app_theme.dart';
// import 'package:nexcampus_app/features/authentication/services/auth_service.dart';
// import 'package:nexcampus_app/features/student/screens/student_dashboard_screen.dart';
// import 'package:nexcampus_app/features/authentication/presentation/pages/sign_up_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign Up')),
//       body: const Center(child: Text('Registration Screen')),
//     );
//   }
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   bool obscureText = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               const SizedBox(height: 40),

//               /// Logo
//               Container(
//                 height: 90,
//                 width: 90,
//                 decoration: BoxDecoration(
//                   color: AppTheme.primary,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Icon(Icons.school, color: Colors.white, size: 45),
//               ),

//               const SizedBox(height: 20),

//               const Text(
//                 "NexCampus",
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.primary,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               const Text(
//                 "The future campus for students",
//                 style: TextStyle(color: AppTheme.textSecondary),
//               ),

//               const SizedBox(height: 50),

//               /// Email
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   hintText: "e.g. 2024-12345",
//                   prefixIcon: const Icon(Icons.email_outlined),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// Password
//               TextField(
//                 controller: passwordController,
//                 obscureText: obscureText,
//                 decoration: InputDecoration(
//                   labelText: "Password",
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       obscureText
//                           ? Icons.visibility_outlined
//                           : Icons.visibility_off_outlined,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         obscureText = !obscureText;
//                       });
//                     },
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//               ),

//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {},
//                   child: const Text(
//                     "Forgot Password?",
//                     style: TextStyle(color: AppTheme.primary),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// Login Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Firebase Login
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primary,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Login",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Icon(Icons.login),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 25),

//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: OutlinedButton.icon(
//                   onPressed: () async {
//                     final user = await AuthService().signInWithGoogle();

//                     if (user != null && context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             'Welcome ${user.displayName ?? user.email}',
//                           ),
//                         ),
//                       );

//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               StudentDashboardScreen(user: user),
//                         ),
//                       );
//                     }
//                   },
//                   icon: Image.asset(
//                     'assets/images/google_logo.png',
//                     height: 22,
//                   ),
//                   label: const Text(
//                     "Sign in with Google",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.black87,
//                     side: const BorderSide(color: Color(0xFFDDDDDD)),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 35),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("New to the platform?"),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const SignUpScreen()),
//                       );
//                     },
//                     child: const Text(
//                       "Sign Up",
//                       style: TextStyle(
//                         color: AppTheme.primary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/authentication/blocs/auth/auth_bloc.dart';
import 'package:nexcampus_app/features/authentication/blocs/auth/auth_event.dart';
import 'package:nexcampus_app/features/authentication/blocs/auth/auth_state.dart';

import 'package:nexcampus_app/features/authentication/presentation/pages/sign_up_screen.dart';

import 'package:nexcampus_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:nexcampus_app/features/student/screens/student_dashboard_screen.dart';
import 'package:nexcampus_app/features/teachers/screens/teacher_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (email == "admin@nexcampus.com" && password == "admin123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
      return;
    }

    context.read<AuthBloc>().add(LoginRequested(email, password));
  }

  void _googleLogin() {
    context.read<AuthBloc>().add(GoogleLoginRequested());
  }

  @override
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Please wait...")));
        }

        if (state is AuthAuthenticated) {
          if (state.role == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else if (state.role == "teacher") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TeacherDashboard()),
            );
          } else {
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentDashboardScreen(user: user),
                ),
              );
            }
          }
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: (.05)),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Logo
                    Center(
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            "NX",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        "Log in to your NexCampus account",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      "Email",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: const Icon(Icons.mail_outline),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Password",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: passwordController,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OR",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: _googleLogin,
                        icon: Image.asset(
                          "assets/images/google_logo.png",
                          height: 22,
                        ),
                        label: const Text(
                          "Continue with Google",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

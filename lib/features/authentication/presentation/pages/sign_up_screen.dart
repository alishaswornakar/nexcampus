import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/authentication/blocs/auth/auth_bloc.dart';
import 'package:nexcampus_app/features/authentication/blocs/auth/auth_event.dart';
import 'package:nexcampus_app/features/authentication/blocs/auth/auth_state.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rollController = TextEditingController();
  final _employeeIdController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  int _semester = 1;

  String selectedRole = "student";
  String? _selectedDepartment;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  void _signup() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
          SignupRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _fullNameController.text.trim(),
            roll: selectedRole == "student"
                ? _rollController.text.trim()
                : "",
            department: _selectedDepartment!,
            semester:
                selectedRole == "student" ? _semester.toString() : "",
            role: selectedRole,
          ),
        );
  }

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppTheme.primary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                    Center(
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                
                   const Center(
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Join NexCampus and continue your academic journey.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Role",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: fieldDecoration(
                      hint: "Select Role",
                      icon: Icons.person_outline,
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: "student",
                        child: Text("Student"),
                      ),
                      DropdownMenuItem<String>(
                        value: "teacher",
                        child: Text("Teacher"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Full Name",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter full name";
                      }
                      return null;
                    },
                    decoration: fieldDecoration(
                      hint: "John Doe",
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (selectedRole == "student") ...[
                    const Text(
                      "Roll Number",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _rollController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter roll number";
                        }
                        return null;
                      },
                      decoration: fieldDecoration(
                        hint: "NX-2024-001",
                        icon: Icons.badge_outlined,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  if (selectedRole == "teacher") ...[
                    const Text(
                      "Employee ID",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _employeeIdController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter employee ID";
                        }
                        return null;
                      },
                      decoration: fieldDecoration(
                        hint: "EMP-001",
                        icon: Icons.badge_outlined,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  const Text(
                    "Email",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter email";
                      }
                      return null;
                    },
                    decoration: fieldDecoration(
                      hint: "example@gmail.com",
                      icon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 20),
                                    const Text(
                    "Department",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    validator: (value) {
                      if (value == null) {
                        return "Please select department";
                      }
                      return null;
                    },
                    decoration: fieldDecoration(
                      hint: "Select Department",
                      icon: Icons.apartment_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Computer Engineering",
                        child: Text("Computer Engineering"),
                      ),
                      DropdownMenuItem(
                        value: "Civil Engineering",
                        child: Text("Civil Engineering"),
                      ),
                      DropdownMenuItem(
                        value: "Architecture Engineering",
                        child: Text("Architecture Engineering"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                  ),

                  if (selectedRole == "student") ...[
                    const SizedBox(height: 20),

                    const Text(
                      "Semester",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<int>(
                      initialValue: _semester,
                      decoration: fieldDecoration(
                        hint: "Semester",
                        icon: Icons.school_outlined,
                      ),
                      items: List.generate(
                        8,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text("Semester ${index + 1}"),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _semester = value!;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  const Text(
                    "Password",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                    decoration: fieldDecoration(
                      hint: "Enter Password",
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible =
                                !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
                  
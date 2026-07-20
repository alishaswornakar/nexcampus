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
        roll: selectedRole == "student" ? _rollController.text.trim() : "",
        department: _selectedDepartment!,
        semester: selectedRole == "student" ? _semester.toString() : "",
        role: selectedRole,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is AuthAuthenticated) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 430),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: (0.05)),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Center(
                        child: Text(
                          "Create Your Account",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Center(
                        child: Text(
                          "Join the NexCampus ecosystem",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Select Role",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "student",
                            child: Text("Student"),
                          ),
                          DropdownMenuItem(
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

                      const SizedBox(height: 18),

                      const Text(
                        "Full Name",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "John Doe",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (selectedRole == "student") ...[
                        const Text(
                          "Roll Number",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _rollController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "NX-2024-001",
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],

                      if (selectedRole == "teacher") ...[
                        const Text(
                          "Employee ID",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _employeeIdController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "EMP-001",
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],

                      const Text(
                        "Email",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "example@gmail.com",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        "Department",
                        style: TextStyle(fontWeight: FontWeight.w600),
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
                        decoration: InputDecoration(
                          hintText: "Select Department",
                          prefixIcon: const Icon(Icons.apartment_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                        const SizedBox(height: 18),

                        const Text(
                          "Semester",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<int>(
                          initialValue: _semester,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.school_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          items: List.generate(
                            8,
                            (index) => DropdownMenuItem(
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

                      const SizedBox(height: 18),

                      const Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.w600),
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
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
                                  "Sign Up",
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
                          const Text("Already have an account?"),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

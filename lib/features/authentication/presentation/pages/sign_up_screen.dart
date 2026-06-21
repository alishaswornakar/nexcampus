import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/features/authentication/blocs/auth/auth_bloc.dart';
import 'package:nexcampus_app/features/authentication/blocs/auth/auth_event.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
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
  final _departmentController = TextEditingController();
  final _employeeIdController = TextEditingController();

  int _semester = 1;
  String selectedRole = "student";

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollController.dispose();
    _departmentController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  void _signup() {
    if (!_formKey.currentState!.validate()) return;

    final role = selectedRole;

    context.read<AuthBloc>().add(
          SignupRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _fullNameController.text.trim(),
            roll: role == "student" ? _rollController.text.trim() : "",
            department: _departmentController.text.trim(),
            semester: role == "student" ? _semester.toString() : "",
            role: role,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Create Account")),
      body: BlocListener<AuthBloc, dynamic>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is AuthAuthenticated) {
            Navigator.pop(context); // go back to login
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// ROLE SELECTOR
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Select Role",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "student", child: Text("Student")),
                    DropdownMenuItem(value: "teacher", child: Text("Teacher")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),

                const SizedBox(height: 12),

                /// FULL NAME
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 12),

                /// EMAIL
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 12),

                /// PASSWORD
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v != null && v.length < 6 ? "Min 6 chars" : null,
                ),

                const SizedBox(height: 12),

                /// STUDENT FIELDS
                if (selectedRole == "student") ...[
                  TextFormField(
                    controller: _rollController,
                    decoration: const InputDecoration(
                      labelText: "Roll Number",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: _semester,
                    decoration: const InputDecoration(
                      labelText: "Semester",
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      8,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text("Semester ${i + 1}"),
                      ),
                    ),
                    onChanged: (v) => setState(() => _semester = v ?? 1),
                  ),
                ],

                /// TEACHER FIELDS
                if (selectedRole == "teacher") ...[
                  TextFormField(
                    controller: _employeeIdController,
                    decoration: const InputDecoration(
                      labelText: "Employee ID",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),
                ],

                const SizedBox(height: 12),

                /// DEPARTMENT (COMMON)
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: "Department",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 20),

                /// SIGNUP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Create Account"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
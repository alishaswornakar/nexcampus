import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/admin/models/student_model.dart';
import 'package:nexcampus_app/features/admin/services/admin_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Text Editing Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Dropdown Selections
  String? _selectedDepartment;
  int? _selectedSemester;
  String? _selectedSection;

  // Options
  final List<String> _departments = ['Computer', 'Civil', 'Architecture'];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  int _getMaxSemester(String? department) {
    if (department == 'Architecture') {
      return 10;
    }
    return 8;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDepartment == null ||
          _selectedSemester == null ||
          _selectedSection == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all dropdown selections!'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final newStudent = StudentModel(
          id: '',
          name: _nameController.text.trim(),
          section: _selectedSection!,
          rollNo: _rollController.text.trim(),
          email: _emailController.text.trim(),
          phone: String.fromCharCode(int.parse(_phoneController.text.trim())),
          department: _selectedDepartment!,
          semester: _selectedSemester.toString(),
          address: _addressController.text.trim(),
          uid: '',
        );

        // 'studentData' मा Add गर्न Async execution
        await AdminService.addStudent(newStudent);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student ${newStudent.name} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int maxSemester = _getMaxSemester(_selectedDepartment);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text(
          "Add New Student",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Department",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                hint: const Text("Choose Department"),
                decoration: _inputDecoration(),
                items: _departments.map((dept) {
                  return DropdownMenuItem(value: dept, child: Text(dept));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                    _selectedSemester = null;
                  });
                },
                validator: (val) =>
                    val == null ? 'Please select a department' : null,
              ),

              const SizedBox(height: 18),

              const Text(
                "Select Semester",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedSemester,
                hint: Text(
                  _selectedDepartment == null
                      ? "First select a department"
                      : "Choose Semester (1 - $maxSemester)",
                ),
                decoration: _inputDecoration(),
                items: _selectedDepartment == null
                    ? []
                    : List.generate(
                        maxSemester,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text("Semester ${index + 1}"),
                        ),
                      ),
                onChanged: _selectedDepartment == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedSemester = value;
                        });
                      },
                validator: (val) =>
                    val == null ? 'Please select a semester' : null,
              ),

              const SizedBox(height: 18),

              const Text(
                "Select Section",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedSection,
                hint: const Text("Choose Section"),
                decoration: _inputDecoration(),
                items: _sections.map((sec) {
                  return DropdownMenuItem(
                    value: sec,
                    child: Text("Section $sec"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value;
                  });
                },
                validator: (val) =>
                    val == null ? 'Please select a section' : null,
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 10),

              const Text(
                "Student Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  hint: "Full Name",
                  icon: Icons.person_outline,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter student name'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _rollController,
                decoration: _inputDecoration(
                  hint: "Roll No / Student ID",
                  icon: Icons.badge_outlined,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter roll number'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  hint: "Email Address",
                  icon: Icons.email_outlined,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter email address'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  hint: "Phone Number",
                  icon: Icons.phone_outlined,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter phone number';
                  }
                  if (val.trim().length < 10) {
                    return 'Enter valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration(
                  hint: "Permanent Address",
                  icon: Icons.location_on_outlined,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter address' : null,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Add Student",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryColor ?? Colors.blue),
      ),
    );
  }
}

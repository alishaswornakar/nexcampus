import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/admin/models/teacher_model.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _teacherIdController =
      TextEditingController(); // 👈 Teacher ID Controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController =
      TextEditingController(); // 👈 Address Controller
  final TextEditingController _qualificationController =
      TextEditingController();

  String? _selectedDepartment;
  final List<String> _departments = ['Computer', 'Civil', 'Architecture'];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDepartment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a department!')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final newTeacher = TeacherModel(
          id: '',
          teacherId: _teacherIdController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          department: _selectedDepartment!,
          qualification: _qualificationController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('teacherData')
            .add(newTeacher.toMap());

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Teacher ${newTeacher.name} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add teacher: $e'),
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
    _teacherIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text(
          "Add New Teacher",
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
                  setState(() => _selectedDepartment = value);
                },
                validator: (val) =>
                    val == null ? 'Please select a department' : null,
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 10),

              const Text(
                "Teacher Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),

              // 🆔 1. Teacher ID Field
              TextFormField(
                controller: _teacherIdController,
                decoration: _inputDecoration(
                  hint: "Teacher ID (e.g. TCH-101)",
                  icon: Icons.badge_outlined,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter teacher ID'
                    : null,
              ),
              const SizedBox(height: 14),

              // 👤 2. Full Name
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  hint: "Full Name",
                  icon: Icons.person_outline,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter teacher name'
                    : null,
              ),
              const SizedBox(height: 14),

              // ✉️ 3. Email
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

              // 📞 4. Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  hint: "Phone Number",
                  icon: Icons.phone_outlined,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter phone number'
                    : null,
              ),
              const SizedBox(height: 14),

              // 🏠 5. Address Field
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration(
                  hint: "Address",
                  icon: Icons.location_on_outlined,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 14),

              // 🎓 6. Qualification
              TextFormField(
                controller: _qualificationController,
                decoration: _inputDecoration(
                  hint: "Qualification / Designation (e.g. M.Sc / Lecturer)",
                  icon: Icons.school_outlined,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter qualification'
                    : null,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor ?? Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Add Teacher",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

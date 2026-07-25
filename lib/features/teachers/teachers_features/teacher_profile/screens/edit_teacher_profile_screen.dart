import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/cloudinary_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/widgets/save_button.dart';


import '../blocs/bloc/teacherprofile_bloc.dart';
import '../blocs/bloc/teacherprofile_event.dart';
import '../blocs/bloc/teacherprofile_state.dart';
import '../models/teacher_profile_model.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_textfield.dart';


class EditTeacherProfileScreen extends StatefulWidget {
  final TeacherProfileModel profile;

  const EditTeacherProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditTeacherProfileScreen> createState() =>
      _EditTeacherProfileScreenState();
}

class _EditTeacherProfileScreenState
    extends State<EditTeacherProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _departmentController;
  late final TextEditingController _designationController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _experienceController;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    _fullNameController =
        TextEditingController(text: profile.fullName);

    _emailController =
        TextEditingController(text: profile.email);

    _phoneController =
        TextEditingController(text: profile.phone ?? "");

    _departmentController =
        TextEditingController(text: profile.department ?? "");

    _designationController =
        TextEditingController(text: profile.designation ?? "");

    _qualificationController =
        TextEditingController(text: profile.qualification ?? "");

    _experienceController =
        TextEditingController(text: profile.experience ?? "");
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedImage == null) {
      return widget.profile.photoUrl;
    }

    try {
      final result = await CloudinaryService().uploadImage(
        _selectedImage!,
      );

      return result["url"];
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Image upload failed\n$e",
          ),
        ),
      );

      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final photoUrl = await _uploadProfileImage();

    if (!mounted) return;

    context.read<TeacherProfileBloc>().add(
      UpdateTeacherProfileEvent(
        {
          "fullName": _fullNameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "department":
              _departmentController.text.trim(),
          "designation":
              _designationController.text.trim(),
          "qualification":
              _qualificationController.text.trim(),
          "experience":
              _experienceController.text.trim(),
          "photoUrl": photoUrl,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
        TeacherProfileBloc,
        TeacherProfileState>(
      listener: (context, state) {
        if (state is TeacherProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Profile updated successfully",
              ),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }

        if (state is TeacherProfileError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
            builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F7FA),

          appBar: AppBar(
            title: const Text("Edit Profile"),
            centerTitle: true,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),

          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Center(
                    child: ProfileAvatar(
                      imageFile: _selectedImage,
                      imageUrl: widget.profile.photoUrl,
                      onTap: _pickImage,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Personal Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ProfileTextField(
                    controller: _fullNameController,
                    label: "Full Name",
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Full name is required";
                      }
                      return null;
                    },
                  ),

                  ProfileTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email,
                    readOnly: true,
                  ),

                  ProfileTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Professional Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ProfileTextField(
                    controller: _departmentController,
                    label: "Department",
                    icon: Icons.school,
                    readOnly: true,
                  ),

                  ProfileTextField(
                    controller: _designationController,
                    label: "Designation",
                    icon: Icons.work,
                    readOnly: true,
                  ),

                  ProfileTextField(
                    controller: _qualificationController,
                    label: "Qualification",
                    icon: Icons.menu_book,
                  ),

                  ProfileTextField(
                    controller: _experienceController,
                    label: "Experience",
                    icon: Icons.star,
                  ),

                  const SizedBox(height: 35),

                  SaveProfileButton(
                    isLoading:
                        state is TeacherProfileUpdating,
                    onPressed: _saveProfile,
                  ),

                  const SizedBox(height: 20),
                                  ],
              ),
            ),
          ),
        );
      },
    );
  }
}
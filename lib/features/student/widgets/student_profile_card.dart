import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfileCard extends StatefulWidget {
  final User user;
  const StudentProfileCard({super.key, required this.user});
  @override
  State<StudentProfileCard> createState() => _StudentProfileCardState();
}

class _StudentProfileCardState extends State<StudentProfileCard> {
  File? _profileImage;
  //String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        // _imagePath = pickedFile.path;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');

    if (path != null && File(path).existsSync()) {
      setState(() {
        // _imagePath = path;
        _profileImage = File(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : (widget.user.photoURL != null
                          ? NetworkImage(widget.user.photoURL!)
                          : null)
                      as ImageProvider?,
            child: _profileImage == null && widget.user.photoURL == null
                ? IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: _pickImage,
                  )
                : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.displayName ?? "Student",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(widget.user.email ?? ""),

                const Text("Department: Computer Science"),

                const Text("Semester: 6"),
              ],
            ),
          ),

          Container(
            width: 70,
            height: 70,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE6F0FF),
            ),

            child: const Center(
              child: Text(
                "88%",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

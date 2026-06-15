import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentProfileCard extends StatelessWidget {
  final User user;

  const StudentProfileCard({super.key, required this.user});

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
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null ? const Icon(Icons.person) : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? "Student",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(user.email ?? ""),

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

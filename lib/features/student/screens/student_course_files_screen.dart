import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentCourseFilesScreen extends StatelessWidget {
  const StudentCourseFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Materials (Admin)"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Admin le haleko files 'course_files' collection ma chha
        stream: FirebaseFirestore.instance
            .collection('course_files')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No course materials available."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var file = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  title: Text(
                    file['title'] ?? "Untitled File",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Subject: ${file['subject'] ?? 'N/A'}\nDept: ${file['department']} | Sem: ${file['semester']}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.download_for_offline, color: Colors.blue),
                  onTap: () async {
                    // 🔗 File URL open garne logic
                    final url = file['fileUrl'];
                    if (url != null && await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Could not open file"))
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
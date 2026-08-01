import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class StudentMaterialView extends StatelessWidget {
  final String department;
  final String semester;

  const StudentMaterialView({
    super.key, 
    required this.department, 
    required this.semester
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Course Materials"),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Admin Files", icon: Icon(Icons.admin_panel_settings)),
              Tab(text: "Teacher Notes", icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. Admin le haleko materials (Filter by Dept & Sem)
            _buildMaterialList('course_files', department, semester),
            
            // 2. Teacher le haleko notes (Filter by Dept & Sem)
            _buildMaterialList('notes', department, semester),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialList(String collectionName, String dept, String sem) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .where('department', isEqualTo: dept)
          .where('semester', isEqualTo: sem)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) 
          return const Center(child: CircularProgressIndicator());
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) 
          return Center(child: Text("No materials found for $dept - $sem"));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(data['title'] ?? "Untitled File"),
                subtitle: Text("Subject: ${data['subject'] ?? data['courseName'] ?? 'N/A'}"),
                trailing: const Icon(Icons.download, color: AppTheme.primary),
                onTap: () async {
                  final url = data['fileUrl'];
                  if (url != null && await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
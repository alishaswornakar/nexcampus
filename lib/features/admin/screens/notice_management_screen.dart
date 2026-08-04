import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'publish_notice_screen.dart';
import 'edit_notice_screen.dart'; // यदि यो फाइल बनाउनु भएको छ भने

class NoticeManagementScreen extends StatelessWidget {
  const NoticeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Manage Notices',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B52D4),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => const PublishNoticeScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Notice",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "All Recent Updates",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              if (docs.isEmpty) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No notices found. Click 'Add Notice' to create one."),
                  ),
                ),
              ] else ...[
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildNoticeCard(
                    context: context,
                    docId: doc.id,
                    title: data['title'] ?? '',
                    subtitle: data['description'] ?? '',
                    date: data['date'] ?? '28/7/2026',
                    audience: data['audience'] ?? 'All',
                    fileUrl: data['fileUrl'] ?? '',
                    fileName: data['fileName'] ?? '',
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoticeCard({
    required BuildContext context,
    required String docId,
    required String title,
    required String subtitle,
    required String date,
    required String audience,
    required String fileUrl,
    required String fileName,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_outlined, color: Color(0xFF3B52D4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) async {
                  if (value == 'view') {
                    // =================== VIEW DIALOG ===================
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(title),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(subtitle.isEmpty ? "No description available." : subtitle),
                              const SizedBox(height: 16),
                              
                              // ✅ फाइल छ भने नाम र लिङ्क देखाउने भाग
                              if (fileName.isNotEmpty) ...[
                                const Text("Attachment:", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    if (fileUrl.isNotEmpty) {
                                      final Uri uri = Uri.parse(fileUrl);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            fileName,
                                            style: const TextStyle(
                                              color: Colors.blue, 
                                              decoration: TextDecoration.underline,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const Text("No attachment for this notice.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          if (fileUrl.isNotEmpty)
                            TextButton(
                              onPressed: () async {
                                final Uri uri = Uri.parse(fileUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: const Text("Open File"),
                            ),
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
                        ],
                      ),
                    );
                  } else if (value == 'edit') {
                    // =================== EDIT SCREEN REDIRECT ===================
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNoticeScreen(
                          docId: docId,
                          currentTitle: title,
                          currentDesc: subtitle,
                          currentAudience: audience,
                          currentFileUrl: fileUrl,
                          currentFileName: fileName,
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    // =================== DELETE FUNCTION ===================
                    if (docId.isNotEmpty) {
                      try {
                        await FirebaseFirestore.instance.collection('notices').doc(docId).delete();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Notice deleted successfully")),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error deleting: $e")),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(children: [Icon(Icons.visibility, size: 18), SizedBox(width: 8), Text("View")]),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit, color: Colors.orange, size: 18), SizedBox(width: 8), Text("Edit")]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Audience: $audience",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3B52D4)),
                ),
              ),
              if (fileUrl.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.attach_file, size: 16, color: Colors.blue),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
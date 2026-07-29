import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../admin/models/notice_model.dart';
import '../../admin/services/admin_notice_service.dart';

class StudentNoticeScreen extends StatelessWidget {
  final String userRole; // Pass 'Student' or 'Teacher'

  const StudentNoticeScreen({super.key, this.userRole = 'Student'});

  Future<void> _openAttachment(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$userRole Notices"),
        // ❌ No Add / Plus FloatingActionButton here (Read-Only)
      ),
      body: StreamBuilder<List<NoticeModel>>(
        stream: AdminNoticeService.getNoticesForUser(userRole),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notices available."));
          }

          final notices = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notice.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              notice.postedBy,
                              style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(notice.description, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          if (notice.attachmentUrl != null && notice.attachmentUrl!.isNotEmpty)
                            InkWell(
                              onTap: () => _openAttachment(notice.attachmentUrl!),
                              child: const Row(
                                children: [
                                  Icon(Icons.attachment, size: 16, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Text("View Attachment", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      // ❌ No Edit / Delete PopupMenuButton here (Teachers & Students cannot edit/delete)
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
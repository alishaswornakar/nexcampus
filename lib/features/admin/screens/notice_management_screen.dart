import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/notice_model.dart';
import '../services/admin_notice_service.dart';
import 'publish_notice_screen.dart';

class NoticeManagementScreen extends StatefulWidget {
  const NoticeManagementScreen({super.key});

  @override
  State<NoticeManagementScreen> createState() => _NoticeManagementScreenState();
}

class _NoticeManagementScreenState extends State<NoticeManagementScreen> {
  // 👁️ Attachment View
  Future<void> _viewAttachment(String urlString) async {
    if (urlString.isEmpty) return;
    final String cleanUrl = urlString.replaceAll('/fl_attachment/', '/');
    final bool isImage =
        cleanUrl.endsWith('.jpg') ||
        cleanUrl.endsWith('.jpeg') ||
        cleanUrl.endsWith('.png') ||
        cleanUrl.endsWith('.webp');

    final String finalUrlToOpen = isImage
        ? cleanUrl
        : "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(cleanUrl)}";

    try {
      await launchUrl(Uri.parse(finalUrlToOpen), mode: LaunchMode.inAppBrowserView);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening attachment: $e")),
        );
      }
    }
  }

  // 📥 Attachment Download
  Future<void> _downloadAttachment(String urlString) async {
    if (urlString.isEmpty) return;
    final String cleanUrl = urlString.replaceAll('/fl_attachment/', '/');
    try {
      await launchUrl(Uri.parse(cleanUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading file: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor ?? const Color(0xFF3F51B5);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Manage Notices",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      // ➕ Floating Action Button (अघिल्लो screenshot २ खोल्न)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoticeManagementScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white, size: 22),
        label: const Text(
          "Add Notice",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      body: StreamBuilder<List<NoticeModel>>(
        stream: AdminNoticeService.getAdminNotices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No notices published yet.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final allNotices = snapshot.data!;
          final pinnedNotices = allNotices.where((n) => n.isPinned).toList();
          final recentNotices = allNotices.where((n) => !n.isPinned).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // 📌 Pinned Notices
              if (pinnedNotices.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.push_pin, size: 18, color: primaryColor),
                    const SizedBox(width: 6),
                    const Text(
                      "Pinned Notices",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pinnedNotices.map((notice) => _buildNoticeCard(notice)),
                const SizedBox(height: 20),
              ],

              // 📢 All Recent Updates
              const Text(
                "All Recent Updates",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),

              if (recentNotices.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "No other notices available.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...recentNotices.map((notice) => _buildNoticeCard(notice)),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  // 🎨 Custom UI Card
  Widget _buildNoticeCard(NoticeModel notice) {
    final bool hasAttachment =
        notice.attachmentUrl != null && notice.attachmentUrl!.isNotEmpty;
    final primaryColor = AppTheme.primaryColor ?? const Color(0xFF3F51B5);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notice.isPinned ? primaryColor : const Color(0xFFDCE4FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notice.isPinned
                      ? Icons.campaign_rounded
                      : Icons.notifications_none_rounded,
                  color: notice.isPinned ? Colors.white : primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notice.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (notice.isPinned) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.push_pin, size: 10, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  "PINNED",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notice.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                onSelected: (val) async {
                  if (val == 'view' && hasAttachment) {
                    _viewAttachment(notice.attachmentUrl!);
                  } else if (val == 'download' && hasAttachment) {
                    _downloadAttachment(notice.attachmentUrl!);
                  } else if (val == 'pin') {
                    await AdminNoticeService.togglePinNotice(notice.id, notice.isPinned);
                  } else if (val == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainDashboardScreen(existingNotice: notice),
                      ),
                    );
                  } else if (val == 'delete') {
                    await AdminNoticeService.deleteNotice(notice.id);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, color: hasAttachment ? primaryColor : Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text("View Attachment", style: TextStyle(color: hasAttachment ? Colors.black : Colors.grey)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.file_download_outlined, color: hasAttachment ? Colors.green : Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text("Download File", style: TextStyle(color: hasAttachment ? Colors.black : Colors.grey)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(
                      children: [
                        Icon(notice.isPinned ? Icons.push_pin_outlined : Icons.push_pin, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(notice.isPinned ? "Unpin Notice" : "Pin to Top"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text("Edit Details"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text("Delete"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 5),
              Text(
                "${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  "Audience: ${notice.targetAudience}",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../screens/pdf_viewer_screen.dart';

/// Read-only notice card for students. Same information as the teacher's
/// `NoticeTile`, minus the edit / delete / pin controls (those stay
/// teacher-only), and restyled to use [AppTheme] instead of hard-coded
/// colors. Tapping a PDF attachment opens it in-app; other file types
/// launch externally.
class NoticeTile extends StatelessWidget {
  final TeacherNoticeModel notice;
  final VoidCallback onTap;

  const NoticeTile({super.key, required this.notice, required this.onTap});

  bool get _isPdfAttachment {
    final name = (notice.attachmentName ?? '').toLowerCase();
    final url = (notice.attachmentUrl ?? '').toLowerCase();
    return name.endsWith('.pdf') || url.contains('.pdf');
  }

  void _openAttachment(BuildContext context) {
    final url = notice.attachmentUrl;
    if (url == null || url.isEmpty) return;

    if (_isPdfAttachment) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(pdfUrl: url, title: notice.title),
        ),
      );
    } else {
      launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Pinned Badge
              if (notice.isPinned)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin, color: AppTheme.primary, size: 16),
                      SizedBox(width: 5),
                      Text(
                        "Pinned",
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              /// Title
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              /// Description
              Text(
                notice.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),

              /// Attachment
              if (notice.attachmentName != null &&
                  notice.attachmentName!.isNotEmpty) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _openAttachment(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isPdfAttachment
                              ? Icons.picture_as_pdf
                              : Icons.attach_file,
                          color: _isPdfAttachment
                              ? Colors.redAccent
                              : AppTheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            notice.attachmentName!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                        Icon(
                          _isPdfAttachment
                              ? Icons.visibility
                              : Icons.open_in_new,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const Divider(height: 28, color: AppTheme.border),

              /// Bottom Row - posted by
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notice.teacherName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat(
                            "dd MMM yyyy • hh:mm a",
                          ).format(notice.createdAt),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

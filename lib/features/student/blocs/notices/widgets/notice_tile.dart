import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../screens/pdf_viewer_screen.dart';

/// Read-only notice card for students.
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin,
                          color: AppTheme.primary,
                          size: isSmallScreen ? 14 : 16,
                        ),
                        SizedBox(width: isSmallScreen ? 3 : 5),
                        Text(
                          "Pinned",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: isSmallScreen ? 8 : 12),

                /// Title
                Text(
                  notice.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isSmallScreen ? 6 : 8),

                /// Description
                Text(
                  notice.description,
                  maxLines: isSmallScreen ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                    fontSize: isSmallScreen ? 13 : (isTablet ? 16 : 14),
                  ),
                ),

                /// Attachment
                if (notice.attachmentName != null &&
                    notice.attachmentName!.isNotEmpty) ...[
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  InkWell(
                    onTap: () => _openAttachment(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        border: Border.all(
                          color: AppTheme.border.withValues(alpha: 0.5),
                        ),
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
                            size: isSmallScreen ? 18 : 22,
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 10),
                          Expanded(
                            child: Text(
                              notice.attachmentName!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: isSmallScreen
                                    ? 12
                                    : (isTablet ? 15 : 13),
                              ),
                            ),
                          ),
                          Icon(
                            _isPdfAttachment
                                ? Icons.visibility
                                : Icons.open_in_new,
                            size: isSmallScreen ? 16 : 18,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                Divider(
                  height: isSmallScreen ? 20 : 24,
                  color: AppTheme.border.withValues(alpha: 0.5),
                ),

                /// Bottom Row - posted by
                Row(
                  children: [
                    CircleAvatar(
                      radius: isSmallScreen ? 16 : (isTablet ? 22 : 18),
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primary,
                        size: isSmallScreen ? 18 : (isTablet ? 24 : 20),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.teacherName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                              fontSize: isSmallScreen
                                  ? 13
                                  : (isTablet ? 16 : 14),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            DateFormat(
                              "dd MMM yyyy • hh:mm a",
                            ).format(notice.createdAt),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: isSmallScreen
                                  ? 10
                                  : (isTablet ? 13 : 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status indicator if needed
                    if (notice.isPinned)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.push_pin,
                          size: isSmallScreen ? 12 : 14,
                          color: AppTheme.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

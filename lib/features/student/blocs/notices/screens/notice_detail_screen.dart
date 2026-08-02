import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dio/dio.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'pdf_viewer_screen.dart';

/// Student-facing detail view for a single notice.
class NoticeDetailScreen extends StatefulWidget {
  final TeacherNoticeModel notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  bool _downloading = false;

  bool get _isPdfAttachment {
    final notice = widget.notice;
    final name = (notice.attachmentName ?? '').toLowerCase();
    final url = (notice.attachmentUrl ?? '').toLowerCase();
    return name.endsWith('.pdf') || url.contains('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Notice",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 14 : (isTablet ? 24 : 18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PINNED BADGE
                if (notice.isPinned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha:0.08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin,
                          size: isSmallScreen ? 16 : 18,
                          color: AppTheme.primary,
                        ),
                        SizedBox(width: isSmallScreen ? 4 : 6),
                        Text(
                          "Pinned Notice",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                /// TITLE
                Text(
                  notice.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : (isTablet ? 32 : 26),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                /// Teacher Info Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.border.withValues(alpha:0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 22 : (isTablet ? 32 : 28),
                          backgroundColor: AppTheme.primary.withValues(alpha:0.1),
                          child: Icon(
                            Icons.person,
                            size: isSmallScreen ? 24 : (isTablet ? 34 : 30),
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notice.teacherName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen
                                      ? 15
                                      : (isTablet ? 19 : 17),
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  "dd MMM yyyy • hh:mm a",
                                ).format(notice.createdAt),
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: isSmallScreen
                                      ? 12
                                      : (isTablet ? 15 : 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 20 : 25),

                /// Notice Content Label
                Text(
                  "Notice",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 8 : 10),

                /// Notice Content Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.border.withValues(alpha:0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isSmallScreen ? 14 : (isTablet ? 22 : 18),
                    ),
                    child: Text(
                      notice.description,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                        height: 1.7,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 20 : 25),

                /// Attachment
                if (notice.attachmentUrl != null &&
                    notice.attachmentUrl!.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.border.withValues(alpha:0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isPdfAttachment
                              ? Colors.red.shade50
                              : AppTheme.primary.withValues(alpha:0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _isPdfAttachment
                              ? Icons.picture_as_pdf
                              : Icons.insert_drive_file,
                          color: _isPdfAttachment
                              ? Colors.red.shade600
                              : AppTheme.primary,
                          size: isSmallScreen ? 28 : (isTablet ? 38 : 32),
                        ),
                      ),
                      title: Text(
                        notice.attachmentName ?? "Attachment",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 13 : (isTablet ? 16 : 14),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _downloading
                            ? "Downloading..."
                            : _isPdfAttachment
                            ? "Tap to view"
                            : "Tap to open",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: isSmallScreen ? 11 : (isTablet ? 14 : 12),
                        ),
                      ),
                      trailing: _downloading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2.0,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha:0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPdfAttachment
                                    ? Icons.visibility
                                    : Icons.download,
                                color: AppTheme.primary,
                                size: isSmallScreen ? 18 : (isTablet ? 24 : 20),
                              ),
                            ),
                      onTap: () => _handleAttachmentTap(
                        notice.attachmentUrl!,
                        notice.attachmentName ?? "attachment",
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                SizedBox(height: isSmallScreen ? 30 : 35),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleAttachmentTap(String url, String fileName) {
    if (_isPdfAttachment) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PdfViewerScreen(pdfUrl: url, title: widget.notice.title),
        ),
      );
      return;
    }

    _downloadAndOpenExternally(url, fileName);
  }

  Future<void> _downloadAndOpenExternally(String url, String fileName) async {
    setState(() => _downloading = true);

    try {
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/$fileName";
      await Dio().download(url, filePath);
      await OpenFilex.open(filePath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to open attachment: $e"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }
}

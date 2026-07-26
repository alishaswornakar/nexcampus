import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/notice_model.dart';
import 'pdf_viewer_screen.dart';

/// Student-facing detail view for a single notice.
///
/// PDF attachments open in-app via [PdfViewerScreen] (flutter_pdfview).
/// Non-PDF attachments (docx, pptx, images, ...) fall back to downloading
/// the file and opening it with whatever app the device has installed for
/// that file type, since there's no in-app renderer for those formats here.
class NoticeDetailScreen extends StatefulWidget {
  final NoticeModel notice;

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

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text("Notice"),
        centerTitle: true,
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

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
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.push_pin, size: 18, color: AppTheme.secondary),
                    SizedBox(width: 6),
                    Text(
                      "Pinned Notice",
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              notice.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.background,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              color: AppTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: AppTheme.primary,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.teacherName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: AppTheme.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            DateFormat(
                              "dd MMM yyyy • hh:mm a",
                            ).format(notice.createdAt),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Notice",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 2,
              color: AppTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  notice.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (notice.attachmentUrl != null &&
                notice.attachmentUrl!.isNotEmpty)
              Card(
                elevation: 2,
                color: AppTheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.border),
                ),
                child: ListTile(
                  leading: Icon(
                    _isPdfAttachment
                        ? Icons.picture_as_pdf
                        : Icons.insert_drive_file,
                    color: _isPdfAttachment ? Colors.red : AppTheme.primary,
                    size: 35,
                  ),

                  title: Text(
                    notice.attachmentName ?? "Attachment",
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),

                  subtitle: Text(
                    _downloading
                        ? "Downloading..."
                        : _isPdfAttachment
                        ? "Tap to view"
                        : "Tap to open",
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),

                  trailing: _downloading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _isPdfAttachment ? Icons.visibility : Icons.download,
                          color: AppTheme.primary,
                        ),

                  onTap: () => _handleAttachmentTap(
                    notice.attachmentUrl!,
                    notice.attachmentName ?? "attachment",
                  ),
                ),
              ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  void _handleAttachmentTap(String url, String fileName) {
    if (_isPdfAttachment) {
      // Viewed in-app — no download/open_filex round trip needed here,
      // PdfViewerScreen handles fetching + caching the file itself.
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to open attachment: $e")));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }
}

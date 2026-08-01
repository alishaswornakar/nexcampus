import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';

class NoteTile extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  IconData _fileIcon(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith(".pdf")) return Icons.picture_as_pdf;
    if (name.endsWith(".doc") || name.endsWith(".docx")) {
      return Icons.description;
    }
    if (name.endsWith(".ppt") || name.endsWith(".pptx")) {
      return Icons.slideshow;
    }
    if (name.endsWith(".jpg") ||
        name.endsWith(".jpeg") ||
        name.endsWith(".png")) {
      return Icons.image;
    }

    return Icons.insert_drive_file;
  }

  Color _iconColor(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith(".pdf")) return Colors.red;
    if (name.endsWith(".ppt") || name.endsWith(".pptx")) {
      return AppTheme.primary;
    }
    if (name.endsWith(".doc") || name.endsWith(".docx")) {
      return AppTheme.primary;
    }
    if (name.endsWith(".jpg") ||
        name.endsWith(".jpeg") ||
        name.endsWith(".png")) {
      return AppTheme.primary;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width >= 600;
    final bool isDesktop = width >= 1000;

    final padding = isDesktop
        ? 22.0
        : isTablet
        ? 20.0
        : 16.0;

    final avatarRadius = isDesktop
        ? 30.0
        : isTablet
        ? 28.0
        : 24.0;

    final titleSize = isDesktop
        ? 19.0
        : isTablet
        ? 18.0
        : 16.0;

    final bodySize = isDesktop
        ? 15.0
        : isTablet
        ? 14.0
        : 13.0;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: isTablet ? 18 : 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: _iconColor(
                      note.fileName,
                    ).withValues(alpha: .12),
                    child: Icon(
                      _fileIcon(note.fileName),
                      color: _iconColor(note.fileName),
                      size: avatarRadius,
                    ),
                  ),

                  SizedBox(width: isTablet ? 16 : 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          note.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: bodySize,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "delete") {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 18 : 14),

              /// File Name
              Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: AppTheme.primary),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        note.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: bodySize),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 16 : 14),

              /// Footer
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        note.uploadedBy,
                        style: TextStyle(fontSize: bodySize),
                      ),
                    ],
                  ),

                  Text(
                    DateFormat("dd MMM yyyy").format(note.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: bodySize,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 20 : 16),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: isTablet ? 46 : 42,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 22 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.visibility),
                    label: Text(
                      "View",
                      style: TextStyle(
                        fontSize: bodySize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

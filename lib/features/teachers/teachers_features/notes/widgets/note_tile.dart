import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    if (name.endsWith(".pdf")) {
      return Icons.picture_as_pdf;
    }

    if (name.endsWith(".doc") ||
        name.endsWith(".docx")) {
      return Icons.description;
    }

    if (name.endsWith(".ppt") ||
        name.endsWith(".pptx")) {
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

    if (name.endsWith(".pdf")) {
      return Colors.red;
    }

    if (name.endsWith(".ppt") ||
        name.endsWith(".pptx")) {
      return Colors.orange;
    }

    if (name.endsWith(".doc") ||
        name.endsWith(".docx")) {
      return Colors.blue;
    }

    if (name.endsWith(".jpg") ||
        name.endsWith(".jpeg") ||
        name.endsWith(".png")) {
      return Colors.green;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        _iconColor(note.fileName)
                            // ignore: deprecated_member_use
                            .withOpacity(.12),
                    child: Icon(
                      _fileIcon(note.fileName),
                      color:
                          _iconColor(note.fileName),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          note.description,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors
                                .grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "delete") {
                        onDelete();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file,
                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        note.fileName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      note.uploadedBy,
                    ),
                  ),

                  Text(
                    DateFormat(
                      "dd MMM yyyy",
                    ).format(note.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor:
                        Colors.white,
                  ),
                  icon: const Icon(
                    Icons.visibility,
                  ),
                  label: const Text("View"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
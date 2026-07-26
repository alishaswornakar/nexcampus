import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/notice_model.dart';

class NoticeTile extends StatelessWidget {
  final TeacherNoticeModel notice;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onTap;

  const NoticeTile({
    super.key,
    required this.notice,
    required this.onEdit,
    required this.onDelete,
    required this.onPin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              /// Top Row
              Row(
                children: [

                  if (notice.isPinned)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.push_pin,
                            color: Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Pinned",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case "edit":
                          onEdit();
                          break;

                        case "delete":
                          onDelete();
                          break;

                        case "pin":
                          onPin();
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      PopupMenuItem(
                        value: "pin",
                        child: Text(
                          notice.isPinned
                              ? "Unpin"
                              : "Pin",
                        ),
                      ),
                      const PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Title
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// Description
              Text(
                notice.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 18),

         const SizedBox(height: 16),

Row(
  children: [
    const Icon(
      Icons.person,
      color: Colors.blue,
      size: 18,
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        "Posted by ${notice.teacherName}",
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ],
),
             if (notice.attachmentName != null &&
    notice.attachmentName!.isNotEmpty) ...[
  const SizedBox(height: 12),

  InkWell(
    onTap: () => launchUrl(
      Uri.parse(notice.attachmentUrl!),
    ),
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              notice.attachmentName!,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Icon(
            Icons.open_in_new,
            size: 18,
          ),
        ],
      ),
    ),
  ),
],
 const Divider(height: 28),

              /// Bottom Row
              Row(
                children: [

                  const CircleAvatar(
                    radius: 18,
                    child: Icon(
                      Icons.person,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          notice.teacherName,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
                          DateFormat(
                            "dd MMM yyyy • hh:mm a",
                          ).format(
                            notice.createdAt,
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade600,
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/notice_model.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class NoticeDetailScreen extends StatefulWidget {
  final NoticeModel notice;

  const NoticeDetailScreen({
    super.key,
    required this.notice,
  });

  @override
  State<NoticeDetailScreen> createState() =>
      _NoticeDetailScreenState();
}

class _NoticeDetailScreenState
    extends State<NoticeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("Notice"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// PINNED BADGE
            if (notice.isPinned)
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Pinned Notice",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight:
                            FontWeight.bold,
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Row(
                  children: [

                    const CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.person,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            notice.teacherName,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            DateFormat(
                              "dd MMM yyyy • hh:mm a",
                            ).format(
                              notice.createdAt,
                            ),
                            style: TextStyle(
                              color: Colors
                                  .grey.shade600,
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
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(18),
                child: Text(
                  notice.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

          if (notice.attachmentUrl != null &&
    notice.attachmentUrl!.isNotEmpty)

Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),

  child: ListTile(

    leading: const Icon(
      Icons.picture_as_pdf,
      color: Colors.red,
      size: 35,
    ),

    title: Text(
      notice.attachmentName ?? "PDF",
    ),

    subtitle: const Text(
      "Tap to open PDF",
    ),

    trailing: IconButton(
      icon: const Icon(
        Icons.download,
      ),

      onPressed: () {

        openPDF(
          notice.attachmentUrl!,
        );

      },
    ),


    onTap: () {

      openPDF(
        notice.attachmentUrl!,
      );

    },

  ),
),

            const SizedBox(height: 35),

            // Teacher actions will come here in Part 2
          ],
        ),
      ),
    );
  }
  Future<void> openPDF(String url) async {

  try {

    final dir = await getTemporaryDirectory();

    final filePath =
        "${dir.path}/${widget.notice.attachmentName}";


    await Dio().download(
      url,
      filePath,
    );


    await OpenFilex.open(filePath);


  } catch (e) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text("Failed to open PDF: $e"),
      ),
    );

  }
}
}
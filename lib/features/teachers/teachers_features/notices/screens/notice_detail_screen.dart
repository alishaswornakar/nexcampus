import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/notice_model.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class NoticeDetailScreen extends StatefulWidget {
  final TeacherNoticeModel notice;

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

    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet =
        width >= 600 && width < 1000;
    final isDesktop = width >= 1000;

    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
            ? 24.0
            : 36.0;

    final maxWidth =
        isDesktop ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Notice",
          style: TextStyle(
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                /// PINNED
                if (notice.isPinned)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin,
                          color: Colors.orange,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Pinned Notice",
                          style: TextStyle(
                            color:
                                AppTheme.primary,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                    height:
                        isMobile ? 20 : 28),

                /// TITLE
                Text(
                  notice.title,
                  style: TextStyle(
                    fontSize:
                        isMobile ? 24 : 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(
                    height:
                        isMobile ? 18 : 24),

                /// TEACHER CARD
                Card(
                  elevation: 2,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(18),
                    child: Row(
                      children: [

                        CircleAvatar(
                          radius:
                              isMobile
                                  ? 24
                                  : 28,
                          backgroundColor:
                              AppTheme.primary,
                          foregroundColor:
                              Colors.white,
                          child: Icon(
                            Icons.person,
                            size: isMobile
                                ? 24
                                : 28,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                notice.teacherName,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize:
                                      isMobile
                                          ? 16
                                          : 18,
                                ),
                              ),

                              const SizedBox(
                                  height: 4),

                              Text(
                                DateFormat(
                                  "dd MMM yyyy • hh:mm a",
                                ).format(
                                    notice.createdAt),
                                style:
                                    TextStyle(
                                  fontSize:
                                      isMobile
                                          ? 13
                                          : 14,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                    height:
                        isMobile ? 24 : 30),

                Text(
                  "Notice",
                  style: TextStyle(
                    fontSize:
                        isMobile ? 18 : 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// DESCRIPTION
                Card(
                  elevation: 2,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(18),
                    child: Text(
                      notice.description,
                      style: TextStyle(
                        fontSize:
                            isMobile
                                ? 15
                                : 17,
                        height: 1.7,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                    height:
                        isMobile ? 24 : 30),

                /// ATTACHMENT
                if (notice.attachmentUrl != null &&
                    notice
                        .attachmentUrl!.isNotEmpty)
                  Card(
                    elevation: 2,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 36,
                      ),

                      title: Text(
                        notice.attachmentName ??
                            "Attachment",
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),

                      subtitle: const Text(
                        "Tap to open attachment",
                      ),

                      trailing: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color:
                              AppTheme.primary,
                        ),
                        onPressed: () {
                          openPDF(
                            notice
                                .attachmentUrl!,
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

                SizedBox(
                    height:
                        isMobile ? 30 : 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openPDF(String url) async {
    try {
      final dir =
          await getTemporaryDirectory();

      final filePath =
          "${dir.path}/${widget.notice.attachmentName}";

      await Dio().download(
        url,
        filePath,
      );

      await OpenFilex.open(filePath);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to open attachment: $e",
          ),
        ),
      );
    }
  }
}
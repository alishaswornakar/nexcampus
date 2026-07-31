import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';


import '../model/note_model.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  Future<void> _downloadFile(BuildContext context) async {
    final uri = Uri.parse(note.fileUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to open download link."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width >= 600;
    final bool isDesktop = width >= 1000;

    final horizontalPadding = isDesktop
        ? 80.0
        : isTablet
            ? 40.0
            : 18.0;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Note Details"),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 850 : double.infinity,
          ),

          child: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                Card(
                  elevation: 2,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Padding(
                    padding: EdgeInsets.all(
                      isTablet ? 24 : 18,
                    ),

                    child: Column(
                      children: [

                        CircleAvatar(
                          radius: isTablet ? 38 : 32,
                          backgroundColor: Colors.blue.shade100,

                          child: const Icon(
                            Icons.menu_book,
                            color: AppTheme.primary,
                            size: 32,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          note.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 24 : 20,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          note.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.grey.shade700,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 2,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Column(
                    children: [

                      ListTile(
                        leading: const Icon(
                          Icons.insert_drive_file,
                          color: AppTheme.primary,
                        ),

                        title: const Text("File Name"),

                        subtitle: Text(
                          note.fileName,
                        ),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: AppTheme.primary,
                        ),

                        title: const Text("Uploaded By"),

                        subtitle: Text(
                          note.uploadedBy,
                        ),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.calendar_today,
                          color: AppTheme.primary,
                        ),

                        title: const Text("Uploaded On"),

                        subtitle: Text(
                          DateFormat(
                            "dd MMM yyyy • hh:mm a",
                          ).format(
                            note.createdAt,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 30),
                                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 60 : 55,

                  child: ElevatedButton.icon(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: AppTheme.primary,

                      foregroundColor: Colors.white,

                      elevation: 2,

                      shape: RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(14),

                      ),

                    ),

                    icon: const Icon(
                      Icons.picture_as_pdf,
                    ),

                    label: const Text(
                      "View PDF",
                    ),

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) => PdfViewerScreen(

                            pdfUrl: note.fileUrl,

                            title: note.title,

                          ),

                        ),

                      );

                    },

                  ),

                ),

                const SizedBox(height: 16),

                SizedBox(

                  width: double.infinity,

                  height: isTablet ? 60 : 55,

                  child: OutlinedButton.icon(

                    style: OutlinedButton.styleFrom(

                      foregroundColor: AppTheme.primary,

                      side: const BorderSide(

                        color: AppTheme.primary,

                      ),

                      shape: RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(14),

                      ),

                    ),

                    icon: const Icon(
                      Icons.download,
                    ),

                    label: const Text(
                      "Download File",
                    ),

                    onPressed: () => _downloadFile(context),

                  ),

                ),

                const SizedBox(height: 20),

              ],

            ),

          ),

        ),

      ),

    );

  }

}
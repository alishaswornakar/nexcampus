import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../models/notice_model.dart';
import '../services/admin_notice_service.dart';

class NoticeManagementScreen extends StatefulWidget {
  const NoticeManagementScreen({super.key});

  @override
  State<NoticeManagementScreen> createState() => _NoticeManagementScreenState();
}

class _NoticeManagementScreenState extends State<NoticeManagementScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  // 👁️ View Attachment Fix
  Future<void> _viewAttachment(String urlString) async {
    if (urlString.isEmpty) return;

    // Clean URL (कुनै नचाहिने transformation छ भने हटाउने)
    final String cleanUrl = urlString.replaceAll('/fl_attachment/', '/');

    // Photo वा Image file भए सोझै खोल्ने, PDF भए Google Docs Viewer प्रयोग गर्ने
    final bool isImage =
        cleanUrl.endsWith('.jpg') ||
        cleanUrl.endsWith('.jpeg') ||
        cleanUrl.endsWith('.png') ||
        cleanUrl.endsWith('.webp');

    final String finalUrlToOpen = isImage
        ? cleanUrl
        : "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(cleanUrl)}";

    final Uri url = Uri.parse(finalUrlToOpen);

    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView, // In-App Web browser मा View गर्ने
      );

      if (!launched) {
        await launchUrl(
          Uri.parse(cleanUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error viewing attachment: $e")));
      }
    }
  }

  // 📥 Download Attachment Fix
  Future<void> _downloadAttachment(String urlString) async {
    if (urlString.isEmpty) return;

    // Direct Clean Link External Browser (Chrome/Safari) मा पठाई डाउन्लोड गराउने
    final String cleanUrl = urlString.replaceAll('/fl_attachment/', '/');
    final Uri url = Uri.parse(cleanUrl);

    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Device Browser मा खोल्ने
      );

      if (launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening in browser to download...")),
        );
      } else if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not launch browser for download"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening download link: $e")),
        );
      }
    }
  }

  // 📸 Camera / Gallery / File Picker Sheet
  Future<void> _showAttachmentPickerSheet({
    required Function(File file, String name) onFilePicked,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Choose Attachment Source",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2FE),
                  child: Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text("Take Photo (Camera)"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (photo != null) {
                    onFilePicked(File(photo.path), photo.name);
                  }
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFEF3C7),
                  child: Icon(Icons.photo_library, color: Colors.amber),
                ),
                title: const Text("Gallery Image"),
                onTap: () async {
                  Navigator.pop(ctx);
                  final image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    onFilePicked(File(image.path), image.name);
                  }
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.attach_file, color: Colors.green),
                ),
                title: const Text("Document / File (PDF, DOC...)"),
                onTap: () async {
                  Navigator.pop(ctx);
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles();
                  if (result != null && result.files.single.path != null) {
                    onFilePicked(
                      File(result.files.single.path!),
                      result.files.single.name,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 📝 Publish / Edit Notice Dialog
  void _showNoticeDialog({NoticeModel? existingNotice}) {
    final titleController = TextEditingController(
      text: existingNotice?.title ?? '',
    );
    final descController = TextEditingController(
      text: existingNotice?.description ?? '',
    );
    String selectedAudience = existingNotice?.targetAudience ?? 'All';
    bool isPinned = existingNotice?.isPinned ?? false;

    File? attachedFile;
    String? attachedFileName;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                existingNotice == null ? "Publish New Notice" : "Edit Notice",
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Notice Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description / Details",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedAudience,
                      decoration: const InputDecoration(
                        labelText: "Target Audience",
                        border: OutlineInputBorder(),
                      ),
                      items: ['All', 'Students', 'Teachers']
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedAudience = val!),
                    ),
                    const SizedBox(height: 12),

                    // 📌 Pin Option Checkbox
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Pin this Notice to Top 📌",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: isPinned,
                      onChanged: (val) =>
                          setDialogState(() => isPinned = val ?? false),
                    ),
                    const SizedBox(height: 8),

                    // 📷 Attachment Picker
                    if (existingNotice == null) ...[
                      InkWell(
                        onTap: isSaving
                            ? null
                            : () {
                                _showAttachmentPickerSheet(
                                  onFilePicked: (file, name) {
                                    setDialogState(() {
                                      attachedFile = file;
                                      attachedFileName = name;
                                    });
                                  },
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.shade50,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  attachedFileName ??
                                      "Attach Photo (Camera/Gallery) or File...",
                                  style: TextStyle(
                                    color: attachedFileName == null
                                        ? Colors.grey.shade700
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: attachedFileName == null
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (isSaving)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a notice title"),
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);

                          try {
                            String? fileUrl = existingNotice?.attachmentUrl;
                            if (attachedFile != null) {
                              fileUrl =
                                  await AdminNoticeService.uploadNoticeAttachment(
                                    attachedFile!,
                                  );
                            }

                            if (existingNotice == null) {
                              final notice = NoticeModel(
                                id: '',
                                title: titleController.text.trim(),
                                description: descController.text.trim(),
                                targetAudience: selectedAudience,
                                attachmentUrl: fileUrl,
                                postedBy: 'Admin',
                                isPinned: isPinned,
                                createdAt: DateTime.now(),
                              );
                              await AdminNoticeService.addNotice(notice);
                            } else {
                              await AdminNoticeService.updateNotice(
                                existingNotice.id,
                                titleController.text.trim(),
                                descController.text.trim(),
                                selectedAudience,
                              );
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                  child: const Text("Publish"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text(
          "Manage Notices",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor ?? Colors.blue,
        onPressed: () => _showNoticeDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<NoticeModel>>(
        stream: AdminNoticeService.getAdminNotices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notices published yet."));
          }

          final notices = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              final bool hasAttachment =
                  notice.attachmentUrl != null &&
                  notice.attachmentUrl!.isNotEmpty;

              return Card(
                elevation: notice.isPinned ? 3 : 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: notice.isPinned
                      ? const BorderSide(color: Colors.orange, width: 1.5)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: notice.isPinned
                            ? Colors.orange.shade50
                            : const Color(0xFFE0F2FE),
                        child: Icon(
                          notice.isPinned ? Icons.push_pin : Icons.campaign,
                          color: notice.isPinned ? Colors.orange : Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notice.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (notice.isPinned)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "Pinned 📌",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notice.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Audience: ${notice.targetAudience} | Date: ${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (val) async {
                          if (val == 'view') {
                            if (hasAttachment) {
                              _viewAttachment(notice.attachmentUrl!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No attachment available."),
                                ),
                              );
                            }
                          } else if (val == 'download') {
                            if (hasAttachment) {
                              _downloadAttachment(notice.attachmentUrl!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No attachment available."),
                                ),
                              );
                            }
                          } else if (val == 'pin') {
                            await AdminNoticeService.togglePinNotice(
                              notice.id,
                              notice.isPinned,
                            );
                          } else if (val == 'edit') {
                            _showNoticeDialog(existingNotice: notice);
                          } else if (val == 'delete') {
                            await AdminNoticeService.deleteNotice(notice.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  color: hasAttachment
                                      ? Colors.blue
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "View Attachment",
                                  style: TextStyle(
                                    color: hasAttachment
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.file_download_outlined,
                                  color: hasAttachment
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Download File",
                                  style: TextStyle(
                                    color: hasAttachment
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  notice.isPinned
                                      ? Icons.push_pin_outlined
                                      : Icons.push_pin,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  notice.isPinned
                                      ? "Unpin Notice"
                                      : "Pin to Top",
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text("Edit Details"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}

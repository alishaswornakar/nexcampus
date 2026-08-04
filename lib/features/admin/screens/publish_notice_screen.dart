import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart'; // ✅ Cloudinary Service इम्पोर्ट गरिएको छ

class PublishNoticeScreen extends StatefulWidget {
  const PublishNoticeScreen({super.key});

  @override
  State<PublishNoticeScreen> createState() => _PublishNoticeScreenState();
}

class _PublishNoticeScreenState extends State<PublishNoticeScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedAudience = 'All';
  bool _isPinned = false;
  File? _attachmentFile;
  String? _attachmentName;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAttachment() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text("Attach Document or Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text("Pick Image from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() {
                    _attachmentFile = File(picked.path);
                    _attachmentName = picked.name;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.green),
              title: const Text("Pick PDF / Document"),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx', 'jpeg'],
                );
                if (result != null && result.files.single.path != null) {
                  setState(() {
                    _attachmentFile = File(result.files.single.path!);
                    _attachmentName = result.files.single.name;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishNotice() async {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String downloadUrl = '';

      // ✅ यदि फाइल छ भने Cloudinary मा अपलोड गर्ने
      if (_attachmentFile != null) {
        final url = await CloudinaryService.uploadFile(_attachmentFile!);
        if (url != null) {
          downloadUrl = url;
        } else {
          throw "Failed to upload file to Cloudinary.";
        }
      }

      // Firestore मा डाटा सेभ गर्ने
      await FirebaseFirestore.instance.collection('notices').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'audience': _selectedAudience,
        'isPinned': _isPinned,
        'fileName': _attachmentName ?? '',
        'fileUrl': downloadUrl, // ✅ Cloudinary को वास्तविक URL यहाँ बस्छ
        'date': "28/7/2026",
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Publish Notice',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create New Broadcast",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            Text(
              "Fill in the details below to notify the NexCampus community.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            const Text("Notice Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "e.g., Final Year Exam Schedule",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Description / Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Provide complete information about the notice...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Target Audience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedAudience,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              items: ['All', 'Computer', 'Civil', 'Architecture']
                  .map((aud) => DropdownMenuItem(value: aud, child: Text(aud)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedAudience = val!),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.push_pin_outlined, size: 20, color: Color(0xFF3B52D4)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("Pin to Top", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Switch(
                    value: _isPinned,
                    activeColor: const Color(0xFF3B52D4),
                    onChanged: (val) => setState(() => _isPinned = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("Attachment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickAttachment,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 36, color: Color(0xFF3B52D4)),
                    const SizedBox(height: 8),
                    Text(
                      _attachmentName ?? "Attach Photo or File",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _attachmentName == null ? const Color(0xFF1E293B) : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "PDF, JPG, PNG up to 10MB",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B52D4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _publishNotice,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text("Publish Notice", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Color(0xFF3B52D4), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
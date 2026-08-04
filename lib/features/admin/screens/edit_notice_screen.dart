import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../services/cloudinary_service.dart';

class EditNoticeScreen extends StatefulWidget {
  final String docId;
  final String currentTitle;
  final String currentDesc;
  final String currentAudience;
  final String currentFileUrl;
  final String currentFileName;

  const EditNoticeScreen({
    super.key,
    required this.docId,
    required this.currentTitle,
    required this.currentDesc,
    required this.currentAudience,
    required this.currentFileUrl,
    required this.currentFileName,
  });

  @override
  State<EditNoticeScreen> createState() => _EditNoticeScreenState();
}

class _EditNoticeScreenState extends State<EditNoticeScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedAudience;
  bool _isLoading = false;
  File? _newFile;
  late String _fileName;
  late String _fileUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _descController = TextEditingController(text: widget.currentDesc);
    _selectedAudience = widget.currentAudience;
    _fileName = widget.currentFileName;
    _fileUrl = widget.currentFileUrl;
  }

  Future<void> _updateNotice() async {
    setState(() => _isLoading = true);
    try {
      if (_newFile != null) {
        final uploadedUrl = await CloudinaryService.uploadFile(_newFile!);
        if (uploadedUrl != null) {
          _fileUrl = uploadedUrl;
        }
      }

      await FirebaseFirestore.instance.collection('notices').doc(widget.docId).update({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'audience': _selectedAudience,
        'fileName': _fileName,
        'fileUrl': _fileUrl,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notice updated successfully!")),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Notice")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            const SizedBox(height: 12),
            TextField(controller: _descController, maxLines: 4, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedAudience,
              items: ['All', 'Computer', 'Civil', 'Architecture']
                  .map((aud) => DropdownMenuItem(value: aud, child: Text(aud)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedAudience = val!),
              decoration: const InputDecoration(labelText: "Audience"),
            ),
            const SizedBox(height: 20),
            Text("Current File: $_fileName"),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.single.path != null) {
                  setState(() {
                    _newFile = File(result.files.single.path!);
                    _fileName = result.files.single.name;
                  });
                }
              },
              child: const Text("Change Attachment"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateNotice,
              child: _isLoading ? const CircularProgressIndicator() : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
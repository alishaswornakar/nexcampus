import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/admin/models/report_model.dart';
import 'package:nexcampus_app/features/admin/services/report_service.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

/// Lets a logged-in student create a new report that will show up
/// instantly for admins in ReportMonitoringScreen (both read/write the
/// same `reports` collection through ReportService).
class SubmitReportScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const SubmitReportScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reportService = ReportService();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final report = ReportModel(
        id: '', // ignored by ReportService.submitReport; Firestore assigns it
        studentId: widget.studentId,
        studentName: widget.studentName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: 'Pending',
        adminFeedback: '',
        createdAt: DateTime.now(),
      );

      await _reportService.submitReport(report);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit report: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text(
          'Submit a Report',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please describe the issue'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

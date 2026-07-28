import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportMonitoringScreen extends StatelessWidget {
  final ReportService _reportService = ReportService();

  ReportMonitoringScreen({super.key});

  void _showFeedbackDialog(BuildContext context, ReportModel report) {
    final feedbackController = TextEditingController(text: report.adminFeedback);
    String selectedStatus = report.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Update Status: ${report.studentName}"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['Pending', 'In Progress', 'Resolved', 'Rejected']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedStatus = val);
                    },
                    decoration: const InputDecoration(labelText: "Status"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Admin Feedback/Remarks",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _reportService.updateReportFeedback(
                    report.id,
                    selectedStatus,
                    feedbackController.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save Updates"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Monitoring")),
      body: StreamBuilder<List<ReportModel>>(
        stream: _reportService.getAllReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text("No reports submitted yet."));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("From: ${report.studentName}"),
                      Text("Desc: ${report.description}"),
                      const SizedBox(height: 4),
                      Text(
                        "Feedback: ${report.adminFeedback.isEmpty ? 'No feedback yet' : report.adminFeedback}",
                        style: const TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(report.status),
                    backgroundColor: report.status == 'Resolved'
                        ? Colors.green.shade100
                        : report.status == 'In Progress'
                            ? Colors.orange.shade100
                            : Colors.grey.shade200,
                  ),
                  onTap: () => _showFeedbackDialog(context, report),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
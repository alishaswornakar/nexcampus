import 'package:flutter/material.dart';
import '../../admin/models/report_model.dart';
import '../../admin/services/report_service.dart';

class MyReportsScreen extends StatelessWidget {
  final String studentId;
  final ReportService _reportService = ReportService();

  MyReportsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Submitted Reports")),
      body: StreamBuilder<List<ReportModel>>(
        stream: _reportService.getStudentReports(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text("You haven't submitted any reports."));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(report.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Chip(label: Text(report.status)),
                        ],
                      ),
                      Text(report.description),
                      const Divider(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Admin Response: ${report.adminFeedback.isEmpty ? 'Awaiting response...' : report.adminFeedback}",
                          style: TextStyle(
                            color: report.adminFeedback.isEmpty ? Colors.grey : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
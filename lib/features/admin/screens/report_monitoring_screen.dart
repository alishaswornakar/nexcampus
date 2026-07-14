import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class ReportMonitoringScreen extends StatelessWidget {
  const ReportMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Monitoring"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildReportTile(
              title: "Attendance Report",
              subtitle: "Track daily presence log",
              icon: Icons.co_present,
            ),
            _buildReportTile(
              title: "Assignment Report",
              subtitle: "Check ongoing submissions",
              icon: Icons.assignment,
            ),
            _buildReportTile(
              title: "Analytics",
              subtitle: "View system usage and metrics",
              icon: Icons.bar_chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

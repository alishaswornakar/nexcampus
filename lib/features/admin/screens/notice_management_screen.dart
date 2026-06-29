import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class NoticeManagementScreen extends StatelessWidget {
  const NoticeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notice Management"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildActionCard(title: "Add Notice", icon: Icons.add_circle, color: Colors.green, onTap: () {}),
            _buildActionCard(title: "Edit Notice", icon: Icons.edit, color: Colors.blue, onTap: () {}),
            _buildActionCard(title: "Delete Notice", icon: Icons.delete, color: Colors.red, onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
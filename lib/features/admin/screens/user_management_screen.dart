import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("User Management"),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(icon: Icon(Icons.school), text: "Students"),
              Tab(icon: Icon(Icons.person), text: "Teachers"),
              Tab(icon: Icon(Icons.admin_panel_settings), text: "Admins"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList("student"),
            _buildUserList("teacher"),
            _buildAdminProfileView(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(String role) {
    return Center(
      child: Text("List of all $role records will flow here real-time."),
    );
  }

  Widget _buildAdminProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(radius: 50, backgroundColor: AppTheme.primaryColor, child: const Icon(Icons.admin_panel_settings, size: 50, color: Colors.black)),
          const SizedBox(height: 20),
          const ListTile(leading: Icon(Icons.email), title: Text("admin@nexcampus.com"), subtitle: Text("Email Address")),
          const ListTile(leading: Icon(Icons.verified_user), title: Text("Super Admin"), subtitle: Text("Role")),
        ],
      ),
    );
  }
}
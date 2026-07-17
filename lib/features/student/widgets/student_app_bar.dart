import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/authentication/services/auth_service.dart';
import 'package:nexcampus_app/features/authentication/services/auth_wrapper.dart';

class StudentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StudentAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      title: const Text(
        "NexCampus",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          child: Image.asset("assets/images/mbman_app_icon.png"),
        ),
      ),
      actions: [
        const Icon(Icons.notifications_none, color: Colors.white),

        const SizedBox(width: 10),

        const Icon(Icons.mail_outline, color: Colors.white),

        const SizedBox(width: 10),

        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await AuthService().signOut();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}

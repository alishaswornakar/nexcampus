import 'package:flutter/material.dart';
import 'profile_menu_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';

class LogoutTile extends StatelessWidget {
  final VoidCallback? onLogout;

  const LogoutTile({super.key, this.onLogout});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    debugPrint('Logout confirmed: $confirmed'); // Debug print

    if (confirmed == true) {
      debugPrint('Calling onLogout callback...'); // Debug print
      if (onLogout != null) {
        onLogout!.call();
      } else {
        debugPrint('onLogout is null!'); // Debug print
        // Fallback: Try to sign out directly
        try {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        } catch (e) {
          debugPrint('Fallback logout error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ProfileMenuTile(
        icon: Icons.logout,
        title: 'Log Out',
        iconColor: Colors.red,
        onTap: () => _confirmLogout(context),
      ),
    );
  }
}

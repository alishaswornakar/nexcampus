import 'package:flutter/material.dart';
import 'profile_menu_tile.dart';

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
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onLogout?.call();
      // TODO: Hook into your AuthBloc, e.g.:
      // context.read<AuthBloc>().add(AuthLogoutRequested());
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
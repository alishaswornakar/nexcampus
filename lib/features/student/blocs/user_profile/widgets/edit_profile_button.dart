import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';

class EditProfileButton extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback? onPressed;

  const EditProfileButton({
    super.key,
    required this.profile,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed ??
            () {
              // TODO: Navigate to edit profile screen, passing `profile`
            },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Edit Profile'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

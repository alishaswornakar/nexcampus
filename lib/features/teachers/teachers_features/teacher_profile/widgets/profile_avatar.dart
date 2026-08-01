import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    required this.imageFile,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double avatarRadius = isMobile
        ? 60
        : isTablet
            ? 70
            : 80;

    final double personIconSize = isMobile
        ? 60
        : isTablet
            ? 70
            : 80;

    final double cameraIconSize = isMobile
        ? 18
        : 22;

    final double cameraPadding = isMobile
        ? 8
        : 10;

    ImageProvider? provider;

    if (imageFile != null) {
      provider = FileImage(imageFile!);
    } else if (imageUrl != null &&
        imageUrl!.isNotEmpty) {
      provider = NetworkImage(imageUrl!);
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          /// Profile Image
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: provider,
            child: provider == null
                ? Icon(
                    Icons.person,
                    size: personIconSize,
                    color: AppTheme.primary,
                  )
                : null,
          ),

          /// Camera Button
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(30),
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.all(
                      cameraPadding),
                  decoration:
                      BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.15),
                        blurRadius: 8,
                        offset:
                            const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: cameraIconSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
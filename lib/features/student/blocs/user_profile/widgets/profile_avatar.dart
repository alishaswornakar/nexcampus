import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';

/// Circular profile avatar with an optional camera icon (Google Pay style)
/// that lets the user pick a new photo from camera or gallery and upload
/// it via [UserProfileBloc].
class ProfileAvatar extends StatefulWidget {
  final String uid;
  final String? photoUrl;
  final String fullName;
  final double radius;

  /// Whether the camera icon / upload affordance is shown at all.
  /// Set to false if this avatar is displayed read-only elsewhere
  /// (e.g. in a list of other students).
  final bool editable;

  const ProfileAvatar({
    super.key,
    required this.uid,
    required this.photoUrl,
    required this.fullName,
    this.radius = 44,
    this.editable = true,
  });

  String get _initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceSheet(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.lightBlue),
                title: const Text('Camera'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.lightBlue,
                ),
                title: const Text('Gallery'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (source == null || !context.mounted) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedFile == null || !context.mounted) return;

    context.read<UserProfileBloc>().add(
      UploadProfileImage(
        uid: widget.uid,
        imageFile: File(pickedFile.path),
        oldImageUrl: widget.photoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UserProfileBloc, UserProfileState>(
      listenWhen: (previous, current) =>
          previous.imageUploadStatus != current.imageUploadStatus,
      listener: (context, state) {
        if (state.imageUploadStatus == ProfileImageUploadStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.imageUploadError ?? 'Failed to upload profile image.',
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        buildWhen: (previous, current) =>
            previous.imageUploadStatus != current.imageUploadStatus,
        builder: (context, state) {
          final bool isUploading =
              state.imageUploadStatus == ProfileImageUploadStatus.uploading;

          return SizedBox(
            width: widget.radius * 2,
            height: widget.radius * 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: 'profile-avatar-${widget.uid}',
                  child: _buildAvatarCircle(theme),
                ),
                if (isUploading)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.editable && !isUploading)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: GestureDetector(
                      onTap: () => _showImageSourceSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarCircle(ThemeData theme) {
    final String? photoUrl = widget.photoUrl;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircleAvatar(
            radius: widget.radius,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => _buildInitialsAvatar(theme),
        ),
      );
    }

    return _buildInitialsAvatar(theme);
  }

  Widget _buildInitialsAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        widget._initials,
        style: TextStyle(
          fontSize: widget.radius * 0.6,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

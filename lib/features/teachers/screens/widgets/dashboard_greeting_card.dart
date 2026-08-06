import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

/// Dashboard header — teacher's "Namaste, <name>" greeting, notification
/// bell, profile avatar, and logout button, all in one merged header bar.
///
/// Styled to match the student dashboard's GreetingCard header (same
/// paddings, font sizes, avatar sizing, breakpoints), but without the
/// attendance/assignments/queue-position stats row, since that data
/// doesn't apply to the teacher dashboard.
class DashboardGreetingCard extends StatelessWidget {
  final String? photoUrl;
  final String fullName;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onLogout;

  /// Pass a real `TeacherNotificationBell()` here to get the live unread
  /// badge; if omitted, falls back to a plain bell using [onNotification].
  final Widget? notificationBell;
  final VoidCallback? onNotification;

  const DashboardGreetingCard({
    super.key,
    required this.fullName,
    this.photoUrl,
    this.isLoading = false,
    this.onTap,
    this.onLogout,
    this.notificationBell,
    this.onNotification,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double horizontalPadding = isMobile ? 16 : (isTablet ? 24 : 40);
    final double avatarRadius = isMobile ? 20 : (isTablet ? 24 : 28);
    final double nameSize = isMobile ? 20 : (isTablet ? 24 : 28);
    final double greetingSize = isMobile ? 14 : 15;

    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Container(
        width: double.infinity,
        color: AppTheme.primary,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
              18,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Namaste,",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: greetingSize,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isLoading ? "..." : fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: nameSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                notificationBell ??
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                      ),
                      onPressed: onNotification,
                    ),
                SizedBox(width: isMobile ? 10 : 16),
                GestureDetector(
                  onTap: onTap,
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                        hasPhoto ? NetworkImage(photoUrl!) : null,
                    child: isLoading
                        ? SizedBox(
                            width: avatarRadius,
                            height: avatarRadius,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : (!hasPhoto
                            ? Icon(
                                Icons.person,
                                color: Colors.white,
                                size: avatarRadius,
                              )
                            : null),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                  ),
                  onPressed: onLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

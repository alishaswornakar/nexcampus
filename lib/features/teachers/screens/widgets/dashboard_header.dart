import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const DashboardHeader({
    super.key,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.05;
    final avatarRadius = width * 0.06;
    final greetingSize = width * 0.045;
    final nameSize = width * 0.07;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String teacherName = user.displayName ?? "Teacher";
        String? photoUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          teacherName =
              data["fullName"] ?? teacherName;
          photoUrl = data["photoUrl"];
        }

        return Container(
          width: double.infinity,
          height: (height * 0.18).clamp(140.0, 170.0),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            horizontalPadding,
            horizontalPadding,
            20,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.only(
              // bottomLeft:
              //     Radius.circular(width * 0.08),
              // bottomRight:
              //     Radius.circular(width * 0.08),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Namaste,",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: greetingSize.clamp(
                            14,
                            18,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: height * 0.006,
                      ),

                      Text(
                        "Er. $teacherName",
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize:
                              nameSize.clamp(
                            22,
                            30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onProfileTap,
                      child: CircleAvatar(
                        radius: avatarRadius.clamp(22.0, 28.0),
                        backgroundColor: Colors.white,
                        backgroundImage:
                            photoUrl != null &&
                                    photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                        child:
                            photoUrl == null ||
                                    photoUrl.isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: AppTheme.primary,
                                    size: width * 0.06,
                                  )
                                : null,
                      ),
                    ),

                    SizedBox(width: width * 0.02),

                    PopupMenuButton<String>(
                      tooltip: "More",
                      padding: EdgeInsets.zero,
                      splashRadius: 22,
                      offset: const Offset(0, 45),
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'notification':
                            onNotificationTap();
                            break;

                          case 'logout':
                            onLogoutTap();
                            break;
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem<String>(
                          value: 'notification',
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_none,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Notifications',
                              ),
                            ],
                          ),
                        ),

                        PopupMenuDivider(),

                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Colors.red,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
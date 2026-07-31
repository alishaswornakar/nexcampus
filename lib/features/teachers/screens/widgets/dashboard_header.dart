import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const DashboardHeader({
    super.key,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  static const Color primaryColor = AppTheme.primary;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final headerHeight = height * 0.34;
    final horizontalPadding = width * 0.05;
    final avatarRadius = width * 0.06;
    final greetingSize = width * 0.045;
    final nameSize = width * 0.07;
    final statsHeight = height * 0.12;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String teacherName = user.displayName ?? "Teacher";
        String? photoUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          teacherName = data["fullName"] ?? teacherName;
          photoUrl = data["photoUrl"];
        }

        return Container(
          width: double.infinity,
          height: headerHeight.clamp(240.0, 340.0),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            horizontalPadding,
            horizontalPadding,
            horizontalPadding + 10,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(width * 0.08),
              bottomRight: Radius.circular(width * 0.08),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: height * 0.015),

              /// Top Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Namaste,",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: greetingSize.clamp(14.0, 18.0),
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        Text(
                          "Er. $teacherName",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: nameSize.clamp(22.0, 30.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: onNotificationTap,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: EdgeInsets.all(width * 0.025),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: width * 0.065,
                      ),
                    ),
                  ),

                  SizedBox(width: width * 0.03),

                  GestureDetector(
                    onTap: onProfileTap,
                    child: CircleAvatar(
                      radius: avatarRadius.clamp(22.0, 28.0),
                      backgroundColor: Colors.white,
                      backgroundImage: photoUrl != null &&
                              photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              color: AppTheme.primary,
                              size: width * 0.06,
                            )
                          : null,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.04),

              /// Statistics Card
              Container(
                height: statsHeight.clamp(90.0, 120.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(width * 0.05),
                ),
                child: Row(
                  children: [
                    _statItem(
                      context,
                      "03",
                      "Today's\nClasses",
                    ),
                    _divider(),
                    _statItem(
                      context,
                      "15",
                      "Pending\nReviews",
                    ),
                    _divider(),
                    _statItem(
                      context,
                      "180",
                      "Students",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 45,
      color: Colors.grey.shade300,
    );
  }

  Widget _statItem(
    BuildContext context,
    String number,
    String title,
  ) {
    final width = MediaQuery.of(context).size.width;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(
              number,
              style: TextStyle(
                fontSize: (width * 0.07).clamp(22.0, 30.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: width * 0.01),

          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: width * 0.015),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: (width * 0.032).clamp(11.0, 14.0),
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
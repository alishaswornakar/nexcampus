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

  static const Color primaryColor =  AppTheme.primary;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
          height: 300,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color:  AppTheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: Column(
            children: [

              /// Top Row
              Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 15),

                        const Text(
                          "Namaste,",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Er. $teacherName",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: onNotificationTap,
                    borderRadius:
                        BorderRadius.circular(30),
                    child: Container(
                      padding:
                          const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: onProfileTap,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          photoUrl != null &&
                                  photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                      child:
                          photoUrl == null ||
                                  photoUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color:  AppTheme.primary,
                                )
                              : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// Statistics Card
              Container(
                height: 95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  children: [

                    _statItem(
                      "03",
                      "Today's\nClasses",
                    ),

                    _divider(),

                    _statItem(
                      "15",
                      "Pending\nReviews",
                    ),

                    _divider(),

                    _statItem(
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
    String number,
    String title,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
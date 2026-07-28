// teacher_dashboard.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/core/notifications/services/notification_api_service.dart';

import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';
//import 'package:nexcampus_app/features/student/blocs/schedule/screens/schedule_screen.dart';
import 'package:nexcampus_app/features/teachers/shared_screens/department_semester_selection_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/grade_submission_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/teacher_submission_list_screen.dart';

// import 'package:nexcampus_app/features/teachers/teachers_features/notes/screens/notes_screen.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/screens/notice_screen.dart';
//import 'package:nexcampus_app/features/teachers/teachers_features/schedule/screens/teacher_schedule_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/screens/teacher_profile_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,

        title: const Text(
          "Teacher Dashboard",
          style: TextStyle(color: Colors.white),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),

            onSelected: (value) {
              if (value == "logout") {
                _logout(context);
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "logout",

                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),

                    SizedBox(width: 10),

                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            teacherWelcomeCard(),

            const SizedBox(height: 25),

            const Text(
              "Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _stat("Courses", "6", Icons.menu_book, Colors.indigo),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _stat("Students", "180", Icons.people, Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _stat(
                    "Assignments",
                    "12",
                    Icons.assignment,
                    Colors.purple,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _stat(
                    "Attendance",
                    "95%",
                    Icons.check_circle,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Quick Access",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              childAspectRatio: 1.05,

              children: [
                _feature(Icons.menu_book, "Courses", Colors.indigo, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DepartmentSemesterSelectionScreen(
                        feature: FeatureType.courses,
                      ),
                    ),
                  );
                }),

                _feature(Icons.class_, "Classes", Colors.red, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DepartmentSemesterSelectionScreen(
                        feature: FeatureType.classes,
                      ),
                    ),
                  );
                }),

                _feature(Icons.calendar_today, "Attendance", Colors.blue, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DepartmentSemesterSelectionScreen(
                        feature: FeatureType.attendance,
                      ),
                    ),
                  );
                }),

                _feature(Icons.assignment, "Assignments", Colors.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DepartmentSemesterSelectionScreen(
                        feature: FeatureType.assignments,
                      ),
                    ),
                  );
                }),

                // _feature(Icons.grade, "Grades", Colors.orange, () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => const DepartmentSemesterSelectionScreen(
                //         feature: FeatureType.grades,
                //       ),
                //     ),
                //   );
                // }),

                _feature(Icons.campaign, "Notices", Colors.deepPurple, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NoticeScreen()),
                  );
                }),

                //             _feature(

                //               Icons.chat,
                //               "Notes",
                //               Colors.teal,

                //               (){

                //                      Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => const NoteScreen(course: null,),
                //   ),
                // );

                //               },

                //             ),
                _feature(

                  Icons.menu_book,
                  "Courses",
                  Colors.indigo,

                  (){

                   Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const DepartmentSemesterSelectionScreen(
      feature: FeatureType.courses,
    ),
  ),
);

                  },

                ),




                _feature(

                  Icons.class_,
                  "Classes",
                  Colors.red,


                  (){

                   Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const DepartmentSemesterSelectionScreen(
      feature: FeatureType.classes,
    ),
  ),
);

                  },

                ),




                _feature(

                  Icons.calendar_today,
                  "Attendance",
                  Colors.blue,


                  (){


                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const DepartmentSemesterSelectionScreen(
      feature: FeatureType.attendance,
    ),
  ),
);


                  },


                ),





                _feature(

                  Icons.assignment,
                  "Assignments",
                  Colors.green,


                  (){


                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const DepartmentSemesterSelectionScreen(
      feature: FeatureType.assignments,
    ),
  ),
);

                  },


                ),





    //             _feature(

    //               Icons.grade,
    //               "Grades",
    //               Colors.orange,


    //               (){
    //                  Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => TeacherSubmissionListScreen(assignment: assignment),
    //   ),
    // );


    //               },


    //             ),





               _feature(
  Icons.campaign,
  "Notices",
  Colors.deepPurple,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NoticeScreen(),
      ),
    );
  },
),



               


    //             _feature(

    //               Icons.chat,
    //               "Notes",
    //               Colors.teal,


    //               (){
                    
    //                      Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => const NoteScreen(course: null,),
    //   ),
    // );

    //               },

    //             ),
     _feature(

                  Icons.calendar_view_month_rounded,
                  "schedules",
                  Colors.teal,

                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DepartmentSemesterSelectionScreen(
                          feature: FeatureType.schedules,
                        ),
                      ),
                    );
                  },
                ),

                _feature(Icons.person, "Profile", Colors.brown, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeacherProfileScreen(),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.class_), label: "Classes"),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget teacherWelcomeCard() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text("No user found");
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .snapshots(),

      builder: (context, snapshot) {
        String name = "Teacher";

        if (user.displayName != null && user.displayName!.isNotEmpty) {
          name = user.displayName!;
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          if (data["fullName"] != null) {
            name = data["fullName"];
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.blue,

            borderRadius: BorderRadius.circular(18),
          ),

          child: Row(
            children: [
              const CircleAvatar(
                radius: 35,

                backgroundColor: Colors.white,

                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),

              const SizedBox(width: 15),

              Text(
                "Welcome\n$name",

                style: const TextStyle(
                  color: Colors.white,

                  fontSize: 20,

                  fontWeight: FontWeight.bold,
                ),
              ),
               ElevatedButton(
  onPressed: () async {
    final success = await NotificationApiService().sendToStudents(
      department: "Computer Engineering",
      semester: "1",
      title: "Testing",
      body: "Hello students!",
    );

    print(success);
  },
  child: const Text("Send Notification"),
)            ],
          ),
        );
      },
    );
  }

  Widget _stat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 8),

          Text(
            value,

            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text(title),
        ],
      ),
    );
  }

  Widget _feature(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),

      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(15),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,

              blurRadius: 5,

              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 28,

              backgroundColor:
                  // ignore: deprecated_member_use
                  color.withOpacity(0.15),

              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(height: 12),

            Text(
              title,

              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text("Logout"),

        content: const Text("Are you sure you want to logout?"),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),

            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),

            child: const Text("Logout"),
          ),
        ],
      ),
    );
   

    if (result == true) {
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,

          MaterialPageRoute(builder: (_) => const LoginScreen()),

          (route) => false,
        );
      }
    }

  }
  
}

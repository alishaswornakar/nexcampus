import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nexcampus_app/features/student/blocs/result/screens/results_screen.dart';
import 'package:nexcampus_app/features/student/blocs/team_finder/screens/team_finder_screen.dart';
import 'quick_tile.dart';

import 'package:nexcampus_app/features/student/blocs/notices/screens/notices_screen.dart';
import '../blocs/attendance/screens/attendance_screen.dart';

import '../../../features/student/blocs/digital_queue/screens/digital_queue_home_screen.dart';
import 'package:nexcampus_app/features/student/blocs/syllabus/screens/syllabus_screen.dart';

import 'package:nexcampus_app/features/student/blocs/anonymous_issue_reporting/screens/anonymous_issue_reporting_screen.dart';


import '../blocs/assignment/screens/tasks_screen.dart';


/// Student profile data used by Quick Access features
class _StudentProfile {

  final String studentId;
  final String studentName;
  final String studentEmail;
  final String rollNumber;
  final String department;
  final String semester;


  const _StudentProfile({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
  });


  factory _StudentProfile.fromFirestore(
    String studentId,
    Map<String,dynamic>? data,
    User authUser,
  ){

    final map = data ?? {};

    return _StudentProfile(

      studentId: studentId,


      studentName:
          (map['fullName'] as String?)?.trim().isNotEmpty == true
              ? map['fullName']
              : (authUser.displayName ?? "Student"),


      studentEmail:
          (map['email'] as String?) ??
          authUser.email ??
          "",


      rollNumber:
          (map['rollNumber'] as String?) ??
          (map['roll'] as String?) ??
          "",


      department:
          (map['department'] as String?) ??
          "",


      semester:
          (map['semester'] as String?) ??
          "",

    );
  }

}




/// Cache profile data during app session
class _ProfileCache {

  static _StudentProfile? cached;

  static Future<_StudentProfile>? inFlight;

}




class QuickAccessGrid extends StatefulWidget {

  final String studentId;


  const QuickAccessGrid({
    required this.studentId,
    super.key,
  });



  @override
  State<QuickAccessGrid> createState() =>
      _QuickAccessGridState();

}




class _QuickAccessGridState
    extends State<QuickAccessGrid> {



  late final User _authUser =
      FirebaseAuth.instance.currentUser!;



  late _StudentProfile _profile =

      _ProfileCache.cached ??

      _StudentProfile(

        studentId: _authUser.uid,

        studentName:
            _authUser.displayName ??
            "Student",

        studentEmail:
            _authUser.email ??
            "",

        rollNumber: "",

        department: "",

        semester: "",

      );



  @override
  void initState() {

    super.initState();


    if(_ProfileCache.cached == null){

      _loadExtraProfileFields();

    }

  }




  Future<void> _loadExtraProfileFields() async {


    _ProfileCache.inFlight ??=

        FirebaseFirestore.instance
            .collection("users")
            .doc(_authUser.uid)
            .get()
            .then(

              (snap)=>

              _StudentProfile.fromFirestore(

                _authUser.uid,

                snap.data(),

                _authUser,

              ),

            );



    try {


      final profile =
          await _ProfileCache.inFlight!;



      _ProfileCache.cached =
          profile;



      if(mounted){

        setState((){

          _profile = profile;

        });

      }


    }catch(_){

    }


  }
    @override
  Widget build(BuildContext context) {


    final profile = _profile;


    final currentStudent = CurrentStudent(

      studentId: profile.studentId,

      studentName: profile.studentName,

      studentEmail: profile.studentEmail,

      rollNumber: profile.rollNumber,

      department: profile.department,

      semester: profile.semester,

    );



    return LayoutBuilder(

      builder: (context, constraints) {


        final width = constraints.maxWidth;



        int crossAxisCount;


        double childAspectRatio;



        double titleSize;



        double spacing;



        if(width < 400){

          // Small phones

          crossAxisCount = 2;

          childAspectRatio = 1.35;

          titleSize = 16;

          spacing = 10;


        }

        else if(width < 700){

          // Normal phones

          crossAxisCount = 2;

          childAspectRatio = 1.55;

          titleSize = 18;

          spacing = 12;


        }

        else if(width < 1100){

          // Tablets

          crossAxisCount = 3;

          childAspectRatio = 1.65;

          titleSize = 19;

          spacing = 16;


        }

        else{

          // Large screens / emulator desktop

          crossAxisCount = 4;

          childAspectRatio = 1.75;

          titleSize = 20;

          spacing = 18;


        }




        return Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,


          children: [



            Text(

              "Quick Access",

              style: TextStyle(

                fontSize: titleSize,

                fontWeight:
                    FontWeight.bold,

              ),

            ),



            SizedBox(

              height: spacing,

            ),



            GridView.builder(

              itemCount: 8,


              shrinkWrap: true,


              physics:
                  const NeverScrollableScrollPhysics(),



              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount:
                    crossAxisCount,


                mainAxisSpacing:
                    spacing,


                crossAxisSpacing:
                    spacing,


                childAspectRatio:
                    childAspectRatio,

              ),



              itemBuilder:
                  (context,index){



                final tiles = [



                  QuickTile(

                    icon:
                        Icons.calendar_today,

                    label:
                        "Attendance",

                    onTap: ()=>

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            AttendanceScreen(

                              studentId:
                                  profile.studentId,

                            ),

                      ),

                    ),

                  ),




                  QuickTile(

                    icon:
                        Icons.assignment,

                    label:
                        "Assignments",

                    onTap: ()=>

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            TasksScreen(

                              department:
                                  profile.department,

                              semester:
                                  profile.semester,

                              studentId:
                                  profile.studentId,

                            ),

                      ),

                    ),

                  ),




                  QuickTile(

                    icon:
                        Icons.hourglass_bottom,

                    label:
                        "Digital Queue",

                    onTap: ()=>

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            DigitalQueueHomeScreen(

                              student:
                                  currentStudent,

                            ),

                      ),

                    ),

                  ),





                  QuickTile(

                    icon:
                        Icons.menu_book,

                    label:
                        "Syllabus",

                    onTap: ()=>

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const SyllabusScreen(),

                      ),

                    ),

                  ),





                  QuickTile(

                    icon:
                        Icons.campaign,

                    label:
                        "Notices",

                    onTap: ()=>

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const NoticesScreen(),

                      ),

                    ),

                  ),




                  QuickTile(

                    icon:
                        Icons.report_problem,

                    label:
                        "Reporting",

                    onTap: ()=>

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            AnonymousIssueReportingScreen(

                              studentId:
                                  profile.studentId,

                              studentName:
                                  profile.studentName,

                            ),

                      ),

                    ),

                  ),




                  QuickTile(

                    icon:
                        Icons.groups,

                    label:
                        "Team Finder",

                    onTap: ()=>

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            TeamFinderScreen(

                              studentId:
                                  profile.studentId,

                              studentName:
                                  profile.studentName,

                              studentEmail:
                                  profile.studentEmail,

                              rollNumber:
                                  profile.rollNumber,

                              department:
                                  profile.department,

                              semester:
                                  profile.semester,

                            ),

                      ),

                    ),

                  ),




                  QuickTile(

                    icon:
                        Icons.poll,

                    label:
                        "Results",

                    onTap: ()=>

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const ResultsScreen(),

                      ),

                    ),

                  ),


                ];



                return tiles[index];

              },


            ),


          ],


        );


      },

    );

  }
    }
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/grade_submission_screen.dart';

import '../models/assignment_model.dart';
import '../models/assignment_submission_model.dart';

import '../repository/assignment_submission_repository.dart';
import '../services/assignment_submission_service.dart';


class TeacherSubmissionListScreen extends StatelessWidget {

  final AssignmentModel assignment;


  TeacherSubmissionListScreen({
    super.key,
    required this.assignment,
  });



  final repository =
      AssignmentSubmissionRepository(
    AssignmentSubmissionService(),
  );



  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;


    final isTablet =
        width >= 600;


    final isDesktop =
        width >= 1000;



    final horizontalPadding =
        isDesktop
            ? 80.0
            : isTablet
                ? 40.0
                : 16.0;



    return Scaffold(

      backgroundColor:
          const Color(0xffF5F7FA),



      appBar: AppBar(

        backgroundColor:
            AppTheme.primary,

        foregroundColor:
            Colors.white,

        title: Text(

          assignment.title,

          maxLines: 1,

          overflow:
              TextOverflow.ellipsis,

          style: TextStyle(

            fontSize:
                isTablet ? 20 : 17,

            fontWeight:
                FontWeight.w600,

          ),

        ),
      ),




      body: StreamBuilder<
          List<AssignmentSubmissionModel>>(


        stream:
            repository.getAssignmentSubmissions(
          assignmentId:
              assignment.id,
        ),



        builder:
            (context, snapshot) {


          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child:
                  CircularProgressIndicator(),
            );

          }




          if(snapshot.hasError){

            return Center(

              child:
                  Text(
                    snapshot.error.toString(),
                  ),

            );

          }




          if(!snapshot.hasData ||
              snapshot.data!.isEmpty){

            return const Center(

              child:
                  Text(
                    "No submissions yet.",
                    style:
                        TextStyle(
                      fontSize:18,
                    ),
                  ),

            );

          }




          final submissions =
              snapshot.data!;




          return Center(

            child: ConstrainedBox(

              constraints:
                  BoxConstraints(

                maxWidth:
                    isDesktop
                        ? 900
                        : double.infinity,

              ),



              child: ListView.builder(


                padding:
                    EdgeInsets.symmetric(

                  horizontal:
                      horizontalPadding,

                  vertical:
                      isTablet ? 24 : 16,

                ),



                itemCount:
                    submissions.length,



                itemBuilder:
                    (context,index){



                  final submission =
                      submissions[index];




                  return Card(

                    margin:
                        EdgeInsets.only(

                      bottom:
                          isTablet ? 18 : 14,

                    ),



                    elevation:
                        2,



                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                              16),

                    ),




                    child: InkWell(

                      borderRadius:
                          BorderRadius.circular(
                              16),



                      onTap: (){

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder:(_)=>
                                GradeSubmissionScreen(

                              submission:
                                  submission,

                            ),

                          ),

                        );

                      },



                      child: Padding(

                        padding:
                            EdgeInsets.all(

                          isTablet
                              ? 20
                              : 16,

                        ),



                        child: Row(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,



                          children: [



                            CircleAvatar(

                              radius:
                                  isTablet
                                      ? 30
                                      : 25,


                              backgroundColor:
                                  Colors.blue.shade100,

                              child:
                                  Icon(

                                Icons.person,

                                color:
                                    AppTheme.primary,

                                size:
                                    isTablet
                                        ? 30
                                        : 24,

                              ),

                            ),




                            SizedBox(

                              width:
                                  isTablet
                                      ? 18
                                      : 14,

                            ),




                            Expanded(

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment.start,


                                children: [



                                  Text(

                                    submission.studentName,

                                    maxLines:
                                        1,

                                    overflow:
                                        TextOverflow.ellipsis,


                                    style:
                                        TextStyle(

                                      fontWeight:
                                          FontWeight.bold,

                                      fontSize:
                                          isTablet
                                              ? 18
                                              : 16,

                                    ),

                                  ),




                                  const SizedBox(
                                    height:6,
                                  ),




                                  Text(
                                    "Roll: ${submission.roll}",
                                    style:
                                        TextStyle(
                                      fontSize:
                                          isTablet
                                              ? 16
                                              : 14,
                                    ),
                                  ),




                                  const SizedBox(
                                    height:4,
                                  ),




                                  Text(

                                    "Status: ${submission.status}",

                                    style:
                                        TextStyle(

                                      fontSize:
                                          isTablet
                                              ? 16
                                              : 14,

                                    ),

                                  ),




                                  if(submission.grade.isNotEmpty)

                                    Padding(

                                      padding:
                                          const EdgeInsets.only(
                                            top:4,
                                          ),

                                      child: Text(

                                        "Marks: ${submission.grade}",

                                        style:
                                            TextStyle(

                                          fontWeight:
                                              FontWeight.w600,

                                          fontSize:
                                              isTablet
                                                  ? 16
                                                  : 14,

                                        ),

                                      ),

                                    ),



                                ],

                              ),

                            ),




                            const SizedBox(
                              width:8,
                            ),




                            const Icon(

                              Icons.arrow_forward_ios,

                              size:18,

                            ),



                          ],

                        ),

                      ),

                    ),

                  );


                },

              ),

            ),

          );

        },

      ),

    );

  }

}
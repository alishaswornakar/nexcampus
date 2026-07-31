import 'package:flutter/material.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/subject_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/subject_services.dart';

import '../models/subject_model.dart';

import 'assignment_list_screen.dart';



class AssignmentSubjectScreen extends StatelessWidget {


  final String department;
  final String? semester;



  AssignmentSubjectScreen({
    super.key,
    required this.department,
    required this.semester,
  });



  final SubjectRepository repository =
      SubjectRepository(
        SubjectService(),
      );



  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;


    final isTablet =
        width >= 600;



    final horizontalPadding =
        isTablet
            ? 32.0
            : width * 0.045;



    final cardRadius =
        isTablet ? 20.0 : 16.0;



    return Scaffold(


      backgroundColor:
          const Color(0xffF5F7FA),




      appBar: AppBar(

        backgroundColor:
            AppTheme.primary,


        foregroundColor:
            Colors.white,


        title:

            Text(

          "Semester $semester",


          style:

              TextStyle(

                fontSize:
                    isTablet ? 22 : 18,

                fontWeight:
                    FontWeight.w600,
              ),
        ),
      ),




      body:

          StreamBuilder<List<SubjectModel>>(


        stream:

            repository.getSubjects(

          department:
              department,


          semester:
              semester.toString(),
        ),




        builder:

            (context, snapshot) {



          if (snapshot.connectionState ==
              ConnectionState.waiting) {


            return const Center(

              child:
                  CircularProgressIndicator(),
            );
          }




          if (snapshot.hasError) {


            return Center(

              child:

                  Padding(

                padding:
                    const EdgeInsets.all(20),

                child:

                    Text(

                  "Something went wrong\n${snapshot.error}",


                  textAlign:
                      TextAlign.center,


                  style:

                      const TextStyle(

                        fontSize:
                            16,
                      ),
                ),
              ),
            );
          }




          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {


            return const Center(

              child:

                  Text(

                "No subjects available",


                style:

                    TextStyle(

                      fontSize:
                          18,

                      fontWeight:
                          FontWeight.w500,
                    ),
              ),
            );
          }




          final subjects =
              snapshot.data!;




          return ListView.builder(


            padding:

                EdgeInsets.symmetric(

              horizontal:
                  horizontalPadding,


              vertical:
                  isTablet ? 24 : 16,
            ),



            itemCount:
                subjects.length,




            itemBuilder:
                (context, index) {


              final subject =
                  subjects[index];




              return Card(


                elevation:
                    2,


                margin:

                    EdgeInsets.only(

                  bottom:
                      isTablet ? 16 : 12,
                ),




                shape:

                    RoundedRectangleBorder(

                  borderRadius:

                      BorderRadius.circular(
                        cardRadius,
                      ),
                ),




                child:

                    InkWell(


                  borderRadius:

                      BorderRadius.circular(
                        cardRadius,
                      ),



                  onTap: () {


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>

                            AssignmentListScreen(

                              department:
                                  department,


                              semester:
                                  semester,


                              subject:
                                  subject.subject,
                            ),
                      ),
                    );
                  },




                  child:

                      Padding(

                    padding:

                        EdgeInsets.all(

                          isTablet
                              ? 20
                              : 14,
                        ),



                    child:

                        Row(

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

                            Icons.menu_book,


                            color:

                                AppTheme.primary,


                            size:

                                isTablet
                                    ? 30
                                    : 25,
                          ),
                        ),





                        SizedBox(

                          width:

                              isTablet
                                  ? 18
                                  : 14,
                        ),






                        Expanded(

                          child:

                              Text(

                            subject.subject,


                            maxLines:
                                2,


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
                        ),






                        Icon(

                          Icons.arrow_forward_ios,


                          size:

                              isTablet
                                  ? 22
                                  : 18,


                          color:
                              Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
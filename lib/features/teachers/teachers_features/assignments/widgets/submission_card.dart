import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/assignment_submission_model.dart';


class SubmissionCard extends StatelessWidget {

  final AssignmentSubmissionModel submission;
  final VoidCallback onTap;


  const SubmissionCard({
    super.key,
    required this.submission,
    required this.onTap,
  });



  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    final isTablet =
        width >= 600;



    return Card(

      margin:
          EdgeInsets.only(
            bottom: isTablet ? 18 : 14,
          ),


      elevation: 3,


      shape:
          RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
                  isTablet ? 20 : 16,
                ),
          ),



      child: InkWell(

        borderRadius:
            BorderRadius.circular(
              isTablet ? 20 : 16,
            ),


        onTap:
            onTap,



        child: Padding(

          padding:
              EdgeInsets.all(
                isTablet ? 20 : width * 0.04,
              ),



          child: Row(

            crossAxisAlignment:
                CrossAxisAlignment.start,


            children: [



              CircleAvatar(

                radius:
                    isTablet ? 30 : 26,


                backgroundColor:
                    Colors.blue.shade100,


                child:
                    Icon(

                      Icons.person,

                      color:
                          AppTheme.primary,

                      size:
                          isTablet ? 32 : 26,
                    ),
              ),




              SizedBox(

                width:
                    width * 0.035,
              ),





              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,


                  children: [



                    Text(

                      submission.studentName,


                      maxLines:
                          2,


                      overflow:
                          TextOverflow.ellipsis,



                      style:
                          TextStyle(

                            fontWeight:
                                FontWeight.bold,


                            fontSize:
                                isTablet ? 19 : 17,
                          ),
                    ),




                    const SizedBox(
                      height: 5,
                    ),





                    Text(

                      "Roll: ${submission.roll}",


                      style:
                          TextStyle(

                            fontSize:
                                isTablet ? 16 : 14,
                          ),
                    ),





                    const SizedBox(
                      height: 6,
                    ),





                    Row(

                      children: [


                        Icon(

                          Icons.picture_as_pdf,

                          size:
                              isTablet ? 22 : 18,


                          color:
                              Colors.red,
                        ),



                        const SizedBox(
                          width: 6,
                        ),




                        Expanded(

                          child: Text(

                            submission.title,


                            maxLines:
                                1,


                            overflow:
                                TextOverflow.ellipsis,


                            style:
                                TextStyle(

                                  fontSize:
                                      isTablet ? 15 : 13,
                                ),
                          ),
                        ),
                      ],
                    ),





                    SizedBox(

                      height:
                          isTablet ? 12 : 8,
                    ),






                    Container(

                      padding:
                          EdgeInsets.symmetric(

                            horizontal:
                                isTablet ? 14 : 10,


                            vertical:
                                isTablet ? 6 : 4,
                          ),



                      decoration:
                          BoxDecoration(


                            color:

                                submission.grade.isEmpty

                                    ? Colors.orange.shade100

                                    : Colors.green.shade100,



                            borderRadius:
                                BorderRadius.circular(20),
                          ),



                      child:
                          Text(


                            submission.grade.isEmpty

                                ? "Not Graded"

                                : "Grade : ${submission.grade}",



                            style:
                                TextStyle(


                                  color:

                                      submission.grade.isEmpty

                                          ? Colors.orange

                                          : Colors.green,



                                  fontWeight:
                                      FontWeight.bold,


                                  fontSize:
                                      isTablet ? 15 : 13,
                                ),
                          ),
                    ),
                  ],
                ),
              ),




              SizedBox(

                width:
                    width * 0.02,
              ),




              Icon(

                Icons.arrow_forward_ios,

                size:
                    isTablet ? 22 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
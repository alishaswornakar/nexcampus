import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/assignment_model.dart';


class SubmissionSummaryCard extends StatelessWidget {

  final AssignmentModel assignment;


  const SubmissionSummaryCard({
    super.key,
    required this.assignment,
  });



  Widget buildTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {

    final width =
        MediaQuery.of(context).size.width;

    final isTablet =
        width >= 600;



    return Padding(

      padding:
          EdgeInsets.symmetric(

            horizontal:
                isTablet ? 12 : 4,

            vertical:
                isTablet ? 6 : 2,
          ),


      child: ListTile(

        contentPadding:
            EdgeInsets.symmetric(

              horizontal:
                  isTablet ? 12 : 8,
            ),



        leading:
            CircleAvatar(

              radius:
                  isTablet ? 28 : 22,


              backgroundColor:
                  Colors.blue.shade50,


              child:
                  Icon(

                    icon,

                    color:
                        AppTheme.primary,

                    size:
                        isTablet ? 30 : 24,
                  ),
            ),




        title:
            Text(

              title,


              style:
                  TextStyle(

                    fontSize:
                        isTablet ? 16 : 14,

                    fontWeight:
                        FontWeight.w500,
                  ),
            ),




        subtitle:
            Text(

              value,


              maxLines:
                  2,


              overflow:
                  TextOverflow.ellipsis,



              style:
                  TextStyle(

                    fontSize:
                        isTablet ? 17 : 15,


                    fontWeight:
                        FontWeight.w600,
                  ),
            ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;


    final isTablet =
        width >= 600;



    return Card(

      elevation:
          3,


      shape:
          RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(

                  isTablet ? 20 : 16,
                ),
          ),



      child: Padding(

        padding:
            EdgeInsets.symmetric(

              vertical:
                  isTablet ? 12 : 8,
            ),



        child: Column(

          children: [


            buildTile(

              context,

              Icons.assignment,

              "Assignment",

              assignment.title,
            ),




            buildTile(

              context,

              Icons.school,

              "Department",

              assignment.department,
            ),




            buildTile(

              context,

              Icons.layers,

              "Semester",

              assignment.semester,
            ),





            buildTile(

              context,

              Icons.menu_book,

              "Subject",

              assignment.courseName,
            ),





            buildTile(

              context,

              Icons.calendar_today,

              "Due Date",

              "${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}",
            ),
          ],
        ),
      ),
    );
  }
}
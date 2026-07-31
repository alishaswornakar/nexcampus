import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/pdf_viewer_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/teacher_submission_list_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/file_download_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/widgets/pdf_attachment_card.dart';

import '../models/assignment_model.dart';
import '../services/assignment_service.dart';
import 'create_assignment_screen.dart';



class AssignmentDetailScreen extends StatelessWidget {

  final AssignmentModel assignment;


  AssignmentDetailScreen({
    super.key,
    required this.assignment,
  });



  final AssignmentRepository repository =
      AssignmentRepository(
        AssignmentService(),
      );



  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;


    final isTablet =
        width >= 600;



    final horizontalPadding =
        isTablet ? 32.0 : width * 0.045;



    final cardRadius =
        isTablet ? 20.0 : 16.0;



    final bool isOverdue =
        assignment.dueDate
            .isBefore(DateTime.now());



    return Scaffold(


      backgroundColor:
          const Color(0xffF5F7FA),



      appBar: AppBar(

        backgroundColor:
            AppTheme.primary,


        foregroundColor:
            Colors.white,


        title: Text(

          "Assignment Details",

          style: TextStyle(

            fontSize:
                isTablet ? 22 : 18,
          ),
        ),
      ),




      body: SingleChildScrollView(

        padding:
            EdgeInsets.symmetric(

              horizontal:
                  horizontalPadding,

              vertical:
                  isTablet ? 24 : 18,
            ),



        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,



          children: [



            /// Assignment Title Card

            Card(

              elevation:
                  3,


              shape:
                  RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                          cardRadius,
                        ),
                  ),



              child: Padding(

                padding:
                    EdgeInsets.all(
                      isTablet ? 24 : 18,
                    ),



                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,


                  children: [


                    Row(

                      children: [

                        Icon(

                          Icons.assignment,

                          color:
                              AppTheme.primary,

                          size:
                              isTablet ? 28 : 22,
                        ),



                        const SizedBox(
                          width: 8,
                        ),



                        Text(

                          "Assignment",


                          style:
                              TextStyle(

                                fontSize:
                                    isTablet
                                        ? 18
                                        : 16,


                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),
                      ],
                    ),




                    const SizedBox(
                      height: 14,
                    ),





                    Text(

                      assignment.title,


                      maxLines:
                          3,


                      overflow:
                          TextOverflow.ellipsis,



                      style:
                          TextStyle(

                            fontSize:
                                isTablet
                                    ? 26
                                    : 22,


                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),





            const SizedBox(
              height: 18,
            ),




            /// Description Card

            Card(

              elevation:
                  3,


              shape:
                  RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                          cardRadius,
                        ),
                  ),




              child: Padding(

                padding:
                    EdgeInsets.all(
                      isTablet ? 24 : 18,
                    ),



                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,



                  children: [


                    Text(

                      "Description",


                      style:
                          TextStyle(

                            fontSize:
                                isTablet ? 20 : 18,


                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),



                    const SizedBox(
                      height: 12,
                    ),




                    Text(

                      assignment.description,


                      style:
                          TextStyle(

                            fontSize:
                                isTablet ? 18 : 16,


                            height:
                                1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),





            const SizedBox(
              height: 18,
            ),





            /// Information Card

            Card(

              elevation:
                  3,


              shape:
                  RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                          cardRadius,
                        ),
                  ),




              child: Padding(

                padding:
                    EdgeInsets.all(
                      isTablet ? 20 : 18,
                    ),



                child: Column(

                  children: [


                    _infoTile(
                      context,
                      Icons.school,
                      "Department",
                      assignment.department,
                    ),


                    const Divider(),



                    _infoTile(
                      context,
                      Icons.layers,
                      "Semester",
                      assignment.semester,
                    ),



                    const Divider(),



                    _infoTile(
                      context,
                      Icons.menu_book,
                      "Subject",
                      assignment.courseName,
                    ),



                    const Divider(),



                    _infoTile(
                      context,
                      Icons.calendar_month,
                      "Due Date",
                      DateFormat(
                        "dd MMM yyyy",
                      ).format(
                        assignment.dueDate,
                      ),
                    ),



                    const Divider(),



                    _infoTile(
                      context,

                      isOverdue
                          ? Icons.warning
                          : Icons.check_circle,

                      "Status",

                      isOverdue
                          ? "Overdue"
                          : "Active",
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(
              height: 18,
            ),



            /// PDF Attachment

            if (assignment.pdfUrl != null &&
                assignment.pdfUrl!.isNotEmpty) ...[


              PdfAttachmentCard(

                fileName:
                    assignment.pdfName ??
                    "Assignment.pdf",



                onView: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          PdfViewerScreen(

                            pdfUrl:
                                assignment.pdfUrl!,

                            title:
                                assignment.pdfName ??
                                "Assignment PDF",
                          ),
                    ),
                  );
                },



                onDownload: () async {


                  try {


                    final downloaded =
                        await FileDownloadService
                            .downloadFile(

                      url:
                          assignment.pdfUrl!,


                      fileName:
                          assignment.pdfName ??
                          "Assignment.pdf",
                    );



                    if (!context.mounted) return;



                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      SnackBar(

                        backgroundColor:

                            downloaded

                                ? Colors.green

                                : Colors.orange,


                        content: Text(

                          downloaded

                              ? "PDF downloaded successfully."

                              : "Download cancelled.",
                        ),
                      ),
                    );


                  } catch (e) {


                    if (!context.mounted) return;


                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      SnackBar(

                        backgroundColor:
                            Colors.red,

                        content:
                            Text(e.toString()),
                      ),
                    );
                  }
                },
              ),
            ],





            const SizedBox(
              height: 30,
            ),




            /// Edit Button

            _actionButton(

              context,

              icon:
                  Icons.edit,


              label:
                  "Edit Assignment",


              color:
                  AppTheme.primary,


              onPressed: () async {


                final updated =
                    await Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        CreateAssignmentScreen(

                          department:
                              assignment.department,


                          semester:
                              assignment.semester,


                          selectedSubject:
                              assignment.courseName,


                          assignment:
                              assignment,
                        ),
                  ),
                );



                if (updated == true &&
                    context.mounted) {

                  Navigator.pop(
                    context,
                    true,
                  );
                }
              },
            ),




            const SizedBox(
              height: 12,
            ),




            /// Delete Button

            _actionButton(

              context,

              icon:
                  Icons.delete,


              label:
                  "Delete",


              color:
                  Colors.red,



              onPressed: () async {


                final confirm =
                    await showDialog<bool>(

                      context:
                          context,


                      builder: (_) =>
                          AlertDialog(

                            title:
                                const Text(
                              "Delete Assignment",
                            ),


                            content:
                                const Text(
                              "Are you sure you want to delete this assignment?",
                            ),



                            actions: [


                              TextButton(

                                onPressed: () {

                                  Navigator.pop(
                                    context,
                                    false,
                                  );
                                },


                                child:
                                    const Text(
                                  "Cancel",
                                ),
                              ),




                              ElevatedButton(

                                onPressed: () {

                                  Navigator.pop(
                                    context,
                                    true,
                                  );
                                },


                                child:
                                    const Text(
                                  "Delete",
                                ),
                              ),
                            ],
                          ),
                    ) ??
                    false;



                if (!confirm) return;



                await repository.deleteAssignment(
                  assignment.id,
                );



                if (context.mounted) {


                  Navigator.pop(
                    context,
                  );



                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(

                      backgroundColor:
                          Colors.green,

                      content:
                          Text(
                        "Assignment Deleted",
                      ),
                    ),
                  );
                }
              },
            ),





            const SizedBox(
              height: 12,
            ),





            /// Submission Button

            SizedBox(

              width:
                  double.infinity,


              child:
                  OutlinedButton.icon(


                    icon:
                        const Icon(
                      Icons.people,
                    ),



                    label:
                        Text(

                      "View Submissions",

                      style:
                          TextStyle(

                            fontSize:
                                isTablet
                                    ? 18
                                    : 16,
                          ),
                    ),



                    style:
                        OutlinedButton.styleFrom(


                          foregroundColor:
                              AppTheme.primary,



                          side:
                              const BorderSide(

                                color:
                                    Colors.blue,

                                width:
                                    1.5,
                              ),



                          padding:
                              EdgeInsets.symmetric(

                                vertical:
                                    isTablet
                                        ? 18
                                        : 14,
                              ),



                          shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                      14,
                                    ),
                              ),
                        ),



                    onPressed: () {


                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              TeacherSubmissionListScreen(

                                assignment:
                                    assignment,
                              ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }





  Widget _actionButton(
    BuildContext context, {

    required IconData icon,

    required String label,

    required Color color,

    required VoidCallback onPressed,

  }) {


    final width =
        MediaQuery.of(context).size.width;


    final isTablet =
        width >= 600;



    return SizedBox(

      width:
          double.infinity,


      child:
          ElevatedButton.icon(


            icon:
                Icon(icon),



            label:
                Text(

              label,


              style:
                  TextStyle(

                    fontSize:
                        isTablet
                            ? 18
                            : 16,
                  ),
            ),



            onPressed:
                onPressed,



            style:
                ElevatedButton.styleFrom(


                  backgroundColor:
                      color,


                  foregroundColor:
                      Colors.white,


                  padding:
                      EdgeInsets.symmetric(

                        vertical:
                            isTablet
                                ? 20
                                : 15,
                      ),



                  shape:
                      RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                      ),
                ),
          ),
    );
  }






  Widget _infoTile(

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

            vertical:
                isTablet
                    ? 8
                    : 5,
          ),



      child:
          Row(


            crossAxisAlignment:
                CrossAxisAlignment.start,



            children: [



              Icon(

                icon,

                color:
                    AppTheme.primary,


                size:
                    isTablet
                        ? 26
                        : 22,
              ),




              const SizedBox(
                width: 12,
              ),




              Expanded(

                flex:
                    2,


                child:
                    Text(

                  title,


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





              Expanded(

                flex:
                    3,


                child:
                    Text(

                  value,


                  textAlign:
                      TextAlign.end,


                  maxLines:
                      2,


                  overflow:
                      TextOverflow.ellipsis,


                  style:
                      TextStyle(

                        fontSize:
                            isTablet
                                ? 16
                                : 14,
                      ),
                ),
              ),
            ],
          ),
    );
  }
}
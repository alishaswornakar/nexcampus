// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../models/assignment_submission_model.dart';
import '../repository/assignment_submission_repository.dart';
import '../services/assignment_submission_service.dart';


class GradeSubmissionScreen extends StatefulWidget {

  final AssignmentSubmissionModel submission;


  const GradeSubmissionScreen({
    super.key,
    required this.submission,
  });


  @override
  State<GradeSubmissionScreen> createState() =>
      _GradeSubmissionScreenState();

}



class _GradeSubmissionScreenState
    extends State<GradeSubmissionScreen> {


  final repository =
      AssignmentSubmissionRepository(
    AssignmentSubmissionService(),
  );


  late TextEditingController gradeController;

  late TextEditingController feedbackController;


  bool isSaving = false;


  String status = "Reviewed";



  @override
  void initState() {

    super.initState();


    gradeController =
        TextEditingController(
      text: widget.submission.grade,
    );


    feedbackController =
        TextEditingController(
      text: widget.submission.feedback,
    );



    if (widget.submission.status == "Pending" ||
        widget.submission.status.isEmpty) {

      status = "Reviewed";

    } else {

      status = widget.submission.status;

    }

  }




  @override
  void dispose() {

    gradeController.dispose();

    feedbackController.dispose();

    super.dispose();

  }
Future<void> downloadPdf() async {

  try {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Downloading PDF...",
        ),
      ),
    );


    final directory =
        await getApplicationDocumentsDirectory();


    final filePath =
        "${directory.path}/${widget.submission.studentName}_assignment.pdf";


    await Dio().download(

      widget.submission.pdfUrl,

      filePath,

    );


    if(!mounted) return;


    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        backgroundColor:
            Colors.green,

        content:
            Text(
          "PDF downloaded successfully",
        ),

      ),

    );


    await OpenFilex.open(filePath);


  }

  catch(e){

    if(!mounted) return;


    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        backgroundColor:
            Colors.red,

        content:
            Text(
          "Download failed: $e",
        ),

      ),

    );

  }

}



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
          const Color(0xffF5F7FA),



      appBar: AppBar(

        backgroundColor:
            AppTheme.primary,

        foregroundColor:
            Colors.white,

        title:
            const Text(
          "Grade Submission",
          overflow:
              TextOverflow.ellipsis,
        ),

      ),



      body:

      LayoutBuilder(

        builder:
            (context,constraints){


          final width =
              constraints.maxWidth;



          final bool isTablet =
              width >= 600;



          final double horizontalPadding =
              isTablet ? 40 : 20;



          return SingleChildScrollView(

            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,


            padding:
                EdgeInsets.symmetric(

              horizontal:
                  horizontalPadding,


              vertical:
                  isTablet ? 30 : 20,

            ),



            child:

            Center(

              child:

              ConstrainedBox(

                constraints:
                    BoxConstraints(

                  maxWidth:
                      isTablet
                          ? 700
                          : double.infinity,

                ),



                child:

                Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,


                  children: [



                    /// Student Information Card

                    Card(

                      elevation: 2,


                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          isTablet ? 20 : 14,
                        ),

                      ),



                      child:

                      ListTile(

                        contentPadding:
                            EdgeInsets.all(
                          isTablet ? 18 : 12,
                        ),



                        leading:

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



                        title:

                        Text(

                          widget.submission.studentName,


                          style:
                              TextStyle(

                            fontSize:
                                isTablet ? 18 : 16,


                            fontWeight:
                                FontWeight.w600,

                          ),

                        ),



                        subtitle:

                        Text(

                          "Roll: ${widget.submission.roll}",

                        ),

                      ),

                    ),




                    SizedBox(
                      height:
                          isTablet ? 20 : 15,
                    ),




                    /// Submitted Date Card


                    Card(

                      elevation: 2,


                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          isTablet ? 20 : 14,
                        ),

                      ),



                      child:

                      ListTile(

                        contentPadding:
                            EdgeInsets.all(
                          isTablet ? 18 : 12,
                        ),



                        leading:

                        const Icon(

                          Icons.calendar_today,

                          color:
                              AppTheme.primary,

                        ),



                        title:

                        const Text(
                          "Submitted On",
                        ),



                        subtitle:

                        Text(

                          DateFormat(
                            "dd MMM yyyy hh:mm a",
                          ).format(
                            widget.submission.submittedAt,
                          ),

                        ),

                      ),

                    ),




                    SizedBox(
                      height:
                          isTablet ? 30 : 25,
                    ),




                    _sectionTitle(
                      "Student Remarks",
                      isTablet,
                    ),



                    const SizedBox(
                      height: 8,
                    ),
//                     _sectionTitle(
//   "Submitted Assignment PDF",
//   isTablet,
// ),


const SizedBox(
  height: 8,
),



if(widget.submission.pdfUrl.isNotEmpty)

Container(

  width:
      double.infinity,


  padding:
      EdgeInsets.all(
        isTablet ? 18 : 14,
      ),



  decoration:
      BoxDecoration(

    color:
        Colors.white,


    borderRadius:
        BorderRadius.circular(
          isTablet ? 18 : 12,
        ),

  ),



  child:

  Column(

    children: [


      const Icon(
        Icons.picture_as_pdf,
        size: 50,
        color: Colors.red,
      ),



      const SizedBox(
        height: 10,
      ),



      Text(
        "Student uploaded PDF",
        style:
            TextStyle(
          fontSize:
              isTablet ? 16 : 14,
          fontWeight:
              FontWeight.w600,
        ),
      ),



      const SizedBox(
        height: 15,
      ),



      SizedBox(

        width:
            double.infinity,


        child:

        ElevatedButton.icon(

          icon:
              const Icon(
                Icons.visibility,
              ),


          label:
              const Text(
                "View PDF",
              ),



          style:
              ElevatedButton.styleFrom(

            backgroundColor:
                AppTheme.primary,


            foregroundColor:
                Colors.white,

          ),



          onPressed: (){


            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    Scaffold(

                      appBar:
                          AppBar(

                        title:
                            const Text(
                          "Assignment PDF",
                        ),

                        backgroundColor:
                            AppTheme.primary,

                      ),



                      body:

                      SfPdfViewer.network(

                        widget.submission.pdfUrl,

                      ),

                    ),

              ),

            );


          },


        ),

      ),

    ],

  ),

)

else

Container(

  width:
      double.infinity,

  padding:
      const EdgeInsets.all(16),


  decoration:
      BoxDecoration(

    color:
        Colors.white,


    borderRadius:
        BorderRadius.circular(12),

  ),


  child:

  const Text(
    "No PDF submitted.",
  ),

),



                    Container(

                      width:
                          double.infinity,


                      padding:
                          EdgeInsets.all(
                        isTablet ? 18 : 14,
                      ),



                      decoration:
                          BoxDecoration(

                        color:
                            Colors.white,


                        borderRadius:
                            BorderRadius.circular(
                          isTablet ? 18 : 12,
                        ),

                      ),



                      child:

                      Text(

                        widget.submission.remarks.isEmpty
                            ? "No remarks"
                            : widget.submission.remarks,


                        style:

                        TextStyle(

                          fontSize:
                              isTablet ? 16 : 14,

                        ),

                      ),

                    ),



                    SizedBox(
                      height:
                          isTablet ? 30 : 25,
                    ),



                    _sectionTitle(
                      "Marks",
                      isTablet,
                    ),



                    const SizedBox(
                      height: 8,
                    ),



                    TextField(

                      controller:
                          gradeController,


                      keyboardType:
                          TextInputType.number,


                      decoration:
                          _inputDecoration(
                        "Enter marks (e.g. 85)",
                      ),

                    ),



                    SizedBox(
                      height:
                          isTablet ? 25 : 20,
                    ),



                    _sectionTitle(
                      "Teacher Feedback",
                      isTablet,
                    ),



                    const SizedBox(
                      height: 8,
                    ),



                    TextField(

                      controller:
                          feedbackController,


                      maxLines:
                          isTablet ? 6 : 5,


                      decoration:
                          _inputDecoration(
                        "Write feedback...",
                      ),

                    ),
                                        SizedBox(
                      height:
                          isTablet ? 25 : 20,
                    ),



                    _sectionTitle(
                      "Status",
                      isTablet,
                    ),



                    const SizedBox(
                      height: 8,
                    ),



                    DropdownButtonFormField<String>(

                      initialValue: status,


                      decoration:
                          _inputDecoration(
                        "",
                      ),



                      items: const [

                        DropdownMenuItem(

                          value:
                              "Reviewed",

                          child:
                              Text(
                            "Reviewed",
                          ),

                        ),



                        DropdownMenuItem(

                          value:
                              "Needs Revision",

                          child:
                              Text(
                            "Needs Revision",
                          ),

                        ),

                      ],



                      onChanged:
                          (value){

                        if(value != null){

                          setState(() {

                            status =
                                value;

                          });

                        }

                      },

                    ),




                    SizedBox(
                      height:
                          isTablet ? 35 : 30,
                    ),

                     SizedBox(

                      width:
                          double.infinity,


                      height:
                          isTablet ? 60 : 55,



                      child:

                      ElevatedButton.icon(


                        icon:

                        isSaving

                            ?

                        const SizedBox(

                          height: 20,

                          width: 20,

                          child:

                          CircularProgressIndicator(

                            strokeWidth: 2,

                            color:
                                Colors.white,

                          ),

                        )

                            :

                        const Icon(
                          Icons.save,
                        ),




                        label:

                        Text(

                          isSaving
                              ? "Saving..."
                              : "Save Grade",


                          style:
                              TextStyle(

                            fontSize:
                                isTablet ? 17 : 15,

                          ),

                        ),




                        onPressed:

                        isSaving
                            ? null
                            : saveGrade,




                        style:

                        ElevatedButton.styleFrom(

                          backgroundColor:
                              AppTheme.primary,


                          foregroundColor:
                              Colors.white,



                          shape:

                          RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),

                          ),

                        ),

                      ),

                    ),



                  ],

                ),

              ),

            ),

          );


        },

      ),

    );

  }






  Widget _sectionTitle(
      String text,
      bool tablet,
      ){

    return Text(

      text,

      style:

      TextStyle(

        fontSize:
            tablet ? 18 : 16,


        fontWeight:
            FontWeight.bold,

      ),

    );

  }







  InputDecoration _inputDecoration(
      String hint,
      ){

    return InputDecoration(


      hintText:
          hint,


      filled:
          true,


      fillColor:
          Colors.white,



      border:

      OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(
          12,
        ),

      ),


    );

  }







  Future<void> saveGrade() async {


    if (gradeController.text.trim().isEmpty) {


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
              Text(
            "Please enter marks.",
          ),

        ),

      );


      return;

    }



    setState(() {

      isSaving =
          true;

    });




    try {


      await repository.gradeSubmission(


        submissionId:
            widget.submission.id,



        grade:
            gradeController.text.trim(),



        feedback:
            feedbackController.text.trim(),



        status:
            status,


      );



      if(!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
              Colors.green,


          content:

          Text(
            "Submission graded successfully!",
          ),

        ),

      );



      Navigator.pop(context);



    }

    catch(e){


      if(!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor:
              Colors.red,


          content:
              Text(
            e.toString(),
          ),

        ),

      );


    }



    finally {


      if(mounted){

        setState(() {

          isSaving =
              false;

        });

      }


    }

  }

}
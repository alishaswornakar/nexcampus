// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/assignment_model.dart';
import '../models/assignment_submission_model.dart';

import '../repository/assignment_submission_repository.dart';
import '../services/assignment_submission_service.dart';
import '../services/cloudinary_service.dart';

import '../widgets/remarks_field.dart';
import '../widgets/submission_summary_card.dart';
import '../widgets/pdf_upload_card.dart';
import '../widgets/submit_assignment_button.dart';


class SubmitAssignmentScreen extends StatefulWidget {

  final AssignmentModel assignment;

  const SubmitAssignmentScreen({
    super.key,
    required this.assignment,
  });


  @override
  State<SubmitAssignmentScreen> createState() =>
      _SubmitAssignmentScreenState();
}



class _SubmitAssignmentScreenState
    extends State<SubmitAssignmentScreen> {


  final remarksController =
      TextEditingController();


  final repository =
      AssignmentSubmissionRepository(
    AssignmentSubmissionService(),
  );


  final dynamic cloudinary =
      CloudinaryService();


  bool isUploadingPdf = false;

  bool isSubmitting = false;


  String? pdfUrl;

  String? pdfName;



  @override
  void dispose() {

    remarksController.dispose();

    super.dispose();
  }



  Future<void> uploadPdf() async {

    setState(() {
      isUploadingPdf = true;
    });


    try {

      final result =
          await cloudinary.uploadPdf();


      if (result != null) {

        setState(() {

          pdfUrl = result["url"];

          pdfName = result["name"];

        });


        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            backgroundColor: Colors.green,
            content:
                Text("PDF uploaded successfully."),
          ),
        );
      }


    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(e.toString()),
        ),
      );
    }


    if(mounted){

      setState(() {
        isUploadingPdf = false;
      });

    }

  }



  Future<void> submitAssignment() async {


    if(pdfUrl == null){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text(
                "Please upload your assignment PDF.",
              ),
        ),
      );

      return;
    }



    final user =
        FirebaseAuth.instance.currentUser;



    if(user == null){
      return;
    }



    setState(() {

      isSubmitting = true;

    });



    try {


      final userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();



      final userData =
          userDoc.data()
              as Map<String,dynamic>;



      final doc =
          FirebaseFirestore.instance
              .collection(
                "assignment_submissions",
              )
              .doc();



      final submission =
          AssignmentSubmissionModel(

        id: doc.id,

        assignmentId:
            widget.assignment.id,


        studentId:
            user.uid,


        studentName:
            userData["fullName"] ?? "",


        roll:
            userData["roll"] ?? "",


        department:
            userData["department"] ?? "",


        semester:
            userData["semester"] ?? "",


        pdfUrl:
            pdfUrl!,


        title:
            pdfName ?? "",


        remarks:
            remarksController.text.trim(),


        submittedAt:
            DateTime.now(),
      );



      await repository.submitAssignment(
        submission,
      );



      if(!mounted)return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          backgroundColor: Colors.green,
          content:
              Text(
                "Assignment submitted successfully!",
              ),
        ),
      );


      Navigator.pop(context);



    }catch(e){


      if(!mounted)return;


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(e.toString()),
        ),
      );


    }finally{


      if(mounted){

        setState(() {

          isSubmitting = false;

        });

      }

    }

  }
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
              : 20.0;



  final titleSize =
      isTablet ? 20.0 : 16.0;



  return Scaffold(

    backgroundColor:
        const Color(0xffF5F7FA),


    appBar: AppBar(

      backgroundColor:
          AppTheme.primary,

      foregroundColor:
          Colors.white,

      centerTitle: true,

      title:
          Text(
            "Submit Assignment",
            style: TextStyle(
              fontSize:
                  isTablet ? 22 : 18,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
    ),



    body: SingleChildScrollView(

      physics:
          const BouncingScrollPhysics(),


      child: Center(

        child: ConstrainedBox(

          constraints:
              BoxConstraints(

            maxWidth:
                isDesktop
                    ? 850
                    : double.infinity,

          ),


          child: Padding(

            padding:
                EdgeInsets.symmetric(

              horizontal:
                  horizontalPadding,

              vertical:
                  isTablet ? 30 : 20,

            ),


            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children: [


                /// Assignment Summary

                SubmissionSummaryCard(
                  assignment:
                      widget.assignment,
                ),



                SizedBox(
                  height:
                      isTablet ? 30 : 24,
                ),




                Text(

                  "Remarks",

                  style:
                      TextStyle(

                    fontSize:
                        titleSize,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),



                const SizedBox(
                  height: 10,
                ),




                RemarksField(

                  controller:
                      remarksController,

                ),





                SizedBox(

                  height:
                      isTablet ? 30 : 24,

                ),




                Text(

                  "Assignment PDF",

                  style:
                      TextStyle(

                    fontSize:
                        titleSize,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),




                const SizedBox(
                  height: 10,
                ),




                PdfUploadCard(

                  isUploading:
                      isUploadingPdf,

                  pdfName:
                      pdfName,

                  onTap:
                      uploadPdf,

                ),





                SizedBox(

                  height:
                      isTablet ? 40 : 30,

                ),





                SubmitAssignmentButton(

                  isSubmitting:
                      isSubmitting,

                  onPressed:
                      submitAssignment,

                ),



                const SizedBox(
                  height: 20,
                ),


              ],

            ),

          ),

        ),

      ),

    ),

  );

}
    }
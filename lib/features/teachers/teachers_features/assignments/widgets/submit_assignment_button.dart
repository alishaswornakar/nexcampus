import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class SubmitAssignmentButton extends StatelessWidget {

  final bool isSubmitting;
  final VoidCallback onPressed;


  const SubmitAssignmentButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });



  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;


    final isTablet =
        width >= 600;



    final buttonHeight =
        isTablet ? 64.0 : width * 0.14;



    return SizedBox(

      width:
          double.infinity,


      height:
          buttonHeight,



      child: ElevatedButton.icon(


        onPressed:
            isSubmitting
                ? null
                : onPressed,



        icon:

        isSubmitting

            ? SizedBox(

                width:
                    isTablet ? 26 : 22,


                height:
                    isTablet ? 26 : 22,


                child:
                    const CircularProgressIndicator(

                      strokeWidth:
                          2,

                      color:
                          Colors.white,
                    ),
              )


            : Icon(

                Icons.upload_file,

                size:
                    isTablet ? 28 : 22,
              ),





        label:

        Flexible(

          child: Text(

            isSubmitting

                ? "Submitting..."

                : "Submit Assignment",



            overflow:
                TextOverflow.ellipsis,



            style:
                TextStyle(

                  fontSize:
                      isTablet ? 18 : 16,


                  fontWeight:
                      FontWeight.w600,
                ),
          ),
        ),




        style:
            ElevatedButton.styleFrom(


              backgroundColor:
                  AppTheme.primary,


              foregroundColor:
                  Colors.white,



              disabledBackgroundColor:
                  Colors.blue.shade300,



              elevation:
                  3,



              padding:
                  EdgeInsets.symmetric(

                    horizontal:
                        isTablet ? 24 : 16,
                  ),




              shape:
                  RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(

                          isTablet ? 18 : 14,
                        ),
                  ),
            ),
      ),
    );
  }
}
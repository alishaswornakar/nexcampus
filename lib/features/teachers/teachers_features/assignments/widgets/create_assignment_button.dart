import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class CreateAssignmentButton extends StatelessWidget {

  final bool isSaving;
  final VoidCallback onPressed;


  const CreateAssignmentButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });


  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600;


    final buttonHeight =
        isTablet ? 64.0 : width * 0.14;


    final fontSize =
        isTablet ? 18.0 : width * 0.04;



    return SizedBox(

      width: double.infinity,

      height: buttonHeight,


      child: ElevatedButton.icon(


        onPressed:
            isSaving ? null : onPressed,


        icon:

        isSaving

            ? SizedBox(

                width:
                    isTablet ? 26 : 22,

                height:
                    isTablet ? 26 : 22,


                child:
                    const CircularProgressIndicator(

                      strokeWidth: 2,

                      color:
                          Colors.white,
                    ),
              )


            : Icon(

                Icons.assignment_add,

                size:
                    isTablet ? 28 : 22,
              ),



        label:

        Flexible(

          child: Text(

            isSaving

                ? "Creating Assignment..."

                : "Create Assignment",


            overflow:
                TextOverflow.ellipsis,


            style:
                TextStyle(

                  fontSize:
                      fontSize,

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
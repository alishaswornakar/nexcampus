import 'package:flutter/material.dart';

class RemarksField extends StatelessWidget {

  final TextEditingController controller;


  const RemarksField({
    super.key,
    required this.controller,
  });



  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;


    final isTablet =
        width >= 600;



    return TextField(

      controller:
          controller,


      maxLines:
          isTablet ? 6 : 4,


      minLines:
          isTablet ? 4 : 3,



      style:
          TextStyle(

            fontSize:
                isTablet ? 16 : 14,
          ),



      decoration:
          InputDecoration(


            labelText:
                "Remarks (Optional)",



            hintText:
                "Write remarks for the teacher...",



            hintStyle:
                TextStyle(

                  fontSize:
                      isTablet ? 16 : 14,

                  color:
                      Colors.grey.shade600,
                ),



            filled:
                true,



            fillColor:
                Colors.white,



            contentPadding:
                EdgeInsets.all(

                  isTablet
                      ? 20
                      : width * 0.04,
                ),



            border:
                OutlineInputBorder(


                  borderRadius:
                      BorderRadius.circular(

                        isTablet ? 18 : 14,
                      ),
                ),



            enabledBorder:
                OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(

                        isTablet ? 18 : 14,
                      ),


                  borderSide:
                      BorderSide(

                        color:
                            Colors.grey.shade300,
                      ),
                ),



            focusedBorder:
                OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(

                        isTablet ? 18 : 14,
                      ),


                  borderSide:
                      const BorderSide(

                        color:
                            Colors.blue,

                        width:
                            1.5,
                      ),
                ),
          ),
    );
  }
}
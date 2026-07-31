import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class AssignmentForm extends StatelessWidget {

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  final String department;
  final String? semester;
  final String subject;

  final DateTime? dueDate;

  final VoidCallback onSelectDate;


  const AssignmentForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.department,
    required this.semester,
    required this.subject,
    required this.dueDate,
    required this.onSelectDate,
  });


  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600;

    final horizontalPadding =
        isTablet ? 24.0 : width * 0.04;

    final titleSize =
        isTablet ? 18.0 : width * 0.042;


    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,


        children: [


          /// Department Information Card
          Card(

            elevation: 3,

            shape: RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                    isTablet ? 20 : 16,
                  ),
            ),


            child: Padding(

              padding:
                  EdgeInsets.all(
                    isTablet ? 18 : 12,
                  ),

              child: Row(

                children: [

                  CircleAvatar(

                    radius:
                        isTablet ? 28 : 22,

                    backgroundColor:
                        AppTheme.primary,


                    child: Icon(

                      Icons.school,

                      color: Colors.white,

                      size:
                          isTablet ? 30 : 24,
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

                          department,

                          style: TextStyle(

                            fontSize:
                                titleSize,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),


                        const SizedBox(
                          height: 4,
                        ),


                        Text(

                          "Semester $semester • $subject",

                          maxLines: 2,

                          overflow:
                              TextOverflow.ellipsis,

                          style: TextStyle(

                            fontSize:
                                isTablet ? 15 : 13,

                            color:
                                Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),



          SizedBox(
            height:
                width * 0.05,
          ),



          _label(
            "Assignment Title",
          ),


          const SizedBox(
            height: 8,
          ),



          _inputField(

            controller:
                titleController,

            hint:
                "Enter assignment title",

            maxLines:
                1,
          ),




          SizedBox(
            height:
                width * 0.045,
          ),




          _label(
            "Description",
          ),



          const SizedBox(
            height: 8,
          ),



          _inputField(

            controller:
                descriptionController,

            hint:
                "Enter assignment description",

            maxLines:
                isTablet ? 8 : 5,
          ),




          SizedBox(
            height:
                width * 0.045,
          ),




          _label(
            "Due Date",
          ),



          const SizedBox(
            height: 8,
          ),




          InkWell(

            onTap:
                onSelectDate,


            borderRadius:
                BorderRadius.circular(14),



            child: Container(

              padding:
                  EdgeInsets.symmetric(

                    horizontal:
                        isTablet ? 20 : 16,

                    vertical:
                        isTablet ? 18 : 15,
                  ),


              decoration:
                  BoxDecoration(

                    color:
                        Colors.white,


                    borderRadius:
                        BorderRadius.circular(14),


                    border:
                        Border.all(

                          color:
                              Colors.grey.shade300,
                        ),
                  ),



              child: Row(

                children: [


                  Icon(

                    Icons.calendar_today,

                    color:
                        AppTheme.primary,

                    size:
                        isTablet ? 26 : 22,
                  ),



                  SizedBox(
                    width:
                        width * 0.035,
                  ),



                  Expanded(

                    child: Text(

                      dueDate == null

                          ? "Select Due Date"

                          : "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}",



                      style: TextStyle(

                        fontSize:
                            isTablet ? 17 : 15,
                      ),
                    ),
                  ),




                  const Icon(

                    Icons.arrow_forward_ios,

                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _label(String text){

    return Text(

      text,

      style: const TextStyle(

        fontWeight:
            FontWeight.bold,

        fontSize: 15,
      ),
    );
  }





  Widget _inputField({

    required TextEditingController controller,

    required String hint,

    required int maxLines,

  }){


    return TextField(

      controller:
          controller,


      maxLines:
          maxLines,


      decoration:
          InputDecoration(

            hintText:
                hint,


            filled:
                true,


            fillColor:
                Colors.white,


            contentPadding:
                const EdgeInsets.all(16),


            border:
                OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(14),
                ),


            enabledBorder:
                OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(14),

                  borderSide:
                      BorderSide(
                        color:
                            Colors.grey.shade300,
                      ),
                ),
          ),
    );
  }
}
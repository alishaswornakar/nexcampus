import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {

  final String subject;
  final String time;
  final String teacher;
  final String room;


  const ScheduleCard({
    super.key,
    required this.subject,
    required this.time,
    required this.teacher,
    required this.room,
  });



  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;



    final bool isMobile =
        width < 600;


    final bool isTablet =
        width >= 600 &&
        width < 1000;



    final double padding =
        isMobile
            ? 12
            : isTablet
                ? 16
                : 18;



    final double titleSize =
        isMobile
            ? 14
            : isTablet
                ? 16
                : 17;



    final double normalSize =
        isMobile
            ? 12
            : isTablet
                ? 14
                : 15;




    return Container(


      margin: EdgeInsets.only(

        bottom:
            isMobile ? 10 : 14,

      ),



      padding:
          EdgeInsets.all(padding),



      decoration: BoxDecoration(


        color:
            Colors.white,


        borderRadius:
            BorderRadius.circular(14),



        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withValues(
                  alpha: 0.05,
                ),

            blurRadius:
                6,

            offset:
                const Offset(0,3),

          ),

        ],

      ),




      child: Row(


        crossAxisAlignment:
            CrossAxisAlignment.start,


        children: [



          Expanded(


            flex: 3,


            child: Column(


              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children: [



                Text(

                  subject,


                  maxLines:
                      2,


                  overflow:
                      TextOverflow.ellipsis,


                  style: TextStyle(

                    fontWeight:
                        FontWeight.bold,


                    fontSize:
                        titleSize,

                  ),

                ),




                const SizedBox(
                  height: 5,
                ),




                Text(

                  time,


                  maxLines:
                      1,


                  overflow:
                      TextOverflow.ellipsis,


                  style: TextStyle(

                    fontSize:
                        normalSize,


                    color:
                        Colors.grey.shade700,

                  ),

                ),



              ],


            ),


          ),





          SizedBox(

            width:
                isMobile ? 10 : 20,

          ),





          Expanded(


            flex: 2,


            child: Column(


              crossAxisAlignment:
                  CrossAxisAlignment.end,


              children: [



                Text(

                  teacher,


                  maxLines:
                      2,


                  overflow:
                      TextOverflow.ellipsis,


                  textAlign:
                      TextAlign.right,


                  style: TextStyle(

                    fontSize:
                        normalSize,


                    fontWeight:
                        FontWeight.w500,

                  ),

                ),





                const SizedBox(
                  height: 5,
                ),




                Text(

                  "Rm $room",


                  maxLines:
                      1,


                  overflow:
                      TextOverflow.ellipsis,


                  style: TextStyle(

                    fontSize:
                        normalSize,


                    color:
                        Colors.grey.shade700,

                  ),

                ),



              ],


            ),


          ),



        ],


      ),


    );

  }

}
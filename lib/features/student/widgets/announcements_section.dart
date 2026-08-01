import 'package:flutter/material.dart';

class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet =
        width >= 600 && width < 1000;


    final double titleSize =
        isMobile
            ? 18
            : isTablet
                ? 20
                : 22;


    final double horizontalPadding =
        isMobile
            ? 0
            : isTablet
                ? 8
                : 12;



    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [


          Text(
            "Announcements",

            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),


          SizedBox(
            height:
                isMobile ? 10 : 14,
          ),



          Container(

            width: double.infinity,


            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                    isMobile ? 12 : 16,
                  ),


              boxShadow: [

                BoxShadow(

                  color:
                      Colors.black
                          .withValues(
                            alpha: 0.05,
                          ),

                  blurRadius: 8,

                  offset:
                      const Offset(0, 3),

                ),

              ],

            ),



            child: Column(

              children: [


                _AnnouncementTile(

                  icon:
                      Icons.info,

                  iconColor:
                      Colors.blue,

                  title:
                      "Mid-Semester Exams start from Nov 15th",

                ),



                const Divider(
                  height: 1,
                ),



                _AnnouncementTile(

                  icon:
                      Icons.warning,

                  iconColor:
                      Colors.red,

                  title:
                      "Hostel Fees due by Oct 31st",

                ),



                const Divider(
                  height: 1,
                ),



                _AnnouncementTile(

                  icon:
                      Icons.campaign,

                  iconColor:
                      Colors.orange,

                  title:
                      "College fest registration closes this Friday",

                ),

              ],

            ),
          ),
        ],
      ),
    );
  }
}



class _AnnouncementTile extends StatelessWidget {

  final IconData icon;

  final Color iconColor;

  final String title;



  const _AnnouncementTile({

    required this.icon,

    required this.iconColor,

    required this.title,

  });



  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;


    final bool isMobile =
        width < 600;



    return Padding(

      padding:
          EdgeInsets.symmetric(

            horizontal:
                isMobile ? 12 : 18,

            vertical:
                isMobile ? 4 : 8,

          ),


      child: Row(

        children: [


          CircleAvatar(

            radius:
                isMobile ? 18 : 22,


            backgroundColor:
                iconColor.withValues(
                  alpha: 0.12,
                ),


            child:
                Icon(

              icon,

              color:
                  iconColor,

              size:
                  isMobile ? 18 : 22,

            ),

          ),



          SizedBox(

            width:
                isMobile ? 12 : 16,

          ),



          Expanded(

            child: Text(

              title,

              maxLines:
                  2,

              overflow:
                  TextOverflow.ellipsis,


              style:
                  TextStyle(

                fontSize:
                    isMobile ? 14 : 15,

                fontWeight:
                    FontWeight.w500,

              ),

            ),

          ),



          const Icon(

            Icons.chevron_right,

            color:
                Colors.grey,

          ),

        ],

      ),

    );

  }
}
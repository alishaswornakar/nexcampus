import 'package:flutter/material.dart';

class QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });


  static const _tileColor = Color(0xFFE9EBF8);
  static const _iconColor = Color(0xFF1B4F9B);



  @override
  Widget build(BuildContext context) {


    final width = MediaQuery.of(context).size.width;


    final bool isSmallPhone = width < 400;

    final bool isTablet =
        width >= 600 && width < 1100;



    final double padding =
        isSmallPhone
            ? 10
            : isTablet
                ? 16
                : 14;



    final double radius =
        isSmallPhone
            ? 14
            : 16;



    final double iconRadius =
        isSmallPhone
            ? 16
            : isTablet
                ? 22
                : 18;



    final double iconSize =
        isSmallPhone
            ? 16
            : isTablet
                ? 22
                : 18;



    final double textSize =
        isSmallPhone
            ? 12
            : isTablet
                ? 15
                : 13;



    final double spacing =
        isSmallPhone
            ? 8
            : 10;



    return InkWell(

      onTap: onTap,

      borderRadius:
          BorderRadius.circular(radius),


      child: Container(

        padding:
            EdgeInsets.all(padding),


        decoration: BoxDecoration(

          color: _tileColor,

          borderRadius:
              BorderRadius.circular(radius),

        ),



        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,


          mainAxisAlignment:
              MainAxisAlignment.center,


          children: [



            CircleAvatar(

              radius: iconRadius,

              backgroundColor:
                  Colors.white,


              child: Icon(

                icon,

                color:
                    _iconColor,

                size:
                    iconSize,

              ),

            ),



            SizedBox(
              height: spacing,
            ),




            Text(

              label,


              maxLines: 2,

              overflow:
                  TextOverflow.ellipsis,


              style: TextStyle(

                fontSize:
                    textSize,


                fontWeight:
                    FontWeight.w600,


                color:
                    const Color(0xFF1A1A1A),

              ),

            ),


          ],

        ),

      ),

    );

  }
}
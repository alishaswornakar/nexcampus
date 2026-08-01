import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/authentication/services/auth_service.dart';
import 'package:nexcampus_app/features/authentication/services/auth_wrapper.dart';

import 'package:nexcampus_app/features/student/blocs/notification/bloc/notification_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/notification/bloc/notification_event.dart';
import 'package:nexcampus_app/features/student/blocs/notification/widgets/notification_bell.dart';


class StudentAppBar extends StatelessWidget implements PreferredSizeWidget {

  final String studentId;

  const StudentAppBar({
    super.key,
    required this.studentId,
  });


  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);


  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;


    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;


    final double titleSize =
        isMobile
            ? 14
            : isTablet
                ? 16
                : 18;


    final double logoRadius =
        isMobile
            ? 16
            : isTablet
                ? 18
                : 20;


    final double actionSpacing =
        isMobile
            ? 4
            : 10;



    return AppBar(

      backgroundColor: AppTheme.primary,

      elevation: 0,


      titleSpacing: isMobile ? 4 : 8,


      title: Text(
        "Student Dashboard",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,

        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: titleSize,
        ),
      ),



      leading: Padding(
        padding: EdgeInsets.all(
          isMobile ? 8 : 6,
        ),

        child: CircleAvatar(

          radius: logoRadius,

          backgroundColor:
              Colors.white24,

          child: ClipOval(
            child: Image.asset(
              "assets/images/App_image.png",

              fit: BoxFit.cover,

              width:
                  logoRadius * 2,

              height:
                  logoRadius * 2,
            ),
          ),
        ),
      ),



      actions: [


        BlocProvider(
          create: (_) =>
              NotificationBloc()
                ..add(
                  NotificationSubscribeRequested(
                    studentId,
                  ),
                ),

          child: const NotificationBell(),
        ),



        SizedBox(
          width: actionSpacing,
        ),



        if (!isMobile)

          const Icon(
            Icons.mail_outline,
            color: Colors.white,
          ),



        if (!isMobile)

          SizedBox(
            width: actionSpacing,
          ),



        IconButton(

          padding:
              EdgeInsets.zero,

          constraints:
              const BoxConstraints(),

          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),

          onPressed: () {

            _showLogoutDialog(
              context,
            );

          },
        ),



        SizedBox(
          width: isMobile ? 8 : 12,
        ),
      ],
    );
  }




  void _showLogoutDialog(
      BuildContext context,
  ) {


    showDialog(

      context: context,

      builder: (_) => AlertDialog(

        title:
            const Text(
              "Logout",
            ),


        content:
            const Text(
              "Are you sure you want to logout?",
            ),



        actions: [


          TextButton(

            onPressed: () async {

              Navigator.of(
                context,
                rootNavigator: true,
              ).pop();


              await AuthService()
                  .signOut();



              if(context.mounted){

                Navigator.pushAndRemoveUntil(

                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const AuthWrapper(),
                  ),

                  (route)=>false,

                );

              }

            },


            child:
                const Text(
                  "Logout",

                  style:
                      TextStyle(
                        color:
                            Colors.red,
                      ),
                ),

          ),




          ElevatedButton(

            onPressed: () {

              Navigator.pop(
                context,
              );

            },


            style:
                ElevatedButton.styleFrom(

              backgroundColor:
                  AppTheme.primary,

              foregroundColor:
                  Colors.white,

            ),


            child:
                const Text(
                  "Cancel",
                ),

          ),


        ],

      ),

    );

  }
}
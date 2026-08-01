import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../../student/screens/student_dashboard_screen.dart';
import 'package:nexcampus_app/features/student/blocs/question_bank/screens/question_bank_screen.dart';
import 'package:nexcampus_app/features/student/blocs/courses/screens/courses_screen.dart';
import 'package:nexcampus_app/features/student/blocs/user_profile/screens/user_profile_screen.dart';



class AppBottomNavBar extends StatelessWidget {

  final int currentIndex; 
  // 0 = Home
  // 1 = Courses
  // 2 = QNB
  // 3 = Profile


  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
  });



  static const Color _primary =
      AppTheme.primary;



  void _onTap(
    BuildContext context,
    int index,
  ) {

    final user =
        FirebaseAuth.instance.currentUser;


    if(index == currentIndex){
      return;
    }



    switch(index){


      case 0:

        if(user != null){

          Navigator.pushAndRemoveUntil(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  StudentDashboardScreen(
                    user: user,
                  ),

            ),

            (route)=>false,

          );

        }

        break;



      case 1:

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) =>
                const CoursesScreen(),

          ),

        );

        break;



      case 2:

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) =>
                const QuestionBankScreen(),

          ),

        );

        break;



      case 3:

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) =>
                const UserProfileScreen(),

          ),

        );

        break;

    }

  }




  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;


    final bottom =
        MediaQuery.of(context).padding.bottom;



    final bool isSmall =
        width < 360;



    final double height =
        isSmall ? 62 : 72;



    return SizedBox(

      height:
          height + bottom,


      child: Container(

        padding:
            EdgeInsets.only(
              bottom: bottom,
            ),


        decoration:
            BoxDecoration(

          color:
              _primary,


          boxShadow: [

            BoxShadow(

              color:
                  Colors.black.withValues(
                    alpha: 0.15,
                  ),

              blurRadius:
                  12,

              offset:
                  const Offset(
                    0,
                    -3,
                  ),

            ),

          ],

        ),



        child: Row(

          children: [


            _NavItem(

              icon:
                  Icons.home_outlined,

              activeIcon:
                  Icons.home,

              label:
                  "Home",

              active:
                  currentIndex == 0,

              onTap:
                  ()=>_onTap(
                    context,
                    0,
                  ),

            ),




            _NavItem(

              icon:
                  Icons.library_books_outlined,

              activeIcon:
                  Icons.library_books,

              label:
                  "Courses",

              active:
                  currentIndex == 1,

              onTap:
                  ()=>_onTap(
                    context,
                    1,
                  ),

            ),




            _NavItem(

              icon:
                  Icons.menu_book_outlined,

              activeIcon:
                  Icons.menu_book,

              label:
                  "QNB",

              active:
                  currentIndex == 2,

              onTap:
                  ()=>_onTap(
                    context,
                    2,
                  ),

            ),




            _NavItem(

              icon:
                  Icons.person_outline,

              activeIcon:
                  Icons.person,

              label:
                  "Profile",

              active:
                  currentIndex == 3,

              onTap:
                  ()=>_onTap(
                    context,
                    3,
                  ),

            ),


          ],

        ),

      ),

    );

  }

}






class _NavItem extends StatelessWidget {


  final IconData icon;

  final IconData activeIcon;

  final String label;

  final bool active;

  final VoidCallback onTap;



  const _NavItem({

    required this.icon,

    required this.activeIcon,

    required this.label,

    required this.active,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;



    final bool isSmall =
        width < 360;



    final double iconSize =
        isSmall ? 20 : 24;



    final double textSize =
        isSmall ? 8 : 10;




    return Expanded(

      child: InkWell(

        onTap:
            onTap,


        splashColor:
            Colors.white24,


        highlightColor:
            Colors.white10,



        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,


          children: [


            AnimatedContainer(

              duration:
                  const Duration(
                    milliseconds: 200,
                  ),


              padding:
                  EdgeInsets.all(
                    active ? 6 : 0,
                  ),


              decoration:
                  BoxDecoration(

                color:
                    active

                        ? Colors.white24

                        : Colors.transparent,


                shape:
                    BoxShape.circle,

              ),


              child: Icon(

                active
                    ? activeIcon
                    : icon,


                size:
                    iconSize,


                color:
                    active

                        ? Colors.white

                        : Colors.white60,

              ),

            ),



            const SizedBox(
              height: 3,
            ),




            Text(

              label,


              maxLines:
                  1,


              overflow:
                  TextOverflow.ellipsis,


              style:
                  TextStyle(

                fontSize:
                    textSize,


                color:
                    active

                        ? Colors.white

                        : Colors.white60,


                fontWeight:
                    active

                        ? FontWeight.w700

                        : FontWeight.normal,

              ),

            ),


          ],

        ),

      ),

    );

  }

}
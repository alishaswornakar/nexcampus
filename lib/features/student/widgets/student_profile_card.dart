import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StudentProfileCard extends StatefulWidget {

  final User user;

  const StudentProfileCard({
    super.key,
    required this.user,
  });


  @override
  State<StudentProfileCard> createState() =>
      _StudentProfileCardState();
}



class _StudentProfileCardState
    extends State<StudentProfileCard> {


  File? _profileImage;



  @override
  void initState() {

    super.initState();

    _loadProfileImage();

  }




  Future<void> _pickImage() async {


    final picker = ImagePicker();


    final XFile? pickedFile =
        await picker.pickImage(
          source: ImageSource.gallery,
        );


    if(pickedFile != null){

      setState(() {

        _profileImage =
            File(pickedFile.path);

      });



      final prefs =
          await SharedPreferences.getInstance();


      await prefs.setString(
        'profile_image',
        pickedFile.path,
      );

    }

  }




  Future<void> _loadProfileImage() async {


    final prefs =
        await SharedPreferences.getInstance();


    final path =
        prefs.getString(
          'profile_image',
        );


    if(path != null &&
        File(path).existsSync()){

      setState(() {

        _profileImage =
            File(path);

      });

    }

  }





  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;


    final bool isMobile =
        width < 600;


    final bool isTablet =
        width >= 600 &&
        width < 1000;



    final double avatarRadius =
        isMobile
            ? 30
            : isTablet
                ? 40
                : 50;



    final double attendanceSize =
        isMobile
            ? 65
            : isTablet
                ? 75
                : 85;



    final double titleSize =
        isMobile
            ? 16
            : 18;



    return StreamBuilder<
        DocumentSnapshot<Map<String,dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user.uid)
              .snapshots(),


      builder:(context,snapshot){


        final data =
            snapshot.data?.data();



        final name =
            data?['fullName'] ??
            widget.user.displayName ??
            'Student';



        final email =
            data?['email'] ??
            widget.user.email ??
            '';



        final department =
            data?['department'] ??
            'Not set';



        final semester =
            data?['semester']
                ?.toString() ??
            'Not set';



        final roll =
            data?['roll']
                ?.toString();



        final attendancePercent =
            data?['attendancePercent'] ??
            0;





        return Center(

          child: ConstrainedBox(

            constraints:
                const BoxConstraints(
                  maxWidth:700,
                ),


            child: Container(


              padding:
                  EdgeInsets.all(
                    isMobile
                        ? 14
                        : 20,
                  ),


              decoration:
                  BoxDecoration(

                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                      18,
                    ),

              ),




              child:
                  isMobile

                  ? Column(

                      children:[

                        _profileAvatar(
                          avatarRadius,
                        ),


                        const SizedBox(
                          height:14,
                        ),


                        _studentInfo(
                          name,
                          email,
                          roll,
                          department,
                          semester,
                          titleSize,
                        ),


                        const SizedBox(
                          height:16,
                        ),


                        _attendanceCircle(
                          attendanceSize,
                          attendancePercent,
                        ),

                      ],

                    )



                  : Row(

                      children:[


                        _profileAvatar(
                          avatarRadius,
                        ),



                        SizedBox(
                          width:
                              isTablet
                                  ? 18
                                  : 25,
                        ),



                        Expanded(

                          child:
                              _studentInfo(
                                name,
                                email,
                                roll,
                                department,
                                semester,
                                titleSize,
                              ),

                        ),




                        _attendanceCircle(
                          attendanceSize,
                          attendancePercent,
                        ),

                      ],

                    ),


            ),

          ),

        );

      },

    );

  }






  Widget _profileAvatar(
      double radius,
      ){

    return GestureDetector(

      onTap:_pickImage,


      child: CircleAvatar(

        radius:radius,


        backgroundImage:
            _profileImage != null

            ? FileImage(
                _profileImage!,
              )


            : widget.user.photoURL != null

                ? NetworkImage(
                    widget.user.photoURL!,
                  )

                : null,



        backgroundColor:
            Colors.blue.shade100,



        child:
            _profileImage == null &&
            widget.user.photoURL == null

            ? Icon(
                Icons.person,
                size:radius,
                color:Colors.blue,
              )

            : null,

      ),

    );

  }







  Widget _studentInfo(
      String name,
      String email,
      String? roll,
      String department,
      String semester,
      double titleSize,
      ){


    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,


      children:[


        Text(

          name,

          maxLines:1,

          overflow:
              TextOverflow.ellipsis,


          style:
              TextStyle(

            fontSize:titleSize,

            fontWeight:
                FontWeight.bold,

          ),

        ),



        const SizedBox(
          height:4,
        ),



        Text(

          email,

          maxLines:1,

          overflow:
              TextOverflow.ellipsis,

        ),



        if(roll != null &&
            roll.isNotEmpty)

          Text(
            "Roll: $roll",
            maxLines:1,
            overflow:
                TextOverflow.ellipsis,
          ),



        Text(
          "Department: $department",
          maxLines:2,
          overflow:
              TextOverflow.ellipsis,
        ),



        Text(
          "Semester: $semester",
        ),


      ],

    );


  }







  Widget _attendanceCircle(
      double size,
      dynamic percentage,
      ){


    return Container(

      width:size,

      height:size,


      decoration:
          const BoxDecoration(

        shape:
            BoxShape.circle,

        color:
            Color(0xFFE6F0FF),

      ),


      child:
          Center(

        child: Text(

          "$percentage%",

          style:
              TextStyle(

            color:
                Colors.blue,

            fontWeight:
                FontWeight.bold,

            fontSize:
                size/4,

          ),

        ),

      ),

    );


  }


}
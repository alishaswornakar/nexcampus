import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/repository/teacher_notice_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/services/teacher_notice_service.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/blocs/bloc/notices_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/blocs/bloc/notices_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/blocs/bloc/notices_state.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/screens/notice_detail_screen.dart';

import '../blocs/notices/screens/notices_screen.dart';



class RecentNoticesSection extends StatelessWidget {

  const RecentNoticesSection({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    return LayoutBuilder(

      builder: (context,constraints){


        final width = constraints.maxWidth;


        final bool isMobile = width < 600;

        final bool isTablet =
            width >= 600 && width < 1000;



        final double titleSize =
            isMobile
                ? 18
                : isTablet
                    ? 20
                    : 22;



        return Center(

          child: ConstrainedBox(

            constraints:
                const BoxConstraints(
                  maxWidth: 900,
                ),


            child: BlocProvider(


              create: (_) => NoticeBloc(

                TeacherNoticeRepository(
                  TeacherNoticeService(),
                ),

              )..add(
                  LoadNoticesEvent(),
                ),



              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,


                children: [



                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,


                    children: [


                      Text(

                        "Recent Notices",


                        style: TextStyle(

                          fontSize:
                              titleSize,


                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),



                      TextButton(

                        onPressed: () =>

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const NoticesScreen(),

                              ),

                            ),


                        child: const Text(
                          "VIEW ALL",
                        ),

                      ),


                    ],

                  ),




                  SizedBox(

                    height:
                        isMobile ? 6 : 10,

                  ),




                  BlocBuilder<NoticeBloc, NoticeState>(

                    builder:
                        (context,state){


                      if(
                        state is NoticeLoading ||
                        state is NoticeInitial
                      ){

                        return const Padding(

                          padding:
                              EdgeInsets.symmetric(
                                vertical: 16,
                              ),


                          child: Center(

                            child:
                                CircularProgressIndicator(

                                  color:
                                      AppTheme.primary,

                                  strokeWidth:
                                      2,

                                ),

                          ),

                        );

                      }




                      if(state is NoticeError){

                        return Padding(

                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),


                          child: Text(

                            state.message,


                            style:
                                const TextStyle(

                                  color:
                                      Colors.red,

                                  fontSize:
                                      13,

                                ),

                          ),

                        );

                      }





                      if(state is NoticesLoaded){


                        if(state.notices.isEmpty){

                          return const Padding(

                            padding:
                                EdgeInsets.symmetric(
                                  vertical: 8,
                                ),


                            child: Text(

                              "No notices yet",

                              style:
                                  TextStyle(

                                    color:
                                        AppTheme.textSecondary,

                                  ),

                            ),

                          );

                        }



                        final preview =
                            state.notices
                                .take(2)
                                .toList();



                        return Column(

                          children: [

                            for(final notice in preview)...[


                              _RecentNoticeTile(

                                notice:
                                    notice,

                              ),



                              SizedBox(

                                height:
                                    isMobile ? 10 : 14,

                              ),

                            ],

                          ],

                        );


                      }



                      return const SizedBox();


                    },

                  ),



                ],

              ),

            ),

          ),

        );


      },

    );

  }

}
class _RecentNoticeTile extends StatelessWidget {

  final TeacherNoticeModel notice;


  const _RecentNoticeTile({
    required this.notice,
  });



  String get _relativeTime {

    final diff =
        DateTime.now()
            .difference(notice.createdAt);


    if(diff.inMinutes < 1){
      return "Just now";
    }


    if(diff.inMinutes < 60){
      return "${diff.inMinutes}m ago";
    }


    if(diff.inHours < 24){
      return "${diff.inHours}h ago";
    }


    if(diff.inDays == 1){
      return "Yesterday";
    }


    if(diff.inDays < 7){
      return "${diff.inDays}d ago";
    }


    return
        "${notice.createdAt.day}/"
        "${notice.createdAt.month}/"
        "${notice.createdAt.year}";

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



    final double cardPadding =
        isMobile
            ? 12
            : isTablet
                ? 16
                : 18;



    final double iconRadius =
        isMobile
            ? 20
            : isTablet
                ? 24
                : 26;



    final double iconSize =
        isMobile
            ? 18
            : isTablet
                ? 22
                : 24;



    final double titleSize =
        isMobile
            ? 14
            : isTablet
                ? 16
                : 17;



    final double subtitleSize =
        isMobile
            ? 12
            : 13;



    final iconColor =
        notice.isPinned
            ? Colors.red
            : AppTheme.secondary;



    final icon =
        notice.isPinned
            ? Icons.push_pin
            : Icons.campaign;




    return InkWell(

      borderRadius:
          BorderRadius.circular(16),


      onTap: () =>

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  NoticeDetailScreen(
                    notice: notice,
                  ),

            ),

          ),



      child: Container(

        padding:
            EdgeInsets.all(cardPadding),


        decoration: BoxDecoration(

          color:
              const Color(0xFFEDEFF9),


          borderRadius:
              BorderRadius.circular(16),


        ),



        child: Row(

          crossAxisAlignment:
              CrossAxisAlignment.center,


          children: [



            CircleAvatar(

              radius:
                  iconRadius,


              backgroundColor:
                  iconColor.withValues(
                    alpha: 0.15,
                  ),


              child: Icon(

                icon,

                color:
                    iconColor,

                size:
                    iconSize,

              ),

            ),



            SizedBox(

              width:
                  isMobile ? 12 : 16,

            ),




            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,


                children: [



                  Text(

                    notice.title,


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
                    height: 4,
                  ),





                  Text(

                    "${notice.teacherName} • $_relativeTime",


                    maxLines:
                        1,


                    overflow:
                        TextOverflow.ellipsis,


                    style: TextStyle(

                      fontSize:
                          subtitleSize,


                      color:
                          AppTheme.textSecondary,

                    ),

                  ),



                ],

              ),

            ),





            SizedBox(

              width:
                  isMobile ? 4 : 8,

            ),




            Icon(

              Icons.chevron_right,


              color:
                  Colors.grey,


              size:
                  isMobile ? 22 : 26,

            ),



          ],

        ),

      ),

    );

  }

}
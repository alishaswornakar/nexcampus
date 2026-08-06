import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/screens/notice_detail_screen.dart';

import '../blocs/bloc/notices_bloc.dart';
import '../blocs/bloc/notices_event.dart';
import '../blocs/bloc/notices_state.dart';
import '../repository/teacher_notice_repository.dart';
import '../services/teacher_notice_service.dart';
import '../widgets/notice_tile.dart';
import 'add_notice_screen.dart';


class NoticeScreen extends StatelessWidget {

  const NoticeScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {


    final width = MediaQuery.of(context).size.width;


    final horizontalPadding =
        width < 600
            ? 12.0
            : width < 1000
                ? 24.0
                : 40.0;



    return BlocProvider(

      create: (_) => NoticeBloc(
        TeacherNoticeRepository(
          TeacherNoticeService(),
        ),
      )..add(
          LoadNoticesEvent(),
        ),


      child: Scaffold(

        backgroundColor:
            const Color(0xffF5F7FA),



        appBar: AppBar(

          title: Text(

            "Notices",

            style: TextStyle(

              fontSize:
                  width < 600 ? 20 : 24,

              fontWeight:
                  FontWeight.bold,
            ),
          ),


          centerTitle:true,


          backgroundColor:
              AppTheme.primary,


          foregroundColor:
              Colors.white,
        ),




        floatingActionButton:
        Builder(

          builder:(context){


            return FloatingActionButton.extended(


              backgroundColor:
                  AppTheme.primary,


              foregroundColor:
                  Colors.white,


              icon:
                  const Icon(
                    Icons.add,
                  ),



              label:

              Text(

                width < 400
                    ? "Add"
                    : "Add Notice",

                style:
                    const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
              ),



              onPressed:() async {


               await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<NoticeBloc>(),
      child: const AddNoticeScreen(),
    ),
  ),
);

// ignore: use_build_context_synchronously
context.read<NoticeBloc>().add(
  LoadNoticesEvent(),
);
              },

            );

          },

        ),




        body:

        BlocConsumer<NoticeBloc, NoticeState>(


          listener:(context,state){


            if(state is NoticeDeleted){


              ScaffoldMessenger.of(context)
                  .showSnackBar(

                const SnackBar(

                  content:
                      Text(
                        "Notice deleted successfully",
                      ),


                  backgroundColor:
                      Colors.green,
                ),

              );

            }



            if(state is NoticeError){


              ScaffoldMessenger.of(context)
                  .showSnackBar(

                SnackBar(

                  content:
                      Text(
                        state.message,
                      ),


                  backgroundColor:
                      Colors.red,

                ),

              );

            }


          },





          builder:(context,state){



            if(state is NoticeLoading){


              return const Center(

                child:
                    CircularProgressIndicator(),

              );


            }




            if(state is NoticesLoaded){



              if(state.notices.isEmpty){


                return const Center(

                  child:Column(

                    mainAxisAlignment:
                        MainAxisAlignment.center,


                    children:[


                      Icon(

                        Icons.campaign_outlined,

                        size:80,

                        color:
                            Colors.grey,
                      ),



                      SizedBox(
                        height:15,
                      ),



                      Text(

                        "No Notices Found",

                        style:
                            TextStyle(

                              fontSize:18,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                      )

                    ],
                  ),

                );


              }





              return RefreshIndicator(


                onRefresh:() async {


                  context.read<NoticeBloc>()
                      .add(
                        LoadNoticesEvent(),
                      );


                },



                child:

                Center(

                  child:

                  ConstrainedBox(

                    constraints:

                    BoxConstraints(

                      maxWidth:

                      width > 1200
                          ? 900
                          : double.infinity,

                    ),



                    child:

                    ListView.builder(


                      physics:
                          const AlwaysScrollableScrollPhysics(),


                      padding:

                      EdgeInsets.symmetric(

                        horizontal:
                            horizontalPadding,


                        vertical:
                            width < 600
                                ? 12
                                : 20,

                      ),




                      itemCount:
                          state.notices.length,




                      itemBuilder:(context,index){


                        final notice =
                            state.notices[index];



                        return NoticeTile(


                          notice:
                              notice,



                          onTap:(){



                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder:(_)=>

                                NoticeDetailScreen(

                                  notice:
                                      notice,

                                ),

                              ),

                            );

                          },




                          onDelete:(){


                            context
                                .read<NoticeBloc>()
                                .add(

                              DeleteNoticeEvent(
                                notice.id,
                              ),

                            );


                          },




                          onPin:(){



                            context
                                .read<NoticeBloc>()
                                .add(

                              ToggleNoticePinEvent(

                                noticeId:
                                    notice.id,


                                isPinned:
                                    !notice.isPinned,

                              ),

                            );


                          },




                          onEdit:(){



                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder:(_)=>

                                BlocProvider.value(

                                  value:
                                      context.read<NoticeBloc>(),


                                  child:

                                  AddNoticeScreen(

                                    notice:
                                        notice,

                                  ),

                                ),

                              ),

                            );


                          },


                        );


                      },

                    ),

                  ),

                ),

              );

            }




            return const SizedBox();

          },

        ),

      ),

    );

  }

}
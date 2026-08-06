import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/notice_model.dart';

class NoticeTile extends StatelessWidget {
  final TeacherNoticeModel notice;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onTap;

  const NoticeTile({
    super.key,
    required this.notice,
    required this.onEdit,
    required this.onDelete,
    required this.onPin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final horizontalPadding =
        width < 600 ? 14.0 : width < 1000 ? 20.0 : 24.0;

    final titleSize =
        width < 600 ? 18.0 : width < 1000 ? 21.0 : 24.0;

    final bodySize =
        width < 600 ? 14.0 : 16.0;

    final avatarSize =
        width < 600 ? 18.0 : 22.0;


    return Card(
      margin: EdgeInsets.only(
        bottom: width < 600 ? 12 : 18,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          width < 600 ? 14 : 18,
        ),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,

        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

            /// TOP ACTION ROW
Row(
  children: [
    if (notice.isPinned)
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.push_pin,
              color: AppTheme.primary,
              size: 16,
            ),
            SizedBox(width: 5),
            Text(
              "Pinned",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

    const Spacer(),

    PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case "edit":
            onEdit();
            break;
          case "pin":
            onPin();
            break;
          case "delete":
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: "edit",
          child: Text("Edit"),
        ),
        PopupMenuItem(
          value: "pin",
          child: Text(
            notice.isPinned ? "Unpin" : "Pin",
          ),
        ),
        const PopupMenuItem(
          value: "delete",
          child: Text("Delete"),
        ),
      ],
    ),
  ],
),


              SizedBox(
                height:
                width <600 ?12:18,
              ),


              /// TITLE

              Text(
                notice.title,

                maxLines:2,
                overflow:
                TextOverflow.ellipsis,

                style:TextStyle(
                  fontSize:titleSize,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),


              const SizedBox(height:10),


              /// DESCRIPTION

              Text(
                notice.description,

                maxLines:4,

                overflow:
                TextOverflow.ellipsis,

                style:TextStyle(
                  fontSize:bodySize,
                  color:
                  Colors.grey.shade700,
                ),
              ),



              const SizedBox(height:18),



              /// POSTED BY

              Row(

                children:[

                  Icon(
                    Icons.person,
                    color:
                    AppTheme.primary,
                    size:
                    avatarSize,
                  ),

                  const SizedBox(width:8),


                  Expanded(
                    child:Text(
                      "Posted by ${notice.teacherName}",

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ),

                ],
              ),



              /// ATTACHMENT

              if(notice.attachmentName!=null &&
                  notice.attachmentName!.isNotEmpty)...[


                const SizedBox(height:12),


                InkWell(

                  onTap:(){

                    if(notice.attachmentUrl!=null){

                      launchUrl(
                        Uri.parse(
                          notice.attachmentUrl!,
                        ),
                      );

                    }

                  },


                  child:Container(

                    padding:
                    const EdgeInsets.all(10),


                    decoration:BoxDecoration(

                      color:
                      Colors.grey.shade100,

                      borderRadius:
                      BorderRadius.circular(10),
                    ),


                    child:Row(

                      children:[


                        const Icon(
                          Icons.picture_as_pdf,
                          color:Colors.red,
                        ),


                        const SizedBox(width:10),



                        Expanded(
                          child:Text(

                            notice.attachmentName!,

                            maxLines:1,

                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        ),



                        const Icon(
                          Icons.open_in_new,
                          size:18,
                        )

                      ],
                    ),
                  ),
                )

              ],



              const Divider(
                height:28,
              ),



              /// FOOTER

              Row(

                children:[


                  CircleAvatar(

                    radius:
                    avatarSize,

                    backgroundColor:
                    AppTheme.primary,

                    foregroundColor:
                    Colors.white,

                    child:
                    const Icon(
                      Icons.person,
                    ),
                  ),



                  const SizedBox(width:10),



                  Expanded(

                    child:Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,


                      children:[


                        Text(

                          notice.teacherName,

                          maxLines:1,

                          overflow:
                          TextOverflow.ellipsis,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),



                        Text(

                          DateFormat(
                            "dd MMM yyyy • hh:mm a",
                          ).format(
                            notice.createdAt,
                          ),


                          style:TextStyle(

                            color:
                            Colors.grey.shade600,

                            fontSize:
                            width <600
                                ?11
                                :13,
                          ),
                        )

                      ],
                    ),
                  )

                ],
              )


            ],
          ),
        ),
      ),
    );
  }
}
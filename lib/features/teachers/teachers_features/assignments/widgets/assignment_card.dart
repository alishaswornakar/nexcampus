import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/assignment_model.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    final isTablet = screenWidth >= 600;

    final horizontalPadding = isTablet
        ? 24.0
        : screenWidth * 0.04;

    final titleSize = isTablet
        ? 20.0
        : screenWidth * 0.045;

    final descriptionSize = isTablet
        ? 16.0
        : screenWidth * 0.035;

    final avatarRadius = isTablet
        ? 26.0
        : screenWidth * 0.055;


    final bool isOverdue =
        assignment.dueDate.isBefore(DateTime.now());


    return Card(
      elevation: 3,
      color: Colors.white,
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          isTablet ? 20 : 16,
        ),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(
          isTablet ? 20 : 16,
        ),
        onTap: onTap,

        child: Padding(
          padding: EdgeInsets.all(
            isTablet ? 20 : screenWidth * 0.04,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              /// HEADER
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  CircleAvatar(
                    radius: avatarRadius,

                    backgroundColor:
                        const Color(0xffE8F0FE),

                    child: Icon(
                      Icons.assignment,
                      size: avatarRadius,
                      color: AppTheme.primary,
                    ),
                  ),


                  SizedBox(
                    width: screenWidth * 0.035,
                  ),


                  Expanded(
                    child: Text(
                      assignment.title,

                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight:
                            FontWeight.w700,
                      ),

                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),


              SizedBox(
                height: screenWidth * 0.035,
              ),


              /// DESCRIPTION
              Text(
                assignment.description,

                maxLines: isTablet ? 3 : 2,

                overflow:
                    TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: descriptionSize,
                  color:
                      Colors.grey.shade700,
                  height: 1.4,
                ),
              ),


              SizedBox(
                height: screenWidth * 0.04,
              ),


              /// FOOTER
              LayoutBuilder(
                builder: (context, constraints) {

                  final smallWidth =
                      constraints.maxWidth < 350;


                  return smallWidth
                      ? Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            _dateWidget(),


                            const SizedBox(
                              height: 10,
                            ),


                            _statusWidget(
                              isOverdue,
                            ),
                          ],
                        )


                      : Row(
                          children: [

                            _dateWidget(),


                            const Spacer(),


                            _statusWidget(
                              isOverdue,
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _dateWidget() {

    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [

        Icon(
          Icons.calendar_today,
          size: 18,
          color:
              Colors.grey.shade700,
        ),

        const SizedBox(
          width: 6,
        ),


        Flexible(
          child: Text(
            DateFormat(
              "dd MMM yyyy",
            ).format(
              assignment.dueDate,
            ),

            overflow:
                TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }



  Widget _statusWidget(bool isOverdue) {

    return Container(

      padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),

      decoration: BoxDecoration(

        color: isOverdue
            ? Colors.red.shade100
            : Colors.green.shade100,


        borderRadius:
            BorderRadius.circular(20),
      ),


      child: Text(

        isOverdue
            ? "Overdue"
            : "Active",


        style: TextStyle(

          color: isOverdue
              ? Colors.red
              : Colors.green,


          fontWeight:
              FontWeight.bold,

          fontSize: 13,
        ),
      ),
    );
  }
}
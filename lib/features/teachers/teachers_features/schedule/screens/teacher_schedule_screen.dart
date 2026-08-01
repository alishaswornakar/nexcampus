import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/model/schedule_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/screens/create_schedule_screen.dart';


import '../repository/schedule_repository.dart';
import '../services/schedule_service.dart';


import 'schedule_detail_screen.dart';

class TeacherScheduleScreen extends StatefulWidget {
  final String department;
  final String semester;

  const TeacherScheduleScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<TeacherScheduleScreen> createState() =>
      _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState
    extends State<TeacherScheduleScreen> {

  final ScheduleRepository repository =
      ScheduleRepository(
    ScheduleService(),
  );

  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

  final List<String> days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {});
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
  }
@override
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  final bool isMobile = width < 600;
  //final bool isTablet = width >= 600 && width < 1000;

  final double horizontalPadding = isMobile ? 16 : 24;
  final double maxWidth = width > 900 ? 800 : double.infinity;

  return Scaffold(
    backgroundColor: const Color(0xffF5F7FA),

    appBar: AppBar(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        "Class Schedule",
        style: TextStyle(
          fontSize: isMobile ? 20 : 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text(
        "Add",
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
        ),
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddScheduleScreen(
              department: widget.department,
              semester: widget.semester,
            ),
          ),
        );

        if (!mounted) return;
        setState(() {});
      },
    ),

    body: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: StreamBuilder<List<ScheduleModel>>(
            stream: repository.getSchedule(
              department: widget.department,
              semester: widget.semester,
            ),
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                  ),
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final schedules =
                  snapshot.data ?? [];

              if (schedules.isEmpty) {
                return ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: isMobile ? 140 : 180),

                    Icon(
                      Icons.schedule,
                      size: isMobile ? 70 : 90,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        "No schedules available",
                        style: TextStyle(
                          fontSize:
                              isMobile ? 18 : 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [

                  Padding(
                    padding: EdgeInsets.all(
                        horizontalPadding),
                    child: TextField(
                      controller:
                          searchController,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Search subject...",
                        prefixIcon:
                            const Icon(
                                Icons.search),
                        filled: true,
                        fillColor:
                            Colors.white,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  15),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText =
                              value.toLowerCase();
                        });
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          horizontalPadding,
                    ),
                    child: Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        "Total Schedules : ${schedules.length}",
                        style: TextStyle(
                          fontSize:
                              isMobile ? 15 : 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            horizontalPadding,
                        vertical: 12,
                      ),
                      itemCount: days.length,
                      itemBuilder:
                          (context, index) {
                        final day =
                            days[index];

                        final daySchedules =
                            schedules.where((schedule) {
                          return schedule.day ==
                                  day &&
                              schedule.subject
                                  .toLowerCase()
                                  .contains(
                                      searchText);
                        }).toList();

                        if (daySchedules.isEmpty) {
                          return const SizedBox();
                        }                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 14,
                                bottom: 12,
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: isMobile
                                      ? 20
                                      : 24,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            ...daySchedules.map(
                              (schedule) {
                                return Card(
                                  elevation: 3,
                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 16,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            18),
                                  ),
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(
                                            18),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ScheduleDetailScreen(
                                            schedule:
                                                schedule,
                                          ),
                                        ),
                                      );

                                      if (!mounted) return;

                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(
                                        isMobile
                                            ? 16
                                            : 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [

                                          /// Header
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [

                                              Container(
                                                padding:
                                                    EdgeInsets.all(
                                                  isMobile
                                                      ? 10
                                                      : 12,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                  color: Colors
                                                      .blue
                                                      .shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14),
                                                ),
                                                child:
                                                    Icon(
                                                  Icons
                                                      .menu_book,
                                                  color:
                                                      AppTheme.primary,
                                                  size: isMobile
                                                      ? 22
                                                      : 24,
                                                ),
                                              ),

                                              const SizedBox(
                                                  width: 14),

                                              Expanded(
                                                child:
                                                    Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [

                                                    Text(
                                                      schedule
                                                          .subject,
                                                      maxLines:
                                                          2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            isMobile
                                                                ? 17
                                                                : 20,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                        height:
                                                            4),

                                                    Text(
                                                      schedule
                                                          .teacherName,
                                                      maxLines:
                                                          2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                        fontSize:
                                                            isMobile
                                                                ? 14
                                                                : 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Icon(
                                                Icons
                                                    .arrow_forward_ios,
                                                size: isMobile
                                                    ? 18
                                                    : 20,
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                              height: 18),

                                          const Divider(),

                                          const SizedBox(
                                              height: 12),

                                                                                    Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                color:
                                                    AppTheme.primary,
                                                size: 20,
                                              ),

                                              const SizedBox(
                                                  width: 8),

                                              Expanded(
                                                child: Text(
                                                  "${TimeOfDay.fromDateTime(schedule.startTime).format(context)} - "
                                                  "${TimeOfDay.fromDateTime(schedule.endTime).format(context)}",
                                                  style:
                                                      TextStyle(
                                                    fontSize:
                                                        isMobile
                                                            ? 14
                                                            : 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                              height: 12),

                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.room,
                                                color:
                                                    AppTheme.primary,
                                                size: 20,
                                              ),

                                              const SizedBox(
                                                  width: 8),

                                              Expanded(
                                                child: Text(
                                                  schedule
                                                      .room,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                  style:
                                                      TextStyle(
                                                    fontSize:
                                                        isMobile
                                                            ? 14
                                                            : 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                              height: 12),

                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.school,
                                                color:
                                                    AppTheme.primary,
                                                size: 20,
                                              ),

                                              const SizedBox(
                                                  width: 8),

                                              Expanded(
                                                child: Text(
                                                  schedule
                                                      .department,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                  style:
                                                      TextStyle(
                                                    fontSize:
                                                        isMobile
                                                            ? 14
                                                            : 15,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(
                                                  width: 8),

                                              Container(
                                                padding:
                                                    EdgeInsets.symmetric(
                                                  horizontal:
                                                      isMobile
                                                          ? 10
                                                          : 12,
                                                  vertical:
                                                      6,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      AppTheme.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: Text(
                                                  "Sem ${schedule.semester}",
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize:
                                                        isMobile
                                                            ? 12
                                                            : 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
    }

                
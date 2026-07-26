import 'package:flutter/material.dart';
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
    
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          "Class Schedule",
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add"),

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

      body: RefreshIndicator(

        onRefresh: _refresh,

        child: StreamBuilder<List<ScheduleModel>>(

          stream: repository.getSchedule(
            department: widget.department,
            semester: widget.semester,
          ),

          builder: (context, snapshot) {
              debugPrint("Connection: ${snapshot.connectionState}");
debugPrint("Has Error: ${snapshot.hasError}");
debugPrint("Error: ${snapshot.error}");
debugPrint("Docs: ${snapshot.data?.length}");

if (snapshot.hasError) {
  return Center(
    child: Text(snapshot.error.toString()),
  );
}

if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                ),
              );
            }

            final schedules =
                snapshot.data ?? [];

            if (schedules.isEmpty) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [

                  SizedBox(height: 170),

                  Icon(
                    Icons.schedule,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Center(
                    child: Text(
                      "No schedules available",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(

              children: [

                Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: TextField(

                    controller: searchController,

                    decoration: InputDecoration(

                      hintText:
                          "Search subject...",

                      prefixIcon:
                          const Icon(Icons.search),

                      filled: true,

                      fillColor: Colors.white,

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
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),

                  child: Align(
                    alignment:
                        Alignment.centerLeft,

                    child: Text(

                      "Total Schedules : ${schedules.length}",

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(

                  child: ListView.builder(

                    padding:
                        const EdgeInsets.all(16),

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
                                .contains(searchText);

                      }).toList();
                      if (daySchedules.isEmpty) {
  return const SizedBox();
}

return Column(
  crossAxisAlignment:
      CrossAxisAlignment.start,

  children: [

    Padding(
      padding: const EdgeInsets.only(
        top: 14,
        bottom: 12,
      ),
      child: Text(
        day,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    ...daySchedules.map(
      (schedule) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(
            bottom: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          child: InkWell(
            borderRadius:
                BorderRadius.circular(18),

            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ScheduleDetailScreen(
                    schedule: schedule,
                  ),
                ),
              );

              if (!mounted) return;

              setState(() {});
            },

            child: Padding(
              padding:
                  const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.all(
                                12),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .blue.shade50,
                          borderRadius:
                              BorderRadius
                                  .circular(14),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Text(
                              schedule.subject,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(
                                height: 4),

                            Text(
                              schedule.teacherName,
                              style: TextStyle(
                                color: Colors
                                    .grey
                                    .shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons
                            .arrow_forward_ios,
                        size: 18,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Divider(),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      const Icon(
                        Icons.access_time,
                        color: Colors.blue,
                        size: 20,
                      ),

                      const SizedBox(width: 6),

                     Text(
  "${TimeOfDay.fromDateTime(schedule.startTime).format(context)} - "
  "${TimeOfDay.fromDateTime(schedule.endTime).format(context)}",

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      const Icon(
                        Icons.room,
                        color: Colors.red,
                        size: 20,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          schedule.room,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      const Icon(
                        Icons.school,
                        color: Colors.green,
                        size: 20,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          schedule.department,
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.blue,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),
                        child: Text(
                          "Sem ${schedule.semester}",
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight.bold,
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
    );
  }
}
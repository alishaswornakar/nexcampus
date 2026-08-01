// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/model/schedule_model.dart';

import '../repository/schedule_repository.dart';
import '../services/schedule_service.dart';

class AddScheduleScreen extends StatefulWidget {
  final String department;
  final String semester;

  final ScheduleModel? schedule;

  const AddScheduleScreen({
    super.key,
    required this.department,
    required this.semester,
    this.schedule,
  });

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  final repository = ScheduleRepository(ScheduleService());

  final subjectController = TextEditingController();

  final teacherController = TextEditingController();

  final roomController = TextEditingController();

  String selectedDay = "Sunday";

  DateTime? startTime;
  DateTime? endTime;

  bool isSaving = false;

  final List<String> days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.schedule != null) {
      subjectController.text = widget.schedule!.subject;

      teacherController.text = widget.schedule!.teacherName;

      roomController.text = widget.schedule!.room;

      selectedDay = widget.schedule!.day;

      startTime = widget.schedule!.startTime;

      endTime = widget.schedule!.endTime;
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    teacherController.dispose();
    roomController.dispose();
    super.dispose();
  }

  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    final now = DateTime.now();

    final selected = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    setState(() {
      if (isStart) {
        startTime = selected;
      } else {
        endTime = selected;
      }
    });
  }

  Future<void> saveSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select class time.")));
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final createdAt = widget.schedule?.createdAt ?? DateTime.now();

      final schedule = ScheduleModel(
        id:
            widget.schedule?.id ??
            FirebaseFirestore.instance.collection("schedules").doc().id,
        subject: subjectController.text.trim(),
        teacherName: teacherController.text.trim(),
        room: roomController.text.trim(),
        department: widget.department,
        semester: widget.semester,
        day: selectedDay,
        startTime: startTime!,
        endTime: endTime!,
        teacherId: '',
        createdAt: createdAt,
      );

      if (widget.schedule == null) {
        await repository.createSchedule(schedule: schedule);
      } else {
        await repository.updateSchedule(schedule: schedule);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            widget.schedule == null ? "Schedule Added" : "Schedule Updated",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
        ? 28.0
        : 40.0;

    final maxWidth = width > 900 ? 700.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.schedule == null ? "Add Schedule" : "Edit Schedule",
          style: TextStyle(
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.schedule == null
                        ? "Create Class Schedule"
                        : "Update Class Schedule",
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${widget.department} • Semester ${widget.semester}",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),

                  SizedBox(height: isMobile ? 28 : 36),

                  /// Subject
                  TextFormField(
                    controller: subjectController,
                    style: TextStyle(fontSize: isMobile ? 15 : 16),
                    decoration: inputDecoration(
                      label: "Subject",
                      icon: Icons.menu_book,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Required"
                        : null,
                  ),

                  SizedBox(height: isMobile ? 16 : 20),

                  /// Teacher
                  TextFormField(
                    controller: teacherController,
                    style: TextStyle(fontSize: isMobile ? 15 : 16),
                    decoration: inputDecoration(
                      label: "Teacher Name",
                      icon: Icons.person,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Required"
                        : null,
                  ),

                  SizedBox(height: isMobile ? 16 : 20),

                  /// Room
                  TextFormField(
                    controller: roomController,
                    style: TextStyle(fontSize: isMobile ? 15 : 16),
                    decoration: inputDecoration(
                      label: "Class Room",
                      icon: Icons.room,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Required"
                        : null,
                  ),

                  SizedBox(height: isMobile ? 16 : 20),

                  /// Day
                  DropdownButtonFormField<String>(
                    initialValue: selectedDay,
                    decoration: inputDecoration(
                      label: "Day",
                      icon: Icons.calendar_today,
                    ),
                    items: days
                        .map(
                          (day) =>
                              DropdownMenuItem(value: day, child: Text(day)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value!;
                      });
                    },
                  ),

                  SizedBox(height: isMobile ? 22 : 28),

                  /// Start Time
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        startTime == null
                            ? "Select Start Time"
                            : TimeOfDay.fromDateTime(
                                startTime!,
                              ).format(context),
                        style: TextStyle(fontSize: isMobile ? 15 : 16),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => pickTime(true),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// End Time
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.schedule,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        endTime == null
                            ? "Select End Time"
                            : TimeOfDay.fromDateTime(endTime!).format(context),
                        style: TextStyle(fontSize: isMobile ? 15 : 16),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => pickTime(false),
                    ),
                  ),

                  SizedBox(height: isMobile ? 32 : 40),

                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 54 : 58,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSaving ? null : saveSchedule,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              widget.schedule == null ? Icons.add : Icons.save,
                            ),
                      label: Text(
                        isSaving
                            ? "Saving..."
                            : widget.schedule == null
                            ? "Add Schedule"
                            : "Update Schedule",
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

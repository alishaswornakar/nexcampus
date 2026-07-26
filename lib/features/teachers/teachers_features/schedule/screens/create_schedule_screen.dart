import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/model/schedule_model.dart';


import '../repository/schedule_repository.dart';
import '../services/schedule_service.dart';

class AddScheduleScreen extends StatefulWidget {
  final String department;
  final String semester;

  /// null = Add
  /// not null = Edit
  final ScheduleModel? schedule;

  const AddScheduleScreen({
    super.key,
    required this.department,
    required this.semester,
    this.schedule,
  });

  @override
  State<AddScheduleScreen> createState() =>
      _AddScheduleScreenState();
}

class _AddScheduleScreenState
    extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  final repository =
      ScheduleRepository(
    ScheduleService(),
  );

  final subjectController =
      TextEditingController();

  final teacherController =
      TextEditingController();

  final roomController =
      TextEditingController();

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

    /// Edit Mode
    if (widget.schedule != null) {
      subjectController.text =
          widget.schedule!.subject;

      teacherController.text =
          widget.schedule!.teacherName;

      roomController.text =
          widget.schedule!.room;

      selectedDay =
          widget.schedule!.day;

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
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Select class time."),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final createdAt = widget.schedule?.createdAt ?? DateTime.now();

      final schedule = ScheduleModel(
        id: widget.schedule?.id ??
            FirebaseFirestore.instance
                .collection("schedules")
                .doc()
                .id,
        subject:
            subjectController.text.trim(),
        teacherName:
            teacherController.text.trim(),
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
        await repository.createSchedule(
          schedule: schedule,
        );
      } else {
        await repository.updateSchedule(
          schedule: schedule,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.green,
          content: Text(
            widget.schedule == null
                ? "Schedule Added"
                : "Schedule Updated",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          widget.schedule == null
              ? "Add Schedule"
              : "Edit Schedule",
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(20),
          children: [

            TextFormField(
              controller:
                  subjectController,
              decoration:
                  const InputDecoration(
                labelText: "Subject",
              ),
              validator: (value) =>
                  value!.isEmpty
                      ? "Required"
                      : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  teacherController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Teacher Name",
              ),
              validator: (value) =>
                  value!.isEmpty
                      ? "Required"
                      : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: roomController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Class Room",
              ),
              validator: (value) =>
                  value!.isEmpty
                      ? "Required"
                      : null,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField(
              initialValue: selectedDay,
              decoration:
                  const InputDecoration(
                labelText: "Day",
              ),
              items: days
                  .map(
                    (e) =>
                        DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                selectedDay = value!;
              },
            ),

            const SizedBox(height: 20),

            ListTile(
              tileColor: Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
              title: Text(
  startTime == null
      ? "Start Time"
      : TimeOfDay.fromDateTime(startTime!).format(context),
),
              trailing: const Icon(
                Icons.access_time,
              ),
              onTap: () =>
                  pickTime(true),
            ),

            const SizedBox(height: 12),

            ListTile(
              tileColor: Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
              title: Text(
  endTime == null
      ? "End Time"
      : TimeOfDay.fromDateTime(endTime!).format(context),
),
              trailing: const Icon(
                Icons.access_time,
              ),
              onTap: () =>
                  pickTime(false),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child:
                  ElevatedButton.icon(
                onPressed: isSaving
                    ? null
                    : saveSchedule,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                      ),
                label: Text(
                  isSaving
                      ? "Saving..."
                      : widget.schedule ==
                              null
                          ? "Add Schedule"
                          : "Update Schedule",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
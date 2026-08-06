import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../bloc/teacher_notification_bloc.dart';
import '../bloc/teacher_notification_event.dart';

/// Bottom sheet a teacher uses to publish a notice to all students
/// (and every teacher's notification list, since notices are broadcast).
Future<void> showComposeNoticeSheet(BuildContext context) {
  final bloc = context.read<TeacherNotificationBloc>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Publish a Notice",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  final title = titleController.text.trim();
                  final body = bodyController.text.trim();
                  if (title.isEmpty || body.isEmpty) return;

                  bloc.add(
                    TeacherNotificationNoticeSendRequested(
                      title: title,
                      body: body,
                    ),
                  );
                  Navigator.pop(sheetContext);
                },
                child: const Text(
                  "Send to all students",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

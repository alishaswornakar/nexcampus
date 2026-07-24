// lib/features/student/blocs/anonymous_issue_reporting/screens/create_issue_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/anonymous_issue_bloc.dart';
import '../bloc/anonymous_issue_event.dart';
import '../bloc/anonymous_issue_state.dart';
import '../models/issue_post_model.dart';
import '../utils/issue_colors.dart';

/// Form for creating a new anonymous post/question/issue.
/// Must be pushed with an [AnonymousIssueBloc] already available above it
/// (e.g. from [AnonymousIssueReportingScreen]'s BlocProvider).
class CreateIssuePostScreen extends StatefulWidget {
  const CreateIssuePostScreen({super.key, required this.authorId});

  final String authorId;

  @override
  State<CreateIssuePostScreen> createState() => _CreateIssuePostScreenState();
}

class _CreateIssuePostScreenState extends State<CreateIssuePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _category = IssueCategory.question;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AnonymousIssueBloc>().add(
      AnonymousIssueCreatePostRequested(
        authorId: widget.authorId,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        category: _category,
        isAnswer: _category == IssueCategory.question,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnonymousIssueBloc, AnonymousIssueState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == AnonymousIssueActionStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Posted anonymously')));
          context.read<AnonymousIssueBloc>().add(
            const AnonymousIssueActionResultCleared(),
          );
          Navigator.of(context).pop();
        } else if (state.actionStatus == AnonymousIssueActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError ?? 'Failed to create post'),
              backgroundColor: Colors.red,
            ),
          );
          context.read<AnonymousIssueBloc>().add(
            const AnonymousIssueActionResultCleared(),
          );
        }
      },
      child: Scaffold(
        backgroundColor: IssueColors.background,
        appBar: AppBar(
          backgroundColor: IssueColors.skyBlue,
          title: const Text(
            'New Anonymous Post',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: IssueColors.skyBlueLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: IssueColors.skyBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: IssueColors.skyBlueDark,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your name, roll number, and profile are never shown. '
                        'This will be posted under a random label like '
                        '"Anonymous Curious Falcon".',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: IssueColors.skyBlueDark,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              const _Label('Category'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _category,
                    items: IssueCategory.all
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const _Label('Title'),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                  'e.g. Is the library open on Saturdays?',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),

              const _Label('Details'),
              TextFormField(
                controller: _bodyController,
                maxLines: 6,
                decoration: _inputDecoration(
                  'Share as much context as you feel comfortable with. '
                  'No one will know it was you.',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Details are required'
                    : null,
              ),
              const SizedBox(height: 28),

              BlocBuilder<AnonymousIssueBloc, AnonymousIssueState>(
                buildWhen: (previous, current) =>
                    previous.actionStatus != current.actionStatus,
                builder: (context, state) {
                  final isSubmitting =
                      state.actionStatus ==
                      AnonymousIssueActionStatus.inProgress;
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IssueColors.skyBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Post Anonymously'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// lib/features/student/blocs/team_finder/screens/create_team_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/team_finder_bloc.dart';
import '../bloc/team_finder_event.dart';
import '../bloc/team_finder_state.dart';
import '../widgets/skill_tag_chip.dart';

const List<String> kTeamFinderProjectTypes = [
  'Minor Project',
  'Major Project',
  'Hackathon',
  'Personal Project',
];

/// Form for creating a new team-finder post.
/// Must be pushed with a [TeamFinderBloc] already available above it
/// (e.g. from [TeamFinderScreen]'s BlocProvider).
class CreateTeamPostScreen extends StatefulWidget {
  const CreateTeamPostScreen({
    super.key,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
  });

  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String rollNumber;
  final String department;
  final String semester;

  @override
  State<CreateTeamPostScreen> createState() => _CreateTeamPostScreenState();
}

class _CreateTeamPostScreenState extends State<CreateTeamPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillInputController = TextEditingController();

  String _projectType = kTeamFinderProjectTypes.first;
  final List<String> _skills = [];
  int _slotsTotal = 2;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final value = _skillInputController.text.trim();
    if (value.isEmpty) return;
    if (!_skills.any((s) => s.toLowerCase() == value.toLowerCase())) {
      setState(() => _skills.add(value));
    }
    _skillInputController.clear();
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<TeamFinderBloc>().add(
      TeamFinderCreatePostRequested(
        ownerId: widget.ownerId,
        ownerName: widget.ownerName,
        ownerEmail: widget.ownerEmail,
        rollNumber: widget.rollNumber,
        department: widget.department,
        semester: widget.semester,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        projectType: _projectType,
        skillsNeeded: _skills,
        slotsTotal: _slotsTotal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeamFinderBloc, TeamFinderState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == TeamFinderActionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully')),
          );
          context.read<TeamFinderBloc>().add(
            const TeamFinderActionResultCleared(),
          );
          Navigator.of(context).pop();
        } else if (state.actionStatus == TeamFinderActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError ?? 'Failed to create post'),
              backgroundColor: Colors.red,
            ),
          );
          context.read<TeamFinderBloc>().add(
            const TeamFinderActionResultCleared(),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          title: const Text('New Team Post'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _Label('Title'),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('e.g. Need 2 devs for FYP'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),

              const _Label('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Describe the project, what you need help with, and expectations',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),

              const _Label('Project Type'),
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
                    value: _projectType,
                    items: kTeamFinderProjectTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _projectType = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const _Label('Skills Needed'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillInputController,
                      decoration: _inputDecoration('e.g. Flutter, Firebase'),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              if (_skills.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _skills
                      .map(
                        (s) => SkillTagChip(
                          label: s,
                          onDeleted: () => _removeSkill(s),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),

              const _Label('Slots Needed'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Text(
                      '$_slotsTotal',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.blue,
                      onPressed: _slotsTotal > 1
                          ? () => setState(() => _slotsTotal--)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.blue,
                      onPressed: () => setState(() => _slotsTotal++),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              BlocBuilder<TeamFinderBloc, TeamFinderState>(
                buildWhen: (previous, current) =>
                    previous.actionStatus != current.actionStatus,
                builder: (context, state) {
                  final isSubmitting =
                      state.actionStatus == TeamFinderActionStatus.inProgress;
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                          : const Text('Post'),
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

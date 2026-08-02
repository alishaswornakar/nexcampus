// assignment/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_event.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_submission_service.dart';

import '../models/assignment_model.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_empty_widget.dart';
import 'assignment_tasks_detail_screen.dart';

/// Student-facing "Tasks" screen. AppBar (title/color) is unchanged.
/// The tab selector below it is now a horizontally scrollable pill row
/// matching Figma, with an added "All" tab — everything else keeps the
/// existing [AssignmentBloc] wiring.
class TasksScreen extends StatelessWidget {
  const TasksScreen({
    super.key,
    required this.department,
    required this.semester,
    required this.studentId,
  });

  final String department;
  final String semester;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssignmentBloc(
        AssignmentRepository(AssignmentService()),
        AssignmentSubmissionRepository(AssignmentSubmissionService()),
      ),
      child: _TasksScreenBody(
        department: department,
        semester: semester,
        studentId: studentId,
      ),
    );
  }
}

class _TasksScreenBody extends StatefulWidget {
  const _TasksScreenBody({
    required this.department,
    required this.semester,
    required this.studentId,
  });

  final String department;
  final String semester;
  final String studentId;

  @override
  State<_TasksScreenBody> createState() => _TasksScreenBodyState();
}

class _TasksScreenBodyState extends State<_TasksScreenBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const Color _accent = Color(0xFF4C4FE0);

  static const List<String> _tabLabels = [
    'All',
    'Pending',
    'Overdue',
    'Submitted',
    'Graded',
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentBloc>().add(
        LoadAssignments(
          department: widget.department,
          semester: widget.semester,
          studentId: widget.studentId,
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<AssignmentBloc>().add(
      RefreshAssignments(
        department: widget.department,
        semester: widget.semester,
        studentId: widget.studentId,
      ),
    );
  }

  void _openDetail(BuildContext context, StudentAssignmentModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssignmentTasksDetailScreen(
          assignment: item,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  Widget _tabPill(int index) {
    final bool selected = _tabController.index == index;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _accent : const Color(0xFFEDEDF5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _tabLabels[index],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        title: const Text('Assignments', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _tabLabels.length,
                itemBuilder: (context, index) => _tabPill(index),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AssignmentBloc, AssignmentState>(
              builder: (context, state) {
                if (state is AssignmentLoading || state is AssignmentInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AssignmentError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 44,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context.read<AssignmentBloc>().add(
                              LoadAssignments(
                                department: widget.department,
                                semester: widget.semester,
                                studentId: widget.studentId,
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final loaded = state as AssignmentLoaded;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _AssignmentList(
                      items: loaded.assignments,
                      emptyTitle: 'No assignments yet',
                      emptyMessage:
                          'New assignments from your teachers will show up here.',
                      emptyIcon: Icons.assignment_outlined,
                      onRefresh: () => _onRefresh(context),
                      onTap: (item) => _openDetail(context, item),
                    ),
                    _AssignmentList(
                      items: loaded.pendingAssignments,
                      emptyTitle: 'No Pending Tasks',
                      emptyMessage: 'You\'re all caught up for now.',
                      emptyIcon: Icons.task_alt_rounded,
                      onRefresh: () => _onRefresh(context),
                      onTap: (item) => _openDetail(context, item),
                    ),
                    _AssignmentList(
                      items: loaded.overdueAssignments,
                      emptyTitle: 'No Overdue Assignments',
                      emptyMessage:
                          'Great job! You don\'t have any assignments past their deadline.',
                      emptyIcon: Icons.event_busy_rounded,
                      onRefresh: () => _onRefresh(context),
                      onTap: (item) => _openDetail(context, item),
                    ),
                    _AssignmentList(
                      items: loaded.submittedAssignments,
                      emptyTitle: 'No Submissions Yet',
                      emptyMessage:
                          'Assignments you\'ve submitted will be listed here for your records.',
                      emptyIcon: Icons.cloud_done_rounded,
                      onRefresh: () => _onRefresh(context),
                      onTap: (item) => _openDetail(context, item),
                    ),
                    _AssignmentList(
                      items: loaded.gradedAssignments,
                      emptyTitle: 'No Graded Assignment Yet',
                      emptyMessage:
                          'Grades from your teacher will appear here.',
                      emptyIcon: Icons.star_border_rounded,
                      emptyFilled: false,
                      onRefresh: () => _onRefresh(context),
                      onTap: (item) => _openDetail(context, item),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentList extends StatelessWidget {
  const _AssignmentList({
    required this.items,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onRefresh,
    required this.onTap,
    this.emptyFilled = true,
  });

  final List<StudentAssignmentModel> items;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool emptyFilled;
  final Future<void> Function() onRefresh;
  final void Function(StudentAssignmentModel item) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: AssignmentEmptyWidget(
                    title: emptyTitle,
                    message: emptyMessage,
                    icon: emptyIcon,
                    filled: emptyFilled,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return AssignmentCard(
            key: ValueKey(item.id),
            assignment: item,
            onTap: () => onTap(item),
          );
        },
      ),
    );
  }
}

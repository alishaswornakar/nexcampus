import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../blocs/assignment/assignment_bloc.dart';
import '../blocs/assignment/assignment_event.dart';
import '../blocs/assignment/assignment_state.dart';
import '../models/assignment_model.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_empty_widget.dart';
import 'assignment_tasks_detail_screen.dart';

/// Student-facing "Tasks" screen.
///
/// Shows all assignments for the given [department]/[semester], tabbed by
/// [StudentAssignmentStatus] (Pending, Overdue, Submitted, Graded), each
/// derived from the merged assignment + submission stream in
/// [AssignmentBloc].
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
      create: (_) => AssignmentBloc()
        ..add(
          WatchAssignments(
            department: department,
            semester: semester,
            studentId: studentId,
          ),
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

  static const List<String> _tabLabels = [
    'Pending',
    'Overdue',
    'Submitted',
    'Graded',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
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
          studentName: '',
          roll: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
      body: BlocBuilder<AssignmentBloc, AssignmentState>(
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
                items: loaded.pendingAssignments,
                emptyTitle: 'No pending tasks',
                emptyMessage: 'You\'re all caught up for now.',
                emptyIcon: Icons.task_alt_rounded,
                onRefresh: () => _onRefresh(context),
                onTap: (item) => _openDetail(context, item),
              ),
              _AssignmentList(
                items: loaded.overdueAssignments,
                emptyTitle: 'No overdue tasks',
                emptyMessage: 'Nothing missed — keep it up!',
                emptyIcon: Icons.check_circle_outline_rounded,
                onRefresh: () => _onRefresh(context),
                onTap: (item) => _openDetail(context, item),
              ),
              _AssignmentList(
                items: loaded.submittedAssignments,
                emptyTitle: 'No submissions yet',
                emptyMessage: 'Assignments you submit will show up here.',
                emptyIcon: Icons.cloud_upload_outlined,
                onRefresh: () => _onRefresh(context),
                onTap: (item) => _openDetail(context, item),
              ),
              _AssignmentList(
                items: loaded.gradedAssignments,
                emptyTitle: 'No graded assignments',
                emptyMessage: 'Grades from your teachers will appear here.',
                emptyIcon: Icons.grade_outlined,
                onRefresh: () => _onRefresh(context),
                onTap: (item) => _openDetail(context, item),
              ),
            ],
          );
        },
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
  });

  final List<StudentAssignmentModel> items;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final void Function(StudentAssignmentModel item) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: AssignmentEmptyWidget(
                title: emptyTitle,
                message: emptyMessage,
                icon: emptyIcon,
              ),
            ),
          ],
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

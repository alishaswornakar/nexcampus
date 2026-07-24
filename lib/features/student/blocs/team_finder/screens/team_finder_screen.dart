// lib/features/student/blocs/team_finder/screens/team_finder_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nexcampus_app/core/data/semester_subjects.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../bloc/team_finder_bloc.dart';
import '../bloc/team_finder_event.dart';
import '../bloc/team_finder_state.dart';
import '../models/team_application_model.dart';
import '../models/team_post_model.dart';
import '../repository/team_finder_repository.dart';
import '../widgets/team_finder_filter_bar.dart';
import '../widgets/team_post_card.dart';
import '../widgets/team_post_empty_widget.dart';
import 'create_team_post_screen.dart';
import 'team_post_detail_screen.dart';

const List<String> kTeamFinderDepartments = [
  'Computer Engineering',
  'Civil Engineering',
  'Architecture',
];

const List<String> kTeamFinderSemesters = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
];

/// Entry point for the Team Finder feature. Owns the [TeamFinderBloc] and
/// hosts three tabs: Browse (open posts from everyone), My Posts (posts the
/// current student created), and My Applications (posts they applied to).
class TeamFinderScreen extends StatelessWidget {
  const TeamFinderScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
  });

  final String studentId;
  final String studentName;
  final String studentEmail;
  final String rollNumber;
  final String department;
  final String semester;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamFinderBloc>(
      create: (_) => TeamFinderBloc(repository: TeamFinderRepositoryImpl()),
      child: _TeamFinderView(
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        rollNumber: rollNumber,
        department: department,
        semester: semester,
      ),
    );
  }
}

class _TeamFinderView extends StatefulWidget {
  const _TeamFinderView({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
  });

  final String studentId;
  final String studentName;
  final String studentEmail;
  final String rollNumber;
  final String department;
  final String semester;

  @override
  State<_TeamFinderView> createState() => _TeamFinderViewState();
}

class _TeamFinderViewState extends State<_TeamFinderView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String? _filterDepartment;
  String? _filterSemester;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBrowseTab();
    context.read<TeamFinderBloc>().add(
      TeamFinderMyPostsSubscriptionRequested(ownerId: widget.studentId),
    );
    context.read<TeamFinderBloc>().add(
      TeamFinderMyApplicationsSubscriptionRequested(
        applicantId: widget.studentId,
      ),
    );
  }

  void _loadBrowseTab() {
    context.read<TeamFinderBloc>().add(
      TeamFinderOpenPostsSubscriptionRequested(
        department: _filterDepartment,
        semester: _filterSemester,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: context.read<TeamFinderBloc>(),
          child: CreateTeamPostScreen(
            ownerId: widget.studentId,
            ownerName: widget.studentName,
            ownerEmail: widget.studentEmail,
            rollNumber: widget.rollNumber,
            department: widget.department,
            semester: widget.semester,
          ),
        ),
      ),
    );
  }

  void _openPostDetail(TeamPostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: context.read<TeamFinderBloc>(),
          child: TeamPostDetailScreen(
            initialPost: post,
            currentStudentId: widget.studentId,
            currentStudentName: widget.studentName,
            currentStudentEmail: widget.studentEmail,
            currentStudentRollNumber: widget.rollNumber,
            currentStudentDepartment: widget.department,
            currentStudentSemester: widget.semester,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        title: const Text(
          'Team Finder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'My Posts'),
            Tab(text: 'My Applications'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePost,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BrowseTab(
            filterDepartment: _filterDepartment,
            filterSemester: _filterSemester,
            onFilterChanged: (dept, sem) {
              setState(() {
                _filterDepartment = dept;
                _filterSemester = sem;
              });
              _loadBrowseTab();
            },
            onPostTap: _openPostDetail,
          ),
          _MyPostsTab(onPostTap: _openPostDetail),
          _MyApplicationsTab(onPostTap: _openPostDetail),
        ],
      ),
    );
  }
}

class _BrowseTab extends StatelessWidget {
  const _BrowseTab({
    required this.filterDepartment,
    required this.filterSemester,
    required this.onFilterChanged,
    required this.onPostTap,
  });

  final String? filterDepartment;
  final String? filterSemester;
  final void Function(String? department, String? semester) onFilterChanged;
  final ValueChanged<TeamPostModel> onPostTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeamFinderFilterBar(
            department: filterDepartment,
            semester: filterSemester,
            departments: kTeamFinderDepartments,
            semesters: kTeamFinderSemesters,
            onDepartmentChanged: (v) => onFilterChanged(v, filterSemester),
            onSemesterChanged: (v) => onFilterChanged(filterDepartment, v),
            onClear: () => onFilterChanged(null, null),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: BlocBuilder<TeamFinderBloc, TeamFinderState>(
              buildWhen: (previous, current) =>
                  previous.openPostsStatus != current.openPostsStatus ||
                  previous.openPosts != current.openPosts,
              builder: (context, state) {
                if (state.openPostsStatus == OpenPostsStatus.loading ||
                    state.openPostsStatus == OpenPostsStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.openPostsStatus == OpenPostsStatus.failure) {
                  return TeamPostEmptyWidget(
                    title: 'Could not load posts',
                    subtitle: state.openPostsError,
                    icon: Icons.error_outline,
                  );
                }
                if (state.openPosts.isEmpty) {
                  return const TeamPostEmptyWidget(
                    title: 'No open posts right now',
                    subtitle: 'Be the first to post a team request.',
                    icon: Icons.group_add_outlined,
                  );
                }
                return ListView.separated(
                  itemCount: state.openPosts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = state.openPosts[index];
                    return TeamPostCard(
                      post: post,
                      onTap: () => onPostTap(post),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPostsTab extends StatelessWidget {
  const _MyPostsTab({required this.onPostTap});
  final ValueChanged<TeamPostModel> onPostTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<TeamFinderBloc, TeamFinderState>(
        buildWhen: (previous, current) =>
            previous.myPostsStatus != current.myPostsStatus ||
            previous.myPosts != current.myPosts,
        builder: (context, state) {
          if (state.myPostsStatus == MyPostsStatus.loading ||
              state.myPostsStatus == MyPostsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.myPostsStatus == MyPostsStatus.failure) {
            return TeamPostEmptyWidget(
              title: 'Could not load your posts',
              subtitle: state.myPostsError,
              icon: Icons.error_outline,
            );
          }
          if (state.myPosts.isEmpty) {
            return const TeamPostEmptyWidget(
              title: "You haven't posted anything yet",
              subtitle: 'Tap the + button to create a team post.',
              icon: Icons.post_add_outlined,
            );
          }
          return ListView.separated(
            itemCount: state.myPosts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = state.myPosts[index];
              return TeamPostCard(
                post: post,
                showOwner: false,
                onTap: () => onPostTap(post),
              );
            },
          );
        },
      ),
    );
  }
}

class _MyApplicationsTab extends StatelessWidget {
  const _MyApplicationsTab({required this.onPostTap});
  final ValueChanged<TeamPostModel> onPostTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<TeamFinderBloc, TeamFinderState>(
        buildWhen: (previous, current) =>
            previous.myApplicationsStatus != current.myApplicationsStatus ||
            previous.myApplications != current.myApplications,
        builder: (context, state) {
          if (state.myApplicationsStatus == MyApplicationsStatus.loading ||
              state.myApplicationsStatus == MyApplicationsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.myApplicationsStatus == MyApplicationsStatus.failure) {
            return TeamPostEmptyWidget(
              title: 'Could not load your applications',
              subtitle: state.myApplicationsError,
              icon: Icons.error_outline,
            );
          }
          if (state.myApplications.isEmpty) {
            return const TeamPostEmptyWidget(
              title: "You haven't applied to any posts yet",
              subtitle: 'Browse open posts to find a team.',
              icon: Icons.send_outlined,
            );
          }
          return ListView.separated(
            itemCount: state.myApplications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final app = state.myApplications[index];
              return _MyApplicationRow(
                application: app,
                onTap: () async {
                  final repository = TeamFinderRepositoryImpl();
                  final post = await repository.getPostOnce(app.postId);
                  onPostTap(post);
                },
                onWithdraw: app.status == TeamApplicationStatus.pending
                    ? () {
                        context.read<TeamFinderBloc>().add(
                          TeamFinderWithdrawApplicationRequested(
                            applicationId: app.id,
                            applicantId: app.applicantId,
                          ),
                        );
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _MyApplicationRow extends StatelessWidget {
  const _MyApplicationRow({
    required this.application,
    required this.onTap,
    this.onWithdraw,
  });

  final TeamApplicationModel application;
  final VoidCallback onTap;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.postTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusLabel(application.status),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _statusColor(application.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onWithdraw != null)
              TextButton(
                onPressed: onWithdraw,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Withdraw'),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case TeamApplicationStatus.accepted:
        return 'Accepted';
      case TeamApplicationStatus.rejected:
        return 'Rejected';
      case TeamApplicationStatus.withdrawn:
        return 'Withdrawn';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case TeamApplicationStatus.accepted:
        return Colors.green;
      case TeamApplicationStatus.rejected:
        return Colors.red;
      case TeamApplicationStatus.withdrawn:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

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
        backgroundColor: AppTheme.primary,
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
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'My Posts'),
            Tab(text: 'My Applications'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePost,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Team',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
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

class _BrowseTab extends StatefulWidget {
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
  State<_BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<_BrowseTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeamPostModel> _applySearch(List<TeamPostModel> posts) {
    if (_query.trim().isEmpty) return posts;
    final q = _query.trim().toLowerCase();
    return posts
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.skillsNeeded.any((s) => s.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeamFinderSearchField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 10),
          TeamFinderFilterBar(
            department: widget.filterDepartment,
            semester: widget.filterSemester,
            departments: kTeamFinderDepartments,
            semesters: kTeamFinderSemesters,
            onDepartmentChanged: (v) =>
                widget.onFilterChanged(v, widget.filterSemester),
            onSemesterChanged: (v) =>
                widget.onFilterChanged(widget.filterDepartment, v),
            onClear: () => widget.onFilterChanged(null, null),
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
                final posts = _applySearch(state.openPosts);
                if (posts.isEmpty) {
                  return TeamPostEmptyWidget(
                    title: state.openPosts.isEmpty
                        ? 'No open posts right now'
                        : 'No posts match your search',
                    subtitle: state.openPosts.isEmpty
                        ? 'Be the first to post a team request.'
                        : 'Try a different keyword or clear your filters.',
                    icon: Icons.group_add_outlined,
                  );
                }
                return ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return TeamPostCard(
                      post: post,
                      onTap: () => widget.onPostTap(post),
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
              subtitle: 'Tap "Create Team" to post a team request.',
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
              subtitle:
                  'Browse open posts to find a team and start collaborating.',
              icon: Icons.change_history_outlined,
            );
          }
          return ListView.separated(
            itemCount: state.myApplications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${application.applicantName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  _StatusPillLabel(status: application.status),
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
              Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

class _StatusPillLabel extends StatelessWidget {
  const _StatusPillLabel({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String label;
    switch (status) {
      case TeamApplicationStatus.accepted:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = 'Accepted';
        break;
      case TeamApplicationStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        label = 'Rejected';
        break;
      case TeamApplicationStatus.withdrawn:
        color = Colors.grey;
        icon = Icons.remove_circle_outline;
        label = 'Withdrawn';
        break;
      default:
        color = Colors.orange;
        icon = Icons.access_time;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

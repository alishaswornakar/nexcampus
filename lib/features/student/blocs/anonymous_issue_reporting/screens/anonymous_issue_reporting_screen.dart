import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../bloc/anonymous_issue_bloc.dart';
import '../bloc/anonymous_issue_event.dart';
import '../bloc/anonymous_issue_state.dart';
import '../models/issue_post_model.dart';
import '../repository/anonymous_issue_repository.dart';
import '../widgets/issue_filter_bar.dart';
import '../widgets/issue_post_card.dart';
import '../widgets/issue_post_empty_widget.dart';
import '../widgets/my_reports_list_view.dart';
import 'create_issue_post_screen.dart';
import 'issue_post_detail_screen.dart';
import 'submit_report_screen.dart';

/// Entry point for the Anonymous Issue Reporting feature. Owns the
/// [AnonymousIssueBloc] and hosts three tabs: Feed (everyone's posts),
/// My Posts (posts the current student created, still shown anonymously
/// to everyone else - only the owner sees a small "You" badge), and
/// My Reports (named reports the student submitted to admins, with
/// status + feedback - see `ReportModel`/`ReportService`).
///
/// [studentId] is used to attribute a post/comment for edit/delete
/// permissions, to know which posts/comments the current student has
/// personally upvoted, and (together with [studentName]) to submit and
/// look up the student's named reports on the "My Reports" tab.
class AnonymousIssueReportingScreen extends StatelessWidget {
  const AnonymousIssueReportingScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  final String studentId;
  final String studentName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnonymousIssueBloc>(
      create: (_) =>
          AnonymousIssueBloc(repository: AnonymousIssueRepositoryImpl()),
      child: _AnonymousIssueView(
        studentId: studentId,
        studentName: studentName,
      ),
    );
  }
}

class _AnonymousIssueView extends StatefulWidget {
  const _AnonymousIssueView({
    required this.studentId,
    required this.studentName,
  });
  final String studentId;
  final String studentName;

  @override
  State<_AnonymousIssueView> createState() => _AnonymousIssueViewState();
}

class _AnonymousIssueViewState extends State<_AnonymousIssueView>
    with SingleTickerProviderStateMixin {
  static const int _myReportsTabIndex = 2;

  late final TabController _tabController;
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadFeed();
    _loadMyPosts();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _loadFeed() {
    context.read<AnonymousIssueBloc>().add(
      AnonymousIssueFeedSubscriptionRequested(category: _filterCategory),
    );
  }

  void _loadMyPosts() {
    context.read<AnonymousIssueBloc>().add(
      AnonymousIssueMyPostsSubscriptionRequested(authorId: widget.studentId),
    );
  }

  Future<void> _onRefreshFeed() async {
    _loadFeed();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _onRefreshMyPosts() async {
    _loadMyPosts();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _openCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: context.read<AnonymousIssueBloc>(),
          child: CreateIssuePostScreen(authorId: widget.studentId),
        ),
      ),
    );
  }

  void _openPostDetail(IssuePostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: context.read<AnonymousIssueBloc>(),
          child: IssuePostDetailScreen(
            initialPost: post,
            currentStudentId: widget.studentId,
          ),
        ),
      ),
    );
  }

  void _openSubmitReport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubmitReportScreen(
          studentId: widget.studentId,
          studentName: widget.studentName,
        ),
      ),
    );
  }

  VoidCallback get _fabAction => _tabController.index == _myReportsTabIndex
      ? _openSubmitReport
      : _openCreatePost;

  IconData get _fabIcon => _tabController.index == _myReportsTabIndex
      ? Icons.add_box_outlined
      : Icons.add;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Anonymous Issues',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                tabs: const [
                  Tab(text: 'Community'),
                  Tab(text: 'My Issues'),
                  Tab(text: 'My Reports'),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fabAction,
        backgroundColor: AppTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Icon(_fabIcon, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FeedTab(
            filterCategory: _filterCategory,
            currentStudentId: widget.studentId,
            onFilterChanged: (category) {
              setState(() => _filterCategory = category);
              _loadFeed();
            },
            onPostTap: _openPostDetail,
            onRefresh: _onRefreshFeed,
          ),
          _MyPostsTab(
            currentStudentId: widget.studentId,
            onPostTap: _openPostDetail,
            onRefresh: _onRefreshMyPosts,
          ),
          // My Reports Tab - Using the existing MyReportsListView
          MyReportsListView(
            studentId: widget.studentId,
            onSubmitNew: _openSubmitReport,
          ),
        ],
      ),
    );
  }
}

Widget _refreshableFallback(Widget child) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      );
    },
  );
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.filterCategory,
    required this.currentStudentId,
    required this.onFilterChanged,
    required this.onPostTap,
    required this.onRefresh,
  });

  final String? filterCategory;
  final String currentStudentId;
  final ValueChanged<String?> onFilterChanged;
  final ValueChanged<IssuePostModel> onPostTap;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IssueFilterBar(
            category: filterCategory,
            categories: IssueCategory.all,
            onCategoryChanged: onFilterChanged,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: BlocBuilder<AnonymousIssueBloc, AnonymousIssueState>(
              buildWhen: (previous, current) =>
                  previous.feedStatus != current.feedStatus ||
                  previous.feedPosts != current.feedPosts,
              builder: (context, state) {
                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: onRefresh,
                  child: _buildBody(state),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AnonymousIssueState state) {
    if (state.feedStatus == FeedStatus.loading ||
        state.feedStatus == FeedStatus.initial) {
      return _refreshableFallback(const CircularProgressIndicator());
    }
    if (state.feedStatus == FeedStatus.failure) {
      return _refreshableFallback(
        IssuePostEmptyWidget(
          title: 'Could not load the feed',
          subtitle: state.feedError,
          icon: Icons.error_outline,
        ),
      );
    }
    if (state.feedPosts.isEmpty) {
      return _refreshableFallback(
        const IssuePostEmptyWidget(
          title: 'No posts yet',
          subtitle:
              'Be the first to ask a question or raise an issue - anonymously.',
          icon: Icons.forum_outlined,
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.feedPosts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = state.feedPosts[index];
        return IssuePostCard(
          post: post,
          currentStudentId: currentStudentId,
          onTap: () => onPostTap(post),
          onUpvote: () => context.read<AnonymousIssueBloc>().add(
            AnonymousIssueToggleUpvotePostRequested(
              postId: post.id,
              studentId: currentStudentId,
            ),
          ),
        );
      },
    );
  }
}

class _MyPostsTab extends StatelessWidget {
  const _MyPostsTab({
    required this.currentStudentId,
    required this.onPostTap,
    required this.onRefresh,
  });

  final String currentStudentId;
  final ValueChanged<IssuePostModel> onPostTap;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<AnonymousIssueBloc, AnonymousIssueState>(
        buildWhen: (previous, current) =>
            previous.myPostsStatus != current.myPostsStatus ||
            previous.myPosts != current.myPosts,
        builder: (context, state) {
          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: onRefresh,
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AnonymousIssueState state) {
    if (state.myPostsStatus == MyPostsStatus.loading ||
        state.myPostsStatus == MyPostsStatus.initial) {
      return _refreshableFallback(const CircularProgressIndicator());
    }
    if (state.myPostsStatus == MyPostsStatus.failure) {
      return _refreshableFallback(
        IssuePostEmptyWidget(
          title: 'Could not load your posts',
          subtitle: state.myPostsError,
          icon: Icons.error_outline,
        ),
      );
    }
    if (state.myPosts.isEmpty) {
      return _refreshableFallback(
        const IssuePostEmptyWidget(
          title: "You haven't posted anything yet",
          subtitle: 'Tap the + button to post anonymously.',
          icon: Icons.post_add_outlined,
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.myPosts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = state.myPosts[index];
        return IssuePostCard(
          post: post,
          currentStudentId: currentStudentId,
          showManageBadge: true,
          onTap: () => onPostTap(post),
          onUpvote: () => context.read<AnonymousIssueBloc>().add(
            AnonymousIssueToggleUpvotePostRequested(
              postId: post.id,
              studentId: currentStudentId,
            ),
          ),
        );
      },
    );
  }
}

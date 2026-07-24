// lib/features/student/blocs/anonymous_issue_reporting/screens/anonymous_issue_reporting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../bloc/anonymous_issue_bloc.dart';
import '../bloc/anonymous_issue_event.dart';
import '../bloc/anonymous_issue_state.dart';
import '../models/issue_post_model.dart';
import '../repository/anonymous_issue_repository.dart';
import '../utils/issue_colors.dart';
import '../widgets/issue_filter_bar.dart';
import '../widgets/issue_post_card.dart';
import '../widgets/issue_post_empty_widget.dart';
import 'create_issue_post_screen.dart';
import 'issue_post_detail_screen.dart';

/// Entry point for the Anonymous Issue Reporting feature. Owns the
/// [AnonymousIssueBloc] and hosts two tabs: Feed (everyone's posts) and
/// My Posts (posts the current student created, still shown anonymously
/// to everyone else - only the owner sees a small "You" badge).
///
/// Only [studentId] is required: it is never displayed anywhere in the
/// UI, it's used solely to attribute a post/comment for edit/delete
/// permissions and to know which posts/comments the current student has
/// personally upvoted.
class AnonymousIssueReportingScreen extends StatelessWidget {
  const AnonymousIssueReportingScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnonymousIssueBloc>(
      create: (_) =>
          AnonymousIssueBloc(repository: AnonymousIssueRepositoryImpl()),
      child: _AnonymousIssueView(studentId: studentId),
    );
  }
}

class _AnonymousIssueView extends StatefulWidget {
  const _AnonymousIssueView({required this.studentId});
  final String studentId;

  @override
  State<_AnonymousIssueView> createState() => _AnonymousIssueViewState();
}

class _AnonymousIssueViewState extends State<_AnonymousIssueView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeed();
    _loadMyPosts();
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

  /// Re-fires the feed subscription and gives the RefreshIndicator a
  /// moment to visibly spin before it snaps back - the actual data comes
  /// from Firestore's live stream, this just forces a fresh subscription
  /// (handy if the previous one stalled on an error, e.g. a missing index).
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: IssueColors.skyBlue,
        title: const Text(
          'Anonymous Issues',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'My Posts'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePost,
        backgroundColor: IssueColors.skyBlue,
        child: const Icon(Icons.add, color: Colors.white),
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
        ],
      ),
    );
  }
}

/// Wraps non-list content (loading/error/empty states) in a scrollable
/// container that fills the viewport, so RefreshIndicator's pull gesture
/// still works even when there's nothing to scroll yet.
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
                  color: IssueColors.skyBlue,
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
            color: IssueColors.skyBlue,
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

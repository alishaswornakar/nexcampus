// lib/features/student/blocs/anonymous_issue_reporting/screens/issue_post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/anonymous_issue_bloc.dart';
import '../bloc/anonymous_issue_event.dart';
import '../bloc/anonymous_issue_state.dart';
//import '../models/issue_comment_model.dart';
import '../models/issue_post_model.dart';
import '../repository/anonymous_issue_repository.dart';
import '../utils/anonymous_identity.dart';
import '../utils/issue_colors.dart';
import '../widgets/anonymous_avatar.dart';
import '../widgets/category_chip.dart';
import '../widgets/issue_comment_tile.dart';
import '../widgets/issue_post_empty_widget.dart';

/// Full detail view for a single anonymous post: the post itself
/// (Facebook/Quora-style header + body), a live comment thread below,
/// and a sticky comment composer pinned to the bottom.
///
/// Must be pushed with an [AnonymousIssueBloc] already available above it
/// (e.g. from [AnonymousIssueReportingScreen]'s BlocProvider).
class IssuePostDetailScreen extends StatefulWidget {
  const IssuePostDetailScreen({
    super.key,
    required this.initialPost,
    required this.currentStudentId,
    this.repository,
  });

  final IssuePostModel initialPost;
  final String currentStudentId;

  /// Optional override, mainly for testing. Defaults to a fresh
  /// [AnonymousIssueRepositoryImpl].
  final AnonymousIssueRepository? repository;

  @override
  State<IssuePostDetailScreen> createState() => _IssuePostDetailScreenState();
}

class _IssuePostDetailScreenState extends State<IssuePostDetailScreen> {
  late final AnonymousIssueRepository _repository;
  final _commentController = TextEditingController();

  bool get _isOwner => widget.currentStudentId == widget.initialPost.authorId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AnonymousIssueRepositoryImpl();
    context.read<AnonymousIssueBloc>().add(
      AnonymousIssuePostCommentsSubscriptionRequested(
        postId: widget.initialPost.id,
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    context.read<AnonymousIssueBloc>().add(
      AnonymousIssueCreateCommentRequested(
        postId: widget.initialPost.id,
        authorId: widget.currentStudentId,
        body: text,
      ),
    );
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnonymousIssueBloc, AnonymousIssueState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == AnonymousIssueActionStatus.failure) {
          _showMessage(
            state.actionError ?? 'Something went wrong',
            isError: true,
          );
          context.read<AnonymousIssueBloc>().add(
            const AnonymousIssueActionResultCleared(),
          );
        } else if (state.actionStatus == AnonymousIssueActionStatus.success) {
          context.read<AnonymousIssueBloc>().add(
            const AnonymousIssueActionResultCleared(),
          );
        }
      },
      child: StreamBuilder<IssuePostModel?>(
        stream: _repository.watchPost(widget.initialPost.id),
        initialData: widget.initialPost,
        builder: (context, snapshot) {
          final post = snapshot.data ?? widget.initialPost;
          if (snapshot.hasData && snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: IssueColors.skyBlue,
                title: const Text(
                  'Anonymous Issues',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: const IssuePostEmptyWidget(
                title: 'This post no longer exists',
                icon: Icons.info_outline,
              ),
            );
          }
          return Scaffold(
            backgroundColor: IssueColors.background,
            appBar: AppBar(
              backgroundColor: IssueColors.skyBlue,
              title: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: _isOwner
                  ? [
                      PopupMenuButton<String>(
                        iconColor: Colors.white,
                        onSelected: (value) async {
                          if (value == 'resolve') {
                            context.read<AnonymousIssueBloc>().add(
                              AnonymousIssueSetResolvedRequested(
                                postId: post.id,
                                authorId: widget.currentStudentId,
                                resolved: !post.isResolved,
                              ),
                            );
                          } else if (value == 'delete') {
                            final ok = await _confirm(
                              'Delete post',
                              'This will permanently delete the post and all its comments.',
                            );
                            if (ok && context.mounted) {
                              context.read<AnonymousIssueBloc>().add(
                                AnonymousIssueDeletePostRequested(
                                  postId: post.id,
                                  authorId: widget.currentStudentId,
                                ),
                              );
                              if (mounted) Navigator.of(context).pop();
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'resolve',
                            child: Text(
                              post.isResolved
                                  ? 'Mark as unresolved'
                                  : 'Mark as resolved',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete post'),
                          ),
                        ],
                      ),
                    ]
                  : null,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _PostHeader(
                        post: post,
                        currentStudentId: widget.currentStudentId,
                        onUpvote: () => context.read<AnonymousIssueBloc>().add(
                          AnonymousIssueToggleUpvotePostRequested(
                            postId: post.id,
                            studentId: widget.currentStudentId,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _CommentsSection(
                        currentStudentId: widget.currentStudentId,
                      ),
                    ],
                  ),
                ),
                _CommentComposer(
                  controller: _commentController,
                  onSubmit: _submitComment,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({
    required this.post,
    required this.currentStudentId,
    required this.onUpvote,
  });

  final IssuePostModel post;
  final String currentStudentId;
  final VoidCallback onUpvote;

  @override
  Widget build(BuildContext context) {
    final hasUpvoted = post.hasUpvoted(currentStudentId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnonymousAvatar(
                seed: AnonymousIdentity.postSeed(post.id),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.anonymousName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _relativeTime(post.createdAt),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (post.isResolved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Resolved',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(post.body, style: const TextStyle(fontSize: 14, height: 1.45)),
          const SizedBox(height: 14),
          CategoryChip(label: post.category),
          const Divider(height: 28),
          Row(
            children: [
              InkWell(
                onTap: onUpvote,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 18,
                        color: hasUpvoted
                            ? IssueColors.skyBlue
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.upvoteCount} Upvote${post.upvoteCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: hasUpvoted
                              ? IssueColors.skyBlue
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Icon(
                Icons.mode_comment_outlined,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                '${post.commentsCount} Comment${post.commentsCount == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({required this.currentStudentId});
  final String currentStudentId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnonymousIssueBloc, AnonymousIssueState>(
      buildWhen: (previous, current) =>
          previous.postCommentsStatus != current.postCommentsStatus ||
          previous.postComments != current.postComments,
      builder: (context, state) {
        if (state.postCommentsStatus == PostCommentsStatus.loading ||
            state.postCommentsStatus == PostCommentsStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.postCommentsStatus == PostCommentsStatus.failure) {
          return IssuePostEmptyWidget(
            title: 'Could not load comments',
            subtitle: state.postCommentsError,
            icon: Icons.error_outline,
          );
        }
        final comments = state.postComments;
        if (comments.isEmpty) {
          return const IssuePostEmptyWidget(
            title: 'No comments yet',
            subtitle: 'Be the first to reply - anonymously.',
            icon: Icons.chat_bubble_outline,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments (${comments.length})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...comments.map(
              (comment) => IssueCommentTile(
                comment: comment,
                currentStudentId: currentStudentId,
                onUpvote: () => context.read<AnonymousIssueBloc>().add(
                  AnonymousIssueToggleUpvoteCommentRequested(
                    commentId: comment.id,
                    studentId: currentStudentId,
                  ),
                ),
                onDelete: () => context.read<AnonymousIssueBloc>().add(
                  AnonymousIssueDeleteCommentRequested(
                    commentId: comment.id,
                    authorId: currentStudentId,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.theater_comedy_outlined,
              color: IssueColors.skyBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Add an anonymous comment...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: onSubmit,
              icon: const Icon(Icons.send, color: IssueColors.skyBlue),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/features/student/blocs/team_finder/screens/team_post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/team_finder_bloc.dart';
import '../bloc/team_finder_event.dart';
import '../bloc/team_finder_state.dart';
import '../models/team_application_model.dart';
import '../models/team_post_model.dart';
import '../repository/team_finder_repository.dart';
import '../widgets/applicant_tile.dart';
import '../widgets/skill_tag_chip.dart';
import '../widgets/team_post_empty_widget.dart';

/// Full detail view for a single post.
/// - If the current user owns the post: shows the applicants list with
///   Accept/Reject, plus Close/Delete actions.
/// - Otherwise: shows an Apply button (or the current application status,
///   with a Withdraw action while pending).
///
/// Must be pushed with a [TeamFinderBloc] already available above it
/// (e.g. from [TeamFinderScreen]'s BlocProvider). The post header refreshes
/// live via [TeamFinderRepository.watchPost] independent of the bloc.
class TeamPostDetailScreen extends StatefulWidget {
  const TeamPostDetailScreen({
    super.key,
    required this.initialPost,
    required this.currentStudentId,
    required this.currentStudentName,
    required this.currentStudentEmail,
    required this.currentStudentRollNumber,
    required this.currentStudentDepartment,
    required this.currentStudentSemester,
    this.repository,
  });

  final TeamPostModel initialPost;
  final String currentStudentId;
  final String currentStudentName;
  final String currentStudentEmail;
  final String currentStudentRollNumber;
  final String currentStudentDepartment;
  final String currentStudentSemester;

  /// Optional override, mainly for testing. Defaults to a fresh
  /// [TeamFinderRepositoryImpl].
  final TeamFinderRepository? repository;

  @override
  State<TeamPostDetailScreen> createState() => _TeamPostDetailScreenState();
}

class _TeamPostDetailScreenState extends State<TeamPostDetailScreen> {
  late final TeamFinderRepository _repository;
  String? _respondingApplicationId;

  bool get _isOwner => widget.currentStudentId == widget.initialPost.ownerId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? TeamFinderRepositoryImpl();
    if (_isOwner) {
      context.read<TeamFinderBloc>().add(
        TeamFinderPostApplicationsSubscriptionRequested(
          postId: widget.initialPost.id,
        ),
      );
    } else {
      context.read<TeamFinderBloc>().add(
        TeamFinderMyApplicationsSubscriptionRequested(
          applicantId: widget.currentStudentId,
        ),
      );
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Future<void> _applyToPost(TeamPostModel post) async {
    final messageController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apply to this post'),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Optional message to the owner',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    context.read<TeamFinderBloc>().add(
      TeamFinderApplyRequested(
        postId: post.id,
        applicantId: widget.currentStudentId,
        applicantName: widget.currentStudentName,
        applicantEmail: widget.currentStudentEmail,
        rollNumber: widget.currentStudentRollNumber,
        department: widget.currentStudentDepartment,
        semester: widget.currentStudentSemester,
        message: messageController.text.trim(),
      ),
    );
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
    return BlocListener<TeamFinderBloc, TeamFinderState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == TeamFinderActionStatus.success) {
          _showMessage('Done');
          setState(() => _respondingApplicationId = null);
          context.read<TeamFinderBloc>().add(
            const TeamFinderActionResultCleared(),
          );
        } else if (state.actionStatus == TeamFinderActionStatus.failure) {
          _showMessage(
            state.actionError ?? 'Something went wrong',
            isError: true,
          );
          setState(() => _respondingApplicationId = null);
          context.read<TeamFinderBloc>().add(
            const TeamFinderActionResultCleared(),
          );
        }
      },
      child: StreamBuilder<TeamPostModel?>(
        stream: _repository.watchPost(widget.initialPost.id),
        initialData: widget.initialPost,
        builder: (context, snapshot) {
          final post = snapshot.data ?? widget.initialPost;
          if (snapshot.hasData && snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Team Finder')),
              body: const TeamPostEmptyWidget(
                title: 'This post no longer exists',
                icon: Icons.info_outline,
              ),
            );
          }
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FB),
            appBar: AppBar(
              title: const Text('Post Details'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: _isOwner
                  ? [
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'close') {
                            final ok = await _confirm(
                              'Close post',
                              'This post will stop accepting new applications.',
                            );
                            if (ok && context.mounted) {
                              context.read<TeamFinderBloc>().add(
                                TeamFinderClosePostRequested(
                                  postId: post.id,
                                  ownerId: widget.currentStudentId,
                                ),
                              );
                            }
                          } else if (value == 'delete') {
                            final ok = await _confirm(
                              'Delete post',
                              'This will permanently delete the post and all its applications.',
                            );
                            if (ok && context.mounted) {
                              context.read<TeamFinderBloc>().add(
                                TeamFinderDeletePostRequested(
                                  postId: post.id,
                                  ownerId: widget.currentStudentId,
                                ),
                              );
                              if (mounted) Navigator.of(context).pop();
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          if (post.status == TeamPostStatus.open)
                            const PopupMenuItem(
                              value: 'close',
                              child: Text('Close post'),
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
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PostHeader(post: post),
                const SizedBox(height: 20),
                if (_isOwner)
                  _ApplicantsSection(
                    respondingApplicationId: _respondingApplicationId,
                    onAccept: (app) {
                      setState(() => _respondingApplicationId = app.id);
                      context.read<TeamFinderBloc>().add(
                        TeamFinderRespondToApplicationRequested(
                          applicationId: app.id,
                          ownerId: widget.currentStudentId,
                          accept: true,
                        ),
                      );
                    },
                    onReject: (app) {
                      setState(() => _respondingApplicationId = app.id);
                      context.read<TeamFinderBloc>().add(
                        TeamFinderRespondToApplicationRequested(
                          applicationId: app.id,
                          ownerId: widget.currentStudentId,
                          accept: false,
                        ),
                      );
                    },
                  )
                else
                  _ApplicantActionSection(
                    post: post,
                    currentStudentId: widget.currentStudentId,
                    onApply: () => _applyToPost(post),
                    onWithdraw: (app) async {
                      final ok = await _confirm(
                        'Withdraw application',
                        'You can re-apply to this post later if it is still open.',
                      );
                      if (ok && context.mounted) {
                        context.read<TeamFinderBloc>().add(
                          TeamFinderWithdrawApplicationRequested(
                            applicationId: app.id,
                            applicantId: widget.currentStudentId,
                          ),
                        );
                      }
                    },
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
  const _PostHeader({required this.post});
  final TeamPostModel post;

  @override
  Widget build(BuildContext context) {
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
          Text(
            post.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${post.ownerName} • ${post.rollNumber}',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.category_outlined, label: post.projectType),
              _InfoChip(icon: Icons.school_outlined, label: post.department),
              _InfoChip(
                icon: Icons.calendar_month_outlined,
                label: 'Sem ${post.semester}',
              ),
              _InfoChip(
                icon: Icons.people_outline,
                label: '${post.slotsFilled}/${post.slotsTotal} filled',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post.description,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          if (post.skillsNeeded.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Skills needed',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.skillsNeeded
                  .map((s) => SkillTagChip(label: s))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.blueGrey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700),
          ),
        ],
      ),
    );
  }
}

/// Owner view: list of applicants for this post, sourced from the bloc's
/// `postApplications` (kept in sync via the subscription started in
/// [_TeamPostDetailScreenState.initState]).
class _ApplicantsSection extends StatelessWidget {
  const _ApplicantsSection({
    required this.onAccept,
    required this.onReject,
    required this.respondingApplicationId,
  });

  final ValueChanged<TeamApplicationModel> onAccept;
  final ValueChanged<TeamApplicationModel> onReject;
  final String? respondingApplicationId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamFinderBloc, TeamFinderState>(
      buildWhen: (previous, current) =>
          previous.postApplicationsStatus != current.postApplicationsStatus ||
          previous.postApplications != current.postApplications,
      builder: (context, state) {
        if (state.postApplicationsStatus == PostApplicationsStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.postApplicationsStatus == PostApplicationsStatus.failure) {
          return TeamPostEmptyWidget(
            title: 'Could not load applicants',
            subtitle: state.postApplicationsError,
            icon: Icons.error_outline,
          );
        }
        if (state.postApplications.isEmpty) {
          return const TeamPostEmptyWidget(
            title: 'No applicants yet',
            subtitle: 'Share this post to get students to apply.',
            icon: Icons.person_search_outlined,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applicants (${state.postApplications.length})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...state.postApplications.map(
              (app) => ApplicantTile(
                application: app,
                isResponding: respondingApplicationId == app.id,
                onAccept: () => onAccept(app),
                onReject: () => onReject(app),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Applicant view: Apply button, or current application status + Withdraw,
/// sourced from the bloc's `myApplications`.
class _ApplicantActionSection extends StatelessWidget {
  const _ApplicantActionSection({
    required this.post,
    required this.currentStudentId,
    required this.onApply,
    required this.onWithdraw,
  });

  final TeamPostModel post;
  final String currentStudentId;
  final VoidCallback onApply;
  final ValueChanged<TeamApplicationModel> onWithdraw;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamFinderBloc, TeamFinderState>(
      buildWhen: (previous, current) =>
          previous.myApplicationsStatus != current.myApplicationsStatus ||
          previous.myApplications != current.myApplications,
      builder: (context, state) {
        TeamApplicationModel? existing;
        for (final app in state.myApplications) {
          if (app.postId == post.id &&
              app.status != TeamApplicationStatus.withdrawn &&
              app.status != TeamApplicationStatus.rejected) {
            existing = app;
            break;
          }
        }

        if (existing != null) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    existing.status == TeamApplicationStatus.accepted
                        ? "You're in! Your application was accepted."
                        : 'Application pending owner response.',
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
                if (existing.status == TeamApplicationStatus.pending)
                  TextButton(
                    onPressed: () => onWithdraw(existing!),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Withdraw'),
                  ),
              ],
            ),
          );
        }

        final canApply = post.isOpen;
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canApply ? onApply : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(canApply ? 'Apply to join' : 'No slots available'),
          ),
        );
      },
    );
  }
}

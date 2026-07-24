// lib/features/student/blocs/digital_queue/screens/digital_queue_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../bloc/digital_queue_bloc.dart';
import '../bloc/digital_queue_event.dart';
import '../bloc/digital_queue_state.dart';
import '../repository/digital_queue_repository.dart';
import '../widgets/active_token_card.dart';
import '../widgets/queue_empty_widget.dart';
import '../widgets/queue_service_card.dart';
import 'queue_history_screen.dart';

/// Model for the currently logged-in student, used to populate every
/// join-queue request. Swap the body of wherever this is constructed
/// to pull from your actual SharedPreferences session keys once you
/// wire up integration.
///
/// NOTE: public (no leading underscore) since it's used as a parameter
/// type on the public `DigitalQueueHomeScreen` constructor — a private
/// type can't appear in a public API's signature.
class CurrentStudent {
  const CurrentStudent({
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
}

/// Top-level screen for the Digital Queue feature: lists all services
/// the student can join, and shows their active token (if any) pinned
/// at the top. Provides the [DigitalQueueBloc] for this screen and its
/// children (history screen is pushed on top and reuses the same bloc
/// via `BlocProvider.value`).
class DigitalQueueHomeScreen extends StatelessWidget {
  const DigitalQueueHomeScreen({super.key, required this.student});

  final CurrentStudent student;

  static Route<void> route({required CurrentStudent student}) {
    return MaterialPageRoute(
      builder: (_) => DigitalQueueHomeScreen(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DigitalQueueBloc(repository: DigitalQueueRepositoryImpl())
        ..add(const DigitalQueueServicesSubscriptionRequested())
        ..add(
          DigitalQueueActiveTokenSubscriptionRequested(
            studentId: student.studentId,
          ),
        ),
      child: _DigitalQueueView(student: student),
    );
  }
}

class _DigitalQueueView extends StatelessWidget {
  const _DigitalQueueView({required this.student});

  final CurrentStudent student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        title: const Text(
          'Digital Queue',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Queue history',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<DigitalQueueBloc>(),
                  child: QueueHistoryScreen(studentId: student.studentId),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<DigitalQueueBloc, DigitalQueueState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == QueueActionStatus.success &&
              state.lastJoinedToken != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Joined queue — your token is #${state.lastJoinedToken!.tokenNumber}',
                ),
              ),
            );
            context.read<DigitalQueueBloc>().add(
              const DigitalQueueActionResultCleared(),
            );
          } else if (state.actionStatus == QueueActionStatus.failure &&
              state.actionError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionError!)));
            context.read<DigitalQueueBloc>().add(
              const DigitalQueueActionResultCleared(),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            // Streams are already live; this just gives the user a
            // tactile "refreshed" gesture without re-subscribing.
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: CustomScrollView(
            slivers: [
              // --- Active token banner (only when the student holds one) ---
              BlocBuilder<DigitalQueueBloc, DigitalQueueState>(
                buildWhen: (previous, current) =>
                    previous.activeToken != current.activeToken ||
                    previous.actionStatus != current.actionStatus,
                builder: (context, state) {
                  if (state.activeToken == null) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  // Look up totalWaiting for the matching service, if the
                  // services stream has already loaded it, to feed the
                  // progress bar inside ActiveTokenCard.
                  int? totalWaiting;
                  if (state.servicesStatus == QueueServicesStatus.loaded) {
                    final match = state.services.where(
                      (s) => s.id == state.activeToken!.serviceId,
                    );
                    if (match.isNotEmpty) {
                      totalWaiting = match.first.totalWaiting;
                    }
                  }
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ActiveTokenCard(
                        token: state.activeToken!,
                        totalWaiting: totalWaiting,
                        isCancelInProgress:
                            state.actionStatus == QueueActionStatus.inProgress,
                        onCancel: () => context.read<DigitalQueueBloc>().add(
                          DigitalQueueCancelRequested(
                            tokenId: state.activeToken!.id,
                            studentId: student.studentId,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'Available Services',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              // --- Services list ---
              BlocBuilder<DigitalQueueBloc, DigitalQueueState>(
                builder: (context, state) {
                  switch (state.servicesStatus) {
                    case QueueServicesStatus.initial:
                    case QueueServicesStatus.loading:
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    case QueueServicesStatus.failure:
                      return SliverToBoxAdapter(
                        child: QueueEmptyWidget(
                          icon: Icons.error_outline,
                          title: 'Could not load services',
                          subtitle: state.servicesError,
                        ),
                      );
                    case QueueServicesStatus.loaded:
                      if (state.services.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: QueueEmptyWidget(
                            icon: Icons.inbox_outlined,
                            title: 'No queue services available',
                          ),
                        );
                      }
                      return SliverList.builder(
                        itemCount: state.services.length,
                        itemBuilder: (context, index) {
                          final service = state.services[index];
                          final alreadyInAnotherQueue =
                              state.hasActiveToken &&
                              state.activeToken!.serviceId != service.id;
                          return QueueServiceCard(
                            service: service,
                            isJoinInProgress:
                                state.actionStatus ==
                                QueueActionStatus.inProgress,
                            disabledReason: alreadyInAnotherQueue
                                ? 'You already have an active token for ${state.activeToken!.serviceName}'
                                : (state.hasActiveToken &&
                                          state.activeToken!.serviceId ==
                                              service.id
                                      ? 'You are already in this queue'
                                      : null),
                            onJoin: () => context.read<DigitalQueueBloc>().add(
                              DigitalQueueJoinRequested(
                                studentId: student.studentId,
                                studentName: student.studentName,
                                studentEmail: student.studentEmail,
                                rollNumber: student.rollNumber,
                                department: student.department,
                                semester: student.semester,
                                serviceId: service.id,
                              ),
                            ),
                          );
                        },
                      );
                  }
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

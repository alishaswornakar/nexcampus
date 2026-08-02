// lib/features/student/blocs/digital_queue/screens/queue_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../bloc/digital_queue_bloc.dart';
import '../bloc/digital_queue_event.dart';
import '../bloc/digital_queue_state.dart';
//import '../widgets/queue_empty_widget.dart';
import '../widgets/queue_history_tile.dart';

/// Shows the student's past queue tokens (completed / cancelled /
/// missed), most recent first. Expects a [DigitalQueueBloc] to already
/// be provided above it (pushed from [DigitalQueueHomeScreen] via
/// `BlocProvider.value`, so the same active-token/services streams
/// don't get needlessly re-subscribed).
class QueueHistoryScreen extends StatelessWidget {
  const QueueHistoryScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text(
          'Queue History',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<DigitalQueueBloc, DigitalQueueState>(
        builder: (context, state) {
          // Fire the subscription once, the first time this screen is
          // built, if it hasn't been requested yet.
          if (state.historyStatus == QueueHistoryStatus.initial) {
            context.read<DigitalQueueBloc>().add(
              DigitalQueueHistorySubscriptionRequested(studentId: studentId),
            );
          }

          switch (state.historyStatus) {
            case QueueHistoryStatus.initial:
            case QueueHistoryStatus.loading:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 3.0,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your history...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              );

            case QueueHistoryStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: isSmallScreen ? 48 : 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load history',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.historyError ?? 'Something went wrong',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<DigitalQueueBloc>().add(
                            DigitalQueueHistorySubscriptionRequested(
                              studentId: studentId,
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

            case QueueHistoryStatus.loaded:
              if (state.history.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha:0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history_outlined,
                            size: isSmallScreen ? 48 : 64,
                            color: AppTheme.primary.withValues(alpha:0.5),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No queue history yet',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tokens you complete or cancel will show up here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // History list with modern cards
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DigitalQueueBloc>().add(
                    DigitalQueueHistorySubscriptionRequested(
                      studentId: studentId,
                    ),
                  );
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomScrollView(
                      slivers: [
                        // Header with stats
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isTablet ? 32 : 16,
                              16,
                              isTablet ? 32 : 16,
                              12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha:0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: isSmallScreen ? 14 : 18,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${state.history.length} tokens',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    context.read<DigitalQueueBloc>().add(
                                      DigitalQueueHistorySubscriptionRequested(
                                        studentId: studentId,
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.refresh,
                                    size: isSmallScreen ? 18 : 22,
                                    color: Colors.grey.shade600,
                                  ),
                                  tooltip: 'Refresh',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // History items
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : 16,
                            vertical: 4,
                          ),
                          sliver: SliverList.builder(
                            itemCount: state.history.length,
                            itemBuilder: (context, index) {
                              final item = state.history[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: QueueHistoryTile(
                                  history: item,
                                  index: index,
                                ),
                              );
                            },
                          ),
                        ),
                        // Bottom padding
                        SliverToBoxAdapter(
                          child: SizedBox(height: isTablet ? 32 : 24),
                        ),
                      ],
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

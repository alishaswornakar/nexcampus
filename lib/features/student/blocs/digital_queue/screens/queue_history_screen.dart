// lib/features/student/blocs/digital_queue/screens/queue_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/digital_queue_bloc.dart';
import '../bloc/digital_queue_event.dart';
import '../bloc/digital_queue_state.dart';
import '../widgets/queue_empty_widget.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Queue History')),
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
              return const Center(child: CircularProgressIndicator());
            case QueueHistoryStatus.failure:
              return QueueEmptyWidget(
                icon: Icons.error_outline,
                title: 'Could not load history',
                subtitle: state.historyError,
              );
            case QueueHistoryStatus.loaded:
              if (state.history.isEmpty) {
                return const QueueEmptyWidget(
                  icon: Icons.history_outlined,
                  title: 'No queue history yet',
                  subtitle: 'Tokens you complete or cancel will show up here',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: state.history.length,
                itemBuilder: (context, index) =>
                    QueueHistoryTile(history: state.history[index]),
              );
          }
        },
      ),
    );
  }
}

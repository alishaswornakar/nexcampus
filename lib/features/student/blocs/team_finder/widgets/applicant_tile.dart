// lib/features/student/blocs/team_finder/widgets/applicant_tile.dart
import 'package:flutter/material.dart';

import '../models/team_application_model.dart';

/// Row shown to a post owner for each applicant, with Accept/Reject
/// actions when the application is still pending.
class ApplicantTile extends StatelessWidget {
  const ApplicantTile({
    super.key,
    required this.application,
    this.onAccept,
    this.onReject,
    this.isResponding = false,
  });

  final TeamApplicationModel application;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isResponding;

  @override
  Widget build(BuildContext context) {
    final isPending = application.status == TeamApplicationStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                child: Text(
                  application.applicantName.isNotEmpty
                      ? application.applicantName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${application.rollNumber} • ${application.department} • Sem ${application.semester}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(status: application.status),
            ],
          ),
          if (application.message.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                application.message,
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          ],
          if (isPending && (onAccept != null || onReject != null)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isResponding ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isResponding ? null : onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isResponding
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    late final MaterialColor color;
    late final String label;
    switch (status) {
      case TeamApplicationStatus.accepted:
        color = Colors.green;
        label = 'Accepted';
        break;
      case TeamApplicationStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
      case TeamApplicationStatus.withdrawn:
        color = Colors.grey;
        label = 'Withdrawn';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/admin/models/report_model.dart';
import 'package:nexcampus_app/features/admin/services/report_service.dart';

/// List-only version of My Reports — no [Scaffold], no FAB, so it can be
/// dropped straight into a [TabBarView] tab inside
/// `AnonymousIssueReportingScreen`. The "New Report" action now lives on
/// that screen's shared, tab-aware FAB instead of here.
///
/// Reads the same `reports` collection that `ReportMonitoringScreen`
/// (admin side) writes status/feedback to, via
/// `ReportService.getStudentReports` — so any admin update appears here
/// live through the Firestore stream, no manual refresh needed.
///
/// Includes status filter tabs: All, Pending, Reviewed, Resolved
class MyReportsListView extends StatefulWidget {
  const MyReportsListView({
    super.key,
    required this.studentId,
    required this.onSubmitNew,
  });

  final String studentId;
  final VoidCallback onSubmitNew;

  @override
  State<MyReportsListView> createState() => _MyReportsListViewState();
}

class _MyReportsListViewState extends State<MyReportsListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green.shade100;
      case 'Reviewed':
        return Colors.orange.shade100;
      case 'Pending':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green.shade800;
      case 'Reviewed':
        return Colors.orange.shade800;
      case 'Pending':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Resolved':
        return Icons.check_circle;
      case 'Reviewed':
        return Icons.visibility;
      case 'Pending':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status Filter Tabs
        Container(
          color: Colors.grey.shade50,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.blue.shade700,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: '📋 All'),
              Tab(text: '⏳ Pending'),
              Tab(text: '👀 Reviewed'),
              Tab(text: '✅ Resolved'),
            ],
          ),
        ),
        // Report List with Filter
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildReportList(null),
              _buildReportList('Pending'),
              _buildReportList('Reviewed'),
              _buildReportList('Resolved'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportList(String? statusFilter) {
    return StreamBuilder<List<ReportModel>>(
      stream: _reportService.getStudentReports(
        widget.studentId,
        statusFilter: statusFilter,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final reports = snapshot.data ?? [];
        final filterName = statusFilter ?? 'All';

        if (reports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.report_off, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No $filterName reports',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filterName == 'All'
                        ? "You haven't submitted any reports yet."
                        : 'Your $filterName reports will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (filterName == 'All') ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: widget.onSubmitNew,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit a Report'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report);
          },
        );
      },
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final hasFeedback = report.adminFeedback.isNotEmpty;
    final statusColor = _statusColor(report.status);
    final textColor = _statusTextColor(report.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(report.status),
                        size: 14,
                        color: textColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.status,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Anonymous Badge - Fixed: Changed Icons.anonymous to Icons.visibility_off
            if (report.isAnonymous)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility_off,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Anonymous',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // Description
            Text(
              report.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Category Badge
            if (report.category != null && report.category!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  report.category!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 10),

            // Admin Feedback
            if (hasFeedback) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          size: 14,
                          color: Colors.blueGrey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Admin Feedback',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.adminFeedback,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(report.createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                if (report.updatedAt != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.update, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Updated: ${_formatDate(report.updatedAt!)}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

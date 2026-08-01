// lib/features/admin/team_finder/screens/admin_team_management_screen.dart
import 'package:flutter/material.dart';

import '../models/team_model.dart';
import '../services/admin_team_service.dart';

class AdminTeamManagementScreen extends StatefulWidget {
  const AdminTeamManagementScreen({super.key});

  @override
  State<AdminTeamManagementScreen> createState() =>
      _AdminTeamManagementScreenState();
}

class _AdminTeamManagementScreenState extends State<AdminTeamManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminTeamService _teamService = AdminTeamService();

  // Selected Filter Values
  String selectedDept = 'All Dept';
  String selectedSem = 'All Sem';

  // Dropdown Data Lists
  final List<String> departmentList = [
    'All Dept',
    'Civil',
    'Computer',
    'Architecture',
  ];

  // Department अनुसार Semester List ल्याउने Helper Method
  List<String> _getSemesterList() {
    if (selectedDept == 'Architecture') {
      return [
        'All Sem',
        'Sem 1',
        'Sem 2',
        'Sem 3',
        'Sem 4',
        'Sem 5',
        'Sem 6',
        'Sem 7',
        'Sem 8',
        'Sem 9',
        'Sem 10',
      ];
    } else {
      return [
        'All Sem',
        'Sem 1',
        'Sem 2',
        'Sem 3',
        'Sem 4',
        'Sem 5',
        'Sem 6',
        'Sem 7',
        'Sem 8',
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    // 3 Tabs: All, Open, Closed — matches TeamPostStatus on the student side
    // (there is no Pending/Approved/Rejected workflow in that schema).
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteConfirm(BuildContext context, TeamModel team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text(
          'Delete "${team.title}"? This also removes all applications '
          'submitted to it. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _teamService.deleteTeam(team.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showApplicants(BuildContext context, TeamModel team) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Applicants · ${team.title}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<TeamApplicationSummary>>(
                    stream: _teamService.getApplicantsForPost(team.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final applicants = snapshot.data ?? [];
                      if (applicants.isEmpty) {
                        return const Center(
                          child: Text(
                            'No applicants yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: applicants.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final a = applicants[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              a.applicantName.isEmpty
                                  ? a.applicantEmail
                                  : a.applicantName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              a.rollNumber,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: _applicationStatusChip(a.status),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _applicationStatusChip(String status) {
    Color color;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'withdrawn':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00569E);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Team Finder Posts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          isScrollable: false,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Open"),
            Tab(text: "Closed"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Single Row Filters (Department र Semester मात्र)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                // 1. Department Dropdown
                Expanded(
                  child: _buildDropdown(selectedDept, departmentList, (val) {
                    setState(() {
                      selectedDept = val!;
                      if (selectedDept != 'Architecture' &&
                          (selectedSem == 'Sem 9' || selectedSem == 'Sem 10')) {
                        selectedSem = 'All Sem';
                      }
                    });
                  }),
                ),
                const SizedBox(width: 8),

                // 2. Semester Dropdown
                Expanded(
                  child: _buildDropdown(
                    selectedSem,
                    _getSemesterList(),
                    (val) => setState(() => selectedSem = val!),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeamList(null),
                _buildTeamList(TeamPostStatus.open),
                _buildTeamList(TeamPostStatus.closed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// [status] is `null` for the "All" tab, otherwise `TeamPostStatus.open`
  /// or `TeamPostStatus.closed`.
  Widget _buildTeamList(String? status) {
    final Stream<List<TeamModel>> stream = status == null
        ? _teamService.getAllTeams()
        : _teamService.getTeamsByStatus(status);

    return StreamBuilder<List<TeamModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load posts: ${snapshot.error}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          );
        }

        var teams = snapshot.data ?? [];

        // Apply Local Department Filter
        if (selectedDept != 'All Dept') {
          teams = teams
              .where(
                (t) => t.department.toLowerCase() == selectedDept.toLowerCase(),
              )
              .toList();
        }

        // Apply Local Semester Filter
        if (selectedSem != 'All Sem') {
          teams = teams.where((t) => t.semester == selectedSem).toList();
        }

        if (teams.isEmpty) {
          return Center(
            child: Text(
              "No posts found.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return _buildTeamCard(team);
          },
        );
      },
    );
  }

  Widget _buildTeamCard(TeamModel team) {
    final bool isOpen = team.isOpen;
    final Color statusBg = isOpen ? Colors.green.shade50 : Colors.grey.shade200;
    final Color statusColor = isOpen ? Colors.green : Colors.grey.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  team.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Sub-tags Row (ProjectType, Dept, Semester)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  team.projectType,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${team.department} • ${team.semester}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            team.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),

          // Skills
          if (team.skillsNeeded.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: team.skillsNeeded
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 10),

          // Slots & Owner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.group_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${team.slotsFilled}/${team.slotsTotal} filled",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  team.ownerName.isEmpty
                      ? team.ownerEmail
                      : '${team.ownerName} · ${team.rollNumber}',
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          // Admin Action Buttons
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _showApplicants(context, team),
                icon: const Icon(Icons.people_alt_outlined, size: 16),
                label: Text(
                  'Applicants',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
              Row(
                children: [
                  if (isOpen)
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          await _teamService.closePost(team.id);
                        } catch (e) {
                          {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.lock_outline,
                        color: Colors.orange,
                        size: 16,
                      ),
                      label: const Text(
                        "Close",
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          await _teamService.reopenPost(team.id);
                        } catch (e) {
                          {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.lock_open,
                        color: Colors.green,
                        size: 16,
                      ),
                      label: const Text(
                        "Reopen",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    onPressed: () => _showDeleteConfirm(context, team),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

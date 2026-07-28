import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/admin_team_service.dart';

class AdminTeamManagementScreen extends StatefulWidget {
  const AdminTeamManagementScreen({super.key});

  @override
  State<AdminTeamManagementScreen> createState() =>
      _AdminTeamManagementScreenState();
}

class _AdminTeamManagementScreenState
    extends State<AdminTeamManagementScreen>
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
        'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5',
        'Sem 6', 'Sem 7', 'Sem 8', 'Sem 9', 'Sem 10'
      ];
    } else {
      return [
        'All Sem',
        'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4',
        'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    // 4 Tabs: All, Pending, Approved, Rejected
    _tabController = TabController(length: 4, vsync: this);
  }

  void _showRejectDialog(BuildContext context, String teamId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Team Request"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Enter rejection reason...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                await _teamService.updateTeamStatus(
                  teamId,
                  'Rejected',
                  reason: reasonController.text.trim(),
                );
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
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
          "Team Approvals",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          isScrollable: false,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Single Row Filters (Department र Semester मात्र)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              children: [
                // 1. Department Dropdown
                Expanded(
                  child: _buildDropdown(
                    selectedDept,
                    departmentList,
                    (val) {
                      setState(() {
                        selectedDept = val!;
                        if (selectedDept != 'Architecture' &&
                            (selectedSem == 'Sem 9' || selectedSem == 'Sem 10')) {
                          selectedSem = 'All Sem';
                        }
                      });
                    },
                  ),
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
                _buildTeamList("All"),
                _buildTeamList("Pending"),
                _buildTeamList("Approved"),
                _buildTeamList("Rejected"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
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
          style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTeamList(String status) {
    Stream<List<TeamModel>> stream = (status == "All")
        ? _teamService.getAllTeams()
        : _teamService.getTeamsByStatus(status);

    return StreamBuilder<List<TeamModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var teams = snapshot.data ?? [];

        // Apply Local Department Filter
        if (selectedDept != 'All Dept') {
          teams = teams.where((t) => t.department.toLowerCase() == selectedDept.toLowerCase()).toList();
        }

        // Apply Local Semester Filter
        if (selectedSem != 'All Sem') {
          teams = teams.where((t) => t.semester == selectedSem).toList();
        }

        if (teams.isEmpty) {
          return Center(
            child: Text(
              "No ${status == 'All' ? '' : status} teams found.",
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
    Color statusBg = Colors.orange.shade50;
    Color statusColor = Colors.orange;

    if (team.status == 'Approved') {
      statusBg = Colors.green.shade50;
      statusColor = Colors.green;
    } else if (team.status == 'Rejected') {
      statusBg = Colors.red.shade50;
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              Text(
                team.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  team.status,
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),

          // Slots & Leader
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.group_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${team.filledSlots}/${team.totalSlots} filled",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                team.leaderName,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          // Rejection Reason
          if (team.status == 'Rejected' && team.rejectReason != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Reason: ${team.rejectReason}",
                style: TextStyle(fontSize: 11, color: Colors.red.shade800),
              ),
            ),
          ],

          // Admin Action Buttons
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (team.status != 'Approved')
                TextButton.icon(
                  onPressed: () async {
                    await _teamService.updateTeamStatus(team.id, 'Approved');
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  label: const Text("Approve", style: TextStyle(color: Colors.green, fontSize: 12)),
                ),
              if (team.status != 'Rejected')
                TextButton.icon(
                  onPressed: () => _showRejectDialog(context, team.id),
                  icon: const Icon(Icons.cancel, color: Colors.orange, size: 16),
                  label: const Text("Reject", style: TextStyle(color: Colors.orange, fontSize: 12)),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                onPressed: () async {
                  await _teamService.deleteTeam(team.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
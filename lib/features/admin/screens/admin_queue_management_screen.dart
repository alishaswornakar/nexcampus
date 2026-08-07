import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:nexcampus_app/features/student/blocs/digital_queue/services/digital_queue_firestore_service.dart';
import 'package:nexcampus_app/features/student/blocs/digital_queue/models/queue_token_model.dart' show QueueStatus;

class AdminQueueManagementScreen extends StatefulWidget {
  const AdminQueueManagementScreen({super.key});

  @override
  State<AdminQueueManagementScreen> createState() =>
      _AdminQueueManagementScreenState();
}

class _AdminQueueManagementScreenState
    extends State<AdminQueueManagementScreen> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(initialIndex: 0),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(initialIndex: 1),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(initialIndex: 2),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(initialIndex: 3),
          ),
        );
        break;
    }
  }

  // Services now come live from Firestore (`queue_services`) instead of a
  // hardcoded local list — a hardcoded list can silently drift out of sync
  // with the real service documents (renames, typos, casing), which was
  // causing the serviceName-based token query below to miss most waiting
  // tokens for a section.
  String? selectedServiceId;
  String selectedService = '';
  String selectedCounter = '';
  int selectedAverageServiceTime = 5;
  bool isCounterOpen = true;

  void _onServiceChanged(String? newServiceId, List<QueryDocumentSnapshot> allServices) {
    if (newServiceId == null) return;
    final match = allServices.firstWhere((d) => d.id == newServiceId);
    final data = match.data() as Map<String, dynamic>;
    setState(() {
      selectedServiceId = newServiceId;
      selectedService = data['name'] ?? '';
      selectedCounter = data['counterName'] ?? '';
      selectedAverageServiceTime = (data['averageServiceTime'] as num?)?.toInt() ?? 5;
    });
  }

  final _queueService = DigitalQueueFirestoreService();

  Future<void> _callToken(String docId) async {
    try {
      final calledToken = await _queueService.callSpecificToken(
        tokenId: docId,
        counterName: selectedCounter,
      );
      if (mounted && calledToken != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'For ${calledToken.studentName}, you are called to ${calledToken.serviceName}.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to call token: $e')));
      }
    }
  }

  Future<void> _completeToken(String docId) async {
    try {
      await _queueService.completeToken(
        tokenId: docId,
        counterName: selectedCounter,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete token: $e')),
        );
      }
    }
  }

  /// "Hold" — the student was called but didn't respond/show up. Marks
  /// the token missed (archives it) rather than leaving it stuck in
  /// 'serving' forever, which would otherwise keep counting against the
  /// service indefinitely.
  Future<void> _holdToken(String docId) async {
    try {
      await _queueService.markTokenAsMissed(tokenId: docId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update token: $e')));
      }
    }
  }

  void _showStudentDetails(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Token #${data['tokenNumber'] ?? ''}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  Chip(
                    label: Text(
                      (data['status'] ?? 'waiting').toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    backgroundColor: data['status'] == QueueStatus.serving
                        ? Colors.green
                        : const Color(0xFF4F46E5),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow(
                Icons.person,
                "Student Name",
                data['studentName'],
              ),
              _buildDetailRow(
                Icons.badge_outlined,
                "Roll Number",
                data['rollNumber'],
              ),
              _buildDetailRow(
                Icons.school_outlined,
                "Department",
                data['department'],
              ),
              _buildDetailRow(
                Icons.class_outlined,
                "Semester",
                data['semester'],
              ),
              _buildDetailRow(
                Icons.email_outlined,
                "Email",
                data['studentEmail'],
              ),
              _buildDetailRow(
                Icons.account_balance_outlined,
                "Service",
                data['serviceName'],
              ),
              _buildDetailRow(
                Icons.door_sliding_outlined,
                "Counter",
                data['counterName'],
              ),
              _buildDetailRow(
                Icons.date_range,
                "Queue Date",
                data['queueDate'],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const indigoTheme = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Queue Management",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('queue_services')
            .orderBy('displayOrder')
            .snapshots(),
        builder: (context, servicesSnapshot) {
          if (servicesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final serviceDocs = servicesSnapshot.hasData
              ? servicesSnapshot.data!.docs
              : <QueryDocumentSnapshot>[];

          if (serviceDocs.isEmpty) {
            return const Center(child: Text('No services configured.'));
          }

          // Default to the first service once docs arrive.
          if (selectedServiceId == null ||
              !serviceDocs.any((d) => d.id == selectedServiceId)) {
            final first = serviceDocs.first;
            final firstData = first.data() as Map<String, dynamic>;
            selectedServiceId = first.id;
            selectedService = firstData['name'] ?? '';
            selectedCounter = firstData['counterName'] ?? '';
            selectedAverageServiceTime =
                (firstData['averageServiceTime'] as num?)?.toInt() ?? 5;
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('queue_tokens')
                .where('serviceId', isEqualTo: selectedServiceId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.hasData ? snapshot.data!.docs : [];

          final servingDoc = docs
              .where(
                (d) =>
                    (d.data() as Map<String, dynamic>)['status'] ==
                    QueueStatus.serving,
              )
              .toList();
          final waitingDocs = docs
              .where(
                (d) =>
                    (d.data() as Map<String, dynamic>)['status'] ==
                    QueueStatus.waiting,
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            children: [
              // 1. Active Service Dropdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF1F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Active Service Queue",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedServiceId,
                          isExpanded: true,
                          items: serviceDocs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text(
                                data['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (id) => _onServiceChanged(id, serviceDocs),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Counter Status Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF1F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedService,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.meeting_room_outlined,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  selectedCounter,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${waitingDocs.length} Waiting",
                            style: const TextStyle(
                              fontSize: 12,
                              color: indigoTheme,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: Color(0xFFCBD5E1), height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Queue Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              isCounterOpen ? "OPEN" : "CLOSED",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCounterOpen
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Switch(
                              value: isCounterOpen,
                              activeThumbColor: Colors.white,
                              activeTrackColor: indigoTheme,
                              onChanged: (val) {
                                setState(() {
                                  isCounterOpen = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Currently Serving Card (Blue Theme)
              if (servingDoc.isNotEmpty) ...[
                _buildServingCard(servingDoc.first, indigoTheme),
                const SizedBox(height: 24),
              ],

              // 4. Up Next Section Title
              const Text(
                "Up Next",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              // Waiting Queue List Cards
              if (waitingDocs.isEmpty && servingDoc.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  alignment: Alignment.center,
                  child: const Text(
                    "No active tokens right now.",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                )
              else
                ...waitingDocs.map(
                  (doc) => _buildWaitingCard(doc, indigoTheme),
                ),

              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.horizontal_rule, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      "End of Queue",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.horizontal_rule, color: Colors.grey.shade400),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4F46E5),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Management',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Oversight',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Serving Card Matching Image Design
  Widget _buildServingCard(DocumentSnapshot doc, Color themeColor) {
    final data = doc.data() as Map<String, dynamic>;
    final tokenNo = data['tokenNumber'] ?? '#';
    final studentName = data['studentName'] ?? 'Student';
    final rollNumber = data['rollNumber'] ?? '';
    final serviceName = data['serviceName'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFF3B44B8,
        ), // Deep Indigo/Blue background matching image
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "CURRENTLY SERVING",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "#$tokenNo",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            studentName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Roll No: $rollNumber • Query: $serviceName",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3B44B8),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    "Complete",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () => _completeToken(doc.id),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.pause_circle_outline, size: 18),
                  label: const Text(
                    "Hold",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () => _holdToken(doc.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Up Next Waiting Card Matching Image Design
  Widget _buildWaitingCard(DocumentSnapshot doc, Color themeColor) {
    final data = doc.data() as Map<String, dynamic>;
    final tokenNo = data['tokenNumber'] ?? '#';
    final studentName = data['studentName'] ?? 'Student';
    final rollNumber = data['rollNumber'] ?? '';
    final serviceName = data['serviceName'] ?? '';
    final isFirstInLine =
        data['status'] == 'waiting'; // Can customize wait badge logic if needed

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF1F6), // Soft greyish blue card background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "#$tokenNo",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F46E5),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showStudentDetails(data),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Roll No: $rollNumber",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  serviceName,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: isFirstInLine
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Call Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                    onPressed: () => _callToken(doc.id),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "In Queue",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {},
                  ),
          ),
        ],
      ),
    );
  }
}

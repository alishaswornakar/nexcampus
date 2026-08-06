import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/admin/screens/admin_dashboard_screen.dart';

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

  // DB को serviceName सँग हुबहु मिल्ने लिस्ट
  final List<Map<String, String>> services = [
    {'name': 'College Bank', 'counter': 'Counter 3'},
    {'name': 'Exam Section', 'counter': 'Counter 1'},
    {'name': 'Accounts Section', 'counter': 'Counter 2'},
    {'name': 'Certificate Section', 'counter': 'Counter 4'},
    {'name': 'Library Clearance', 'counter': 'Counter 5'},
  ];

  late String selectedService;
  late String selectedCounter;
  bool isCounterOpen = true;

  @override
  void initState() {
    super.initState();
    selectedService = services[0]['name']!;
    selectedCounter = services[0]['counter']!;
  }

  void _onServiceChanged(String? newService) {
    if (newService == null) return;
    final match = services.firstWhere(
      (element) => element['name'] == newService,
    );
    setState(() {
      selectedService = newService;
      selectedCounter = match['counter']!;
    });
  }

  // Token status update logic
  Future<void> _updateTokenStatus(String docId, String status) async {
    Map<String, dynamic> updateData = {'status': status};

    if (status == 'Serving') {
      updateData['calledAt'] = FieldValue.serverTimestamp();
    } else if (status == 'Completed') {
      updateData['completedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'Skipped') {
      updateData['cancelledAt'] = FieldValue.serverTimestamp();
    }

    await FirebaseFirestore.instance
        .collection('queue_tokens') // 👈 exact Collection Name
        .doc(docId)
        .update(updateData);
  }

  // 📄 विद्यार्थीको पूरा Details देखाउने BottomSheet Dialog
  void _showStudentDetails(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      color: Color(0xFF6B4EFF),
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
                    backgroundColor: data['status'] == 'Serving'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
              const Divider(height: 24),

              // Full Student Details List
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
              _buildDetailRow(
                Icons.timer_outlined,
                "Est. Wait Time",
                "${data['estimatedWaitMinutes'] ?? 0} mins",
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00569E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
    const primaryBlue = Color(0xFF00569E);
    const purpleTheme = Color(0xFF6B4EFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          "Queue Counter Console",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. Top Section: Counter & Status Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Active Service:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedService,
                          items: services.map((s) {
                            return DropdownMenuItem(
                              value: s['name'],
                              child: Text(
                                "${s['name']} (${s['counter']})",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: purpleTheme,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: _onServiceChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Counter Status ($selectedCounter):",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isCounterOpen ? "OPEN" : "CLOSED",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCounterOpen ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        Switch(
                          value: isCounterOpen,
                          activeThumbColor: Colors.green,
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

          // 2. Realtime Stream from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('queue_tokens') // 👈 DB collection name
                  .where(
                    'serviceName',
                    isEqualTo: selectedService,
                  ) // 👈 DB field name
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No active tokens for $selectedService.",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // Status अनुसार Sorting (waiting, Serving)
                final servingDoc = docs
                    .where(
                      (d) =>
                          (d.data() as Map<String, dynamic>)['status'] ==
                          'Serving',
                    )
                    .toList();
                final waitingDocs = docs
                    .where(
                      (d) =>
                          (d.data() as Map<String, dynamic>)['status'] ==
                          'waiting',
                    )
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // A. NOW SERVING SECTION
                    if (servingDoc.isNotEmpty) ...[
                      const Text(
                        "NOW SERVING AT COUNTER",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildServingCard(servingDoc.first, purpleTheme),
                      const SizedBox(height: 20),
                    ],

                    // B. WAITING QUEUE SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "WAITING LINE",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: purpleTheme.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${waitingDocs.length} Waiting",
                            style: const TextStyle(
                              fontSize: 11,
                              color: purpleTheme,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (waitingDocs.isEmpty && servingDoc.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        child: const Text(
                          "No active tokens right now.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    else
                      ...waitingDocs.map(
                        (doc) => _buildWaitingCard(doc, purpleTheme),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3F51B5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            label: 'Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined_rounded),
            label: 'Oversight',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Serving Card
  Widget _buildServingCard(DocumentSnapshot doc, Color themeColor) {
    final data = doc.data() as Map<String, dynamic>;
    final tokenNo = data['tokenNumber'] ?? '#';
    final studentName = data['studentName'] ?? 'Student';
    final rollNumber = data['rollNumber'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Serving Token",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "#$tokenNo",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blue),
                onPressed: () => _showStudentDetails(data),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "$studentName ${rollNumber.isNotEmpty ? '($rollNumber)' : ''}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    "Complete",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _updateTokenStatus(doc.id, 'Completed'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.skip_next_outlined, size: 18),
                label: const Text("Skip"),
                onPressed: () => _updateTokenStatus(doc.id, 'Skipped'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Waiting Card Widget
  Widget _buildWaitingCard(DocumentSnapshot doc, Color themeColor) {
    final data = doc.data() as Map<String, dynamic>;
    final tokenNo = data['tokenNumber'] ?? '#';
    final studentName = data['studentName'] ?? 'Student';
    final rollNumber = data['rollNumber'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "#$tokenNo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: () =>
                  _showStudentDetails(data), // 👈 Click गर्दा Full Detail खुल्छ
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Roll: $rollNumber • ${data['department'] ?? ''}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.grey, size: 20),
            onPressed: () => _showStudentDetails(data),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              "Call Next",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _updateTokenStatus(doc.id, 'Serving'),
          ),
        ],
      ),
    );
  }
}

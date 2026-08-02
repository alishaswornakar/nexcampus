import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/admin/models/notice_model.dart';
import 'package:url_launcher/url_launcher.dart';

// मुख्य ड्यासबोर्ड वा Bottom Nav भएको स्क्रिन
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key, required NoticeModel existingNotice});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0; // मानौं Oversight ट्याब Index 1 मा छ

  final List<Widget> _screens = [
    const Center(child: Text("Home Screen")),
    const OversightMenuScreen(), // यहाँ Oversight मेनु छ
    const Center(child: Text("Profile Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: "Oversight"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. OVERSIGHT MENU SCREEN (जहाँ Attendance, Course Files, Reports हुन्छन्)
// -----------------------------------------------------------------------------
class OversightMenuScreen extends StatelessWidget {
  const OversightMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Oversight',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildOversightCard(
            title: 'Attendance',
            subtitle: 'View and monitor student attendance records.',
            icon: Icons.calendar_today_outlined,
            onTap: () {
              // Attendance पेजमा जाने (चाहिएमा रुट नेभिगेटर राख्न सकिन्छ)
            },
          ),
          const SizedBox(height: 14),
          _buildOversightCard(
            title: 'Course Files',
            subtitle: 'Review courses materials uploaded by administrators.',
            icon: Icons.folder_open_outlined,
            onTap: () {
              // ⚠️ यो कोडले Bottom Nav Bar लाई लुकाएर सिधै फुल स्क्रिनमा Published Notes खोल्छ!
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => const PublishedNotesFullScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOversightCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF3F51B5), size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
        onTap: onTap,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. PUBLISHED NOTES FULL SCREEN (नेभिगेसन बार बिना खुल्ने फुल स्क्रिन)
// -----------------------------------------------------------------------------
class PublishedNotesFullScreen extends StatelessWidget {
  const PublishedNotesFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context), // पछाडि फर्किंदा फेरि Oversight मै जान्छ
        ),
        title: const Text(
          'Published Notes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          int count = docs.length;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // 🟦 Top Blue Summary Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3352E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reviewing ${count > 0 ? count : 6} Published Notes",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Faculty uploads pending audit.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 📄 Notes Cards
              if (docs.isEmpty) ...[
                _buildNoteCard(title: "Math", author: "ranju", department: "General", url: ""),
                _buildNoteCard(title: "chapter 1", author: "ranju", department: "General", url: ""),
                _buildNoteCard(title: "C Programming", author: "ranju", department: "General", url: ""),
                _buildNoteCard(title: "notes", author: "ranju", department: "General", url: ""),
              ] else ...[
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildNoteCard(
                    title: data['title'] ?? 'Untitled Note',
                    author: data['uploadedBy'] ?? data['author'] ?? 'Faculty',
                    department: data['department'] ?? 'General',
                    url: data['fileUrl'] ?? '',
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoteCard({
    required String title,
    required String author,
    required String department,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDBE2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF3F51B5),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "By $author",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
            onPressed: () async {
              if (url.isNotEmpty) {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
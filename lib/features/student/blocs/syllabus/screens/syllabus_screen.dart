import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/student/screens/student_dashboard_screen.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'syllabus_subject_screen.dart';

/// Department + semester picker for the student's Syllabus tab.
///
/// Mirrors `CoursesScreen` / `NotesScreen`'s structure and department
/// list exactly, so all three tabs feel and behave the same way.
/// Selecting a semester pushes [SyllabusSubjectScreen], which streams
/// the department's real Firestore courses for that semester and
/// gives each course a "Drive" / "Teacher Material" dropdown.
class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  final Map<String, int> _departments = const {
    "Computer Engineering": 8,
    "Civil Engineering": 8,
    "Architecture Engineering": 10,
  };

  String? _selectedDepartment;

  IconData _iconFor(String department) {
    if (department.contains('Computer')) return Icons.computer_rounded;
    if (department.contains('Civil')) return Icons.engineering_rounded;
    return Icons.architecture_rounded;
  }

  void _openSemester(int semester) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SyllabusSubjectScreen(
          semester: semester,
          department: _selectedDepartment!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDashboardScreen(user: currentUser),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Syllabus'),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Department',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your department to continue.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ..._departments.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _departmentCard(
                    title: entry.key,
                    semesterCount: entry.value,
                    icon: _iconFor(entry.key),
                  ),
                ),
              ),
              if (_selectedDepartment != null) ...[
                const SizedBox(height: 10),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 20),
                const Text(
                  'Choose Semester',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select a semester to view its Syllabus.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _departments[_selectedDepartment]!,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 2.3,
                  ),
                  itemBuilder: (context, index) {
                    final semester = index + 1;
                    return _semesterChip(semester);
                  },
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _departmentCard({
    required String title,
    required int semesterCount,
    required IconData icon,
  }) {
    final selected = _selectedDepartment == title;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => _selectedDepartment = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppTheme.secondary.withValues(alpha: 0.08),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppTheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$semesterCount Semesters',
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _semesterChip(int semester) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openSemester(semester),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Semester $semester',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

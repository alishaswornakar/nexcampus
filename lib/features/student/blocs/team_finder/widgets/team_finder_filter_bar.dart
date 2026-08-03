// lib/features/student/blocs/team_finder/widgets/team_finder_filter_bar.dart
import 'package:flutter/material.dart';

/// Search field for the Browse tab.
/// Filters posts client-side by title/description as the user types.
class TeamFinderSearchField extends StatelessWidget {
  const TeamFinderSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search projects or roles...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

/// Department / semester filter row for the Browse tab.
/// Pass `null` for a value to mean "All".
class TeamFinderFilterBar extends StatelessWidget {
  const TeamFinderFilterBar({
    super.key,
    required this.department,
    required this.semester,
    required this.departments,
    required this.semesters,
    required this.onDepartmentChanged,
    required this.onSemesterChanged,
    this.onClear,
  });

  final String? department;
  final String? semester;
  final List<String> departments;
  final List<String> semesters;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onSemesterChanged;
  final VoidCallback? onClear;

  bool get _hasFilter => department != null || semester != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterDropdown(
            hint: 'Department',
            value: department,
            items: departments,
            onChanged: onDepartmentChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FilterDropdown(
            hint: 'Semester',
            value: semester,
            items: semesters,
            onChanged: onSemesterChanged,
          ),
        ),
        if (_hasFilter) ...[
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off_outlined, size: 20),
            color: Colors.grey.shade600,
            onPressed: onClear,
          ),
        ],
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade600),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('All $hint', style: const TextStyle(fontSize: 13)),
            ),
            ...items.map(
              (e) => DropdownMenuItem<String?>(
                value: e,
                child: Text(e, style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// lib/features/student/blocs/anonymous_issue_reporting/widgets/issue_filter_bar.dart
import 'package:flutter/material.dart';

/// Category filter row for the Feed tab. Pass `null` to mean "All".
class IssueFilterBar extends StatelessWidget {
  const IssueFilterBar({
    super.key,
    required this.category,
    required this.categories,
    required this.onCategoryChanged,
  });

  final String? category;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterPill(
            label: 'All',
            selected: category == null,
            onTap: () => onCategoryChanged(null),
          ),
          const SizedBox(width: 8),
          for (final c in categories) ...[
            _FilterPill(
              label: c,
              selected: category == c,
              onTap: () => onCategoryChanged(c),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF29B6F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF29B6F6) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

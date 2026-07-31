import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class AttendanceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AttendanceSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double scale(double value) => width * (value / 390);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: scale(16),
        vertical: scale(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: scale(15),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: "Search by date or session...",
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: scale(14),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: scale(22),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: scale(20),
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: scale(16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(scale(14)),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(scale(14)),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(scale(14)),
            borderSide: const BorderSide(
              color: AppTheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
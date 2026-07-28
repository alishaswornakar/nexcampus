import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final int classes;
  final int reviews;
  final int students;

  const StatisticsCard({
    super.key,
    required this.classes,
    required this.reviews,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildItem(
            value: classes.toString(),
            title: "Today's\nClasses",
          ),

          _divider(),

          _buildItem(
            value: reviews.toString(),
            title: "Pending\nReviews",
          ),

          _divider(),

          _buildItem(
            value: students.toString(),
            title: "Students",
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildItem({
    required String value,
    required String title,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
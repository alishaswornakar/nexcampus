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
    final width = MediaQuery.of(context).size.width;

    final horizontalMargin = (width * 0.05).clamp(16.0, 28.0);
    final horizontalPadding = (width * 0.025).clamp(8.0, 16.0);
    final verticalPadding = (width * 0.045).clamp(14.0, 22.0);
    final radius = (width * 0.055).clamp(18.0, 28.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildItem(
            context,
            value: classes.toString(),
            title: "Today's\nClasses",
          ),

          _divider(context),

          _buildItem(
            context,
            value: reviews.toString(),
            title: "Pending\nReviews",
          ),

          _divider(context),

          _buildItem(
            context,
            value: students.toString(),
            title: "Students",
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: 1,
      height: (width * 0.13).clamp(40.0, 60.0),
      color: Colors.grey.shade300,
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String value,
    required String title,
  }) {
    final width = MediaQuery.of(context).size.width;

    final valueSize = (width * 0.075).clamp(22.0, 32.0);
    final titleSize = (width * 0.032).clamp(11.0, 14.0);
    final spacing = (width * 0.02).clamp(4.0, 8.0);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF222222),
              ),
            ),
          ),

          SizedBox(height: spacing),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.01,
            ),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
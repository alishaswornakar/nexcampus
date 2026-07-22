import 'package:flutter/material.dart';

class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key});

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _block({double height = 16, double? width}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = (_controller.value * 2) - 1;
        return Container(
          height: height,
          width: width,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1 + value, 0),
              end: Alignment(1 + value, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: _block(height: 88, width: 88)),
        const SizedBox(height: 12),
        Center(child: _block(height: 18, width: 160)),
        Center(child: _block(height: 14, width: 200)),
        const SizedBox(height: 20),
        _block(height: 80),
        const SizedBox(height: 16),
        _block(height: 160),
        const SizedBox(height: 16),
        _block(height: 160),
        const SizedBox(height: 16),
        _block(height: 100),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class DigitalQueueScreen extends StatelessWidget {
  const DigitalQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Queue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: const Center(child: Text('Digital Queue Screen')),
    );
  }
}

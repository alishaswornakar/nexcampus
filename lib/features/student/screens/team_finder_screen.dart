import 'package:flutter/material.dart';

class TeamFinderScreen extends StatelessWidget {
  const TeamFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Finder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: const Center(child: Text('Team Finder Screen')),
    );
  }
}

import 'package:flutter/material.dart';

class IssueReportingScreen extends StatelessWidget {
  const IssueReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Reporting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: const Center(child: Text('Issue Reporting Screen')),
    );
  }
}

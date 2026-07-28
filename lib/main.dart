import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/startup/app.dart';


import 'core/startup/app_initializer.dart';

Future<void> main() async {
  await AppInitializer.initialize();

  runApp(
    const NexCampusApp(),
  );
}
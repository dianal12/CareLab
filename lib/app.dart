// lib/app.dart

import 'package:flutter/material.dart';
import 'features/sensor_dashboard/screen.dart';

class SensorApp extends StatelessWidget {
  const SensorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF030213),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF0F2F5),
          elevation: 0,
          toolbarHeight: 80,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030213),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF030213),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF030213),
          elevation: 0,
          toolbarHeight: 80,
        ),
      ),

      themeMode: ThemeMode.system,
      home: const SensorDashboardScreen(),
    );
  }
}

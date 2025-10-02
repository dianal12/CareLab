// lib/features/sensor_dashboard/screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class SensorDashboardScreen extends StatefulWidget {
  const SensorDashboardScreen({super.key});

  @override
  State<SensorDashboardScreen> createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  String _fmt(num value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Dashboard')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getEnvironmentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }
          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return const Center(child: Text('No sensor data found.'));
          }

          final data = doc.data() ?? <String, dynamic>{};
          final num temperature = (data['temperature'] as num?) ?? 0;
          final num humidity = (data['humidity'] as num?) ?? 0;
          final num lux = (data['lux'] as num?) ?? 0;
          final num co2 = (data['co2'] as num?) ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                leading: const Icon(Icons.thermostat),
                title: const Text('Temperature'),
                trailing: Text('${_fmt(temperature)} °C'),
              ),
              ListTile(
                leading: const Icon(Icons.water_drop_outlined),
                title: const Text('Humidity'),
                trailing: Text('${_fmt(humidity)} %'),
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: const Text('Light'),
                trailing: Text('${_fmt(lux)} lux'),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: const Text('CO₂'),
                trailing: Text('${_fmt(co2)} ppm'),
              ),
            ],
          );
        },
      ),
    );
  }
}

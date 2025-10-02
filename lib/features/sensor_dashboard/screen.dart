// lib/features/sensor_dashboard/screen.dart

import 'dart:async'; // Нужен для работы таймера
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

  // Вспомогательная функция для форматирования чисел (оставляем без изменений)
  String _fmt(num value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убираем AppBar и задаем светлый фон для всего экрана
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        // SafeArea предотвращает перекрытие элементов интерфейса системными панелями (например, "челкой" на iPhone)
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _firestoreService.getEnvironmentStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading data: ${snapshot.error}'),
              );
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

            // Используем Column для вертикального расположения всех элементов
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 1. Виджет Таймера
                  const PomodoroTimer(),
                  const SizedBox(height: 24),

                  // 2. Карточки с данными сенсоров
                  _buildSensorCard(
                    color: Colors.teal[100]!,
                    title: '온도', // "Температура" на корейском
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSensorValue(
                          Icons.thermostat,
                          '${_fmt(temperature)} °C',
                        ),
                        _buildSensorValue(
                          Icons.water_drop,
                          '${_fmt(humidity)} %',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSensorCard(
                    color: Colors.orange[100]!,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSensorValue(
                          Icons.cloud_queue,
                          '${_fmt(co2)} ppm',
                        ),
                        _buildSensorValue(Icons.wb_sunny, '${_fmt(lux)} lux'),
                      ],
                    ),
                  ),

                  // 3. Растягивающийся элемент, чтобы прижать кнопку SOS к низу
                  const Spacer(),

                  // 4. Кнопка SOS
                  const SosButton(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Вспомогательный метод для создания карточек сенсоров
  Widget _buildSensorCard({
    required Color color,
    String? title,
    required Widget child,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            if (title != null) ...[
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
            ],
            child,
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для отображения иконки и значения
  Widget _buildSensorValue(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 28),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// --- ВИДЖЕТ ТАЙМЕРА POMODORO ---
class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const _initialSeconds = 25 * 60;
  int _remainingSeconds = _initialSeconds;
  Timer? _timer;

  bool get _isRunning => _timer?.isActive ?? false;

  void _startTimer() {
    if (_isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _initialSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Важно отменить таймер при удалении виджета
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            _formatTime(_remainingSeconds),
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _startTimer,
                child: const Text('START'),
              ),
              ElevatedButton(
                onPressed: _pauseTimer,
                child: const Text('PAUSE'),
              ),
              ElevatedButton(
                onPressed: _resetTimer,
                child: const Text('RESET'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- ВИДЖЕТ КНОПКИ SOS ---
class SosButton extends StatelessWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Добавить логику отправки сообщения
          print('SOS button pressed!');
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(24),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text(
          'SOS',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

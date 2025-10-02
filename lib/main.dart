// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  // Обеспечиваем корректную инициализацию Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем Firebase с опциями из firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Запускаем приложение
  runApp(const SensorApp());
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: KhidmaProApp()));
}

class KhidmaProApp extends StatelessWidget {
  const KhidmaProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khidma Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006C67)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

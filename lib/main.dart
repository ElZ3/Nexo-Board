import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nexoboard/features/auth/presentation/pages/login_page.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  runApp(const NexoBoardApp());
}

class NexoBoardApp extends StatelessWidget {
  const NexoBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexo Board',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const LoginPage(),
    );
  }
}

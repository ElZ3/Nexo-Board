import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nexoboard/features/auth/presentation/pages/login_page.dart';
import 'package:nexoboard/features/auth/presentation/views/main_feed_page.dart';
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
      home: const AuthGate(),
    );
  }
}

/// Punto de entrada de navegación que mantiene la sesión persistente.
///
/// Escucha [FirebaseAuth.authStateChanges] para redirigir automáticamente
/// al [MainFeedPage] cuando ya existe una sesión activa, o al [LoginPage]
/// cuando el usuario no está autenticado.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainFeedPage();
        }

        return const LoginPage();
      },
    );
  }
}

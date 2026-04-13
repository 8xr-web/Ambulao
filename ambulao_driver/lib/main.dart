import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/splash_screen.dart';
import 'package:ambulao_driver/screens/main_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const ProviderScope(child: AmbulaoDriverApp()));
}

class AmbulaoDriverApp extends StatelessWidget {
  const AmbulaoDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambulao Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Fallback: If Firebase failed to initialize (e.g., missing config), bypass Firebase Auth
    if (Firebase.apps.isEmpty) {
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return MainLayout();
        }
        return const SplashScreen();
      },
    );
  }
}

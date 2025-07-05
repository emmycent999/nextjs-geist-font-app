import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await StorageService.init();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // Initialize Firebase Messaging
  await NotificationService.initialize();
  
  runApp(const HealaApp());
}

class HealaApp extends StatelessWidget {
  const HealaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Heala - Healthcare at Your Fingertips',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFF0077CC, {
            50: const Color(0xFFE3F2FD),
            100: const Color(0xFFBBDEFB),
            200: const Color(0xFF90CAF9),
            300: const Color(0xFF64B5F6),
            400: const Color(0xFF42A5F5),
            500: const Color(0xFF0077CC),
            600: const Color(0xFF1E88E5),
            700: const Color(0xFF1976D2),
            800: const Color(0xFF1565C0),
            900: const Color(0xFF0D47A1),
          }),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0077CC),
            secondary: const Color(0xFF4CAF50),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0077CC),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077CC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0077CC), width: 2),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

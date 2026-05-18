import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "env");
    print("✅ .env завантажено успішно");
  } catch (e) {
    print("❌ Помилка завантаження .env: $e");
  }

  final url = dotenv.env['SUPABASE_URL'] ?? '';
final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

print("Debug: URL is '$url'"); 
print("Debug: Key length is ${anonKey.length}");

  if (url.isEmpty || anonKey.isEmpty) {
    print("🚨 КРИТИЧНО: URL або AnonKey порожні! Перевір .env та pubspec.yaml");
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouOptimal',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: const Color(0xFF485759),
        scaffoldBackgroundColor: const Color(0xFFF7F3E8),
        fontFamily: 'SFPro',
        useMaterial3: true,
      ),
      home: const HomeScreen(), 
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Підключаємося до бази даних Supabase
  await Supabase.initialize(
    url: 'https://mywhapfxkqjvqtakfxfe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15d2hhcGZ4a3FqdnF0YWtmeGZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyODkwODIsImV4cCI6MjA4Nzg2NTA4Mn0.ZgN4lcZ_Qwn9YXRKsTChZye6GWgAYEt-s05iswep-NQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouOptimal',
      debugShowCheckedModeBanner: false, // Прибираємо червону стрічку "DEBUG"
      theme: ThemeData(
        primaryColor: const Color(0xFF485759),
        scaffoldBackgroundColor: const Color(0xFFF7F3E8), // Ваш фірмовий фон
        fontFamily: 'SFPro', // Основний шрифт із макетів
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Запускаємо головний екран
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:ui'; // Потрібно для налаштування миші та тачпаду

// Твої імпорти екранів та стану (залиш свої, якщо вони відрізняються)
import 'screens/home_screen.dart';
import 'state/app_state.dart'; 

void main() {
  runApp(const YouOptimalApp());
}

// 1. СТВОРЮЄМО КАСТОМНУ ФІЗИКУ СКРОЛІНГУ
class SmoothScrollBehavior extends MaterialScrollBehavior {
  // Дозволяємо тягнути екран мишкою на Web/Desktop
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  // Вмикаємо плавну iOS-фізику (Bouncing) для всіх списків
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class YouOptimalApp extends StatelessWidget {
  const YouOptimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState.theme,
      builder: (context, themeValue, _) {
        // Логіка твоєї теми...
        
        return MaterialApp(
          title: 'YouOptimal',
          debugShowCheckedModeBanner: false,
          
          // 2. ПІДКЛЮЧАЄМО НАШ ПЛАВНИЙ СКРОЛІНГ СЮДИ
          scrollBehavior: SmoothScrollBehavior(), 
          
          theme: ThemeData(
            scaffoldBackgroundColor: AppState.bgMain,
            fontFamily: 'Roboto', // Або ваш фірмовий шрифт
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
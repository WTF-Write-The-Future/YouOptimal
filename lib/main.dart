import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const YouOptimalApp());
}

class YouOptimalApp extends StatelessWidget {
  const YouOptimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Слухаємо зміну теми
    return ValueListenableBuilder(
      valueListenable: AppState.theme,
      builder: (context, themeVal, _) {
        // Слухаємо зміну мови
        return ValueListenableBuilder(
          valueListenable: AppState.language,
          builder: (context, langVal, _) {
            return MaterialApp(
              // МАГІЯ: Цей ключ змушує весь додаток повністю перемалюватися при зміні мови або теми!
              key: ValueKey('$themeVal-$langVal'), 
              title: 'YouOptimal',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.black,
                  brightness: AppState.isDark ? Brightness.dark : Brightness.light,
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: AppState.bgMain,
                textTheme: GoogleFonts.interTextTheme(
                  Theme.of(context).textTheme,
                ).apply(
                  bodyColor: AppState.textMain,
                  displayColor: AppState.textMain,
                ),
              ),
              home: const HomeScreen(),
            );
          }
        );
      }
    );
  }
}
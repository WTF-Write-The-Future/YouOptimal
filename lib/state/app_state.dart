import 'package:flutter/material.dart';
import '../models/city.dart';

class AppState {
  // Налаштування

  static final language = ValueNotifier<String>('auto');
  static final currency = ValueNotifier<String>('USD');


  // Улюблені міста
  static final favorites = ValueNotifier<List<City>>([]);

  static void toggleFavorite(City city) {
    final current = List<City>.from(favorites.value);
    if (current.any((c) => c.id == city.id)) {
      current.removeWhere((c) => c.id == city.id);
    } else {
      current.add(city);
    }
    favorites.value = current;
  }

  static bool isFavorite(City city) {
    return favorites.value.any((c) => c.id == city.id);
  }

  // Отримання значка валюти
  static String getCurrencySymbol() {
    switch (currency.value) {
      case 'EUR': return '€';
      case 'UAH': return '₴';
      default: return '\$';
    }
  }

  // Конвертація ціни з базової (USD) у вибрану
  static int convertPrice(int usdPrice) {
    switch (currency.value) {
      case 'EUR': return (usdPrice * 0.92).round(); // Курс євро
      case 'UAH': return (usdPrice * 42.0).round(); // Курс гривні
      default: return usdPrice; // Долар залишається доларом
    }
  }

  // === КОЛЬОРОВА ПАЛІТРА ДЛЯ ТЕМНОЇ/СВІТЛОЇ ТЕМИ ===
 static ValueNotifier<String> theme = ValueNotifier('Light'); 
 static ValueNotifier<String> tempUnit = ValueNotifier('C');
  static bool get isDark => theme.value == 'Dark';
  
  static Color get bgMain => isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F9);
  static Color get bgCard => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  static Color get bgHeader => isDark ? const Color(0xFF181818) : Colors.white;
  
  static Color get textMain => isDark ? Colors.white : Colors.black87;
  static Color get textMuted => isDark ? Colors.white54 : Colors.black54;
  static Color get border => isDark ? Colors.white12 : Colors.black12;
  
  static Color get btnPrimary => isDark ? Colors.white : const Color(0xFF2D2D2D);
  static Color get btnPrimaryText => isDark ? Colors.black : Colors.white;
}
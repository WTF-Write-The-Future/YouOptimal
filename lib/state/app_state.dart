import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/city.dart';
import '../screens/auth_screen.dart';

class AppState {
  // === Налаштування ===
  static final language = ValueNotifier<String>('auto');
  static final currency = ValueNotifier<String>('USD');
  static final tempUnit = ValueNotifier<String>('C');

  // === Дані міст ===
  static final favorites = ValueNotifier<List<City>>([]);
  // Важливо: cachedCities має заповнюватися при старті HomeScreen
  static List<City> cachedCities = []; 

  // === Логіка "Обраного" ===
  
  static Future<void> toggleFavorite(BuildContext context, City city) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showAuthSnackBar(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
      return; 
    }

    // Копіюємо поточний список
    final List<City> currentFavs = List<City>.from(favorites.value);
    final bool isExist = currentFavs.any((c) => c.id == city.id);

    try {
      if (isExist) {
        // 1. Видаляємо з бази
        await supabase
            .from('favourite') 
            .delete()
            .match({'city_id': city.id, 'user_id': user.id});
        
        // 2. Оновлюємо UI тільки після успіху в БД
        currentFavs.removeWhere((c) => c.id == city.id);
      } else {
        // 1. Додаємо в базу
        await supabase.from('favourite').insert({
          'city_id': city.id,
          'user_id': user.id,
          'added_at': DateTime.now().toIso8601String(),
        });
        
        // 2. Оновлюємо UI
        currentFavs.add(city);
      }
      favorites.value = currentFavs;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      // Можна додати повідомлення про помилку мережі
    }
  }

  // === Синхронізація з Supabase ===
  static Future<void> syncFavorites() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null || cachedCities.isEmpty) {
      favorites.value = [];
      return;
    }

    try {
      // Отримуємо список ID з таблиці favourite
      final List<dynamic> data = await supabase
          .from('favourite')
          .select('city_id')
          .eq('user_id', user.id);

      // Перетворюємо в Set для швидкого пошуку
      final Set<int> favoriteIds = data.map((item) => item['city_id'] as int).toSet();

      // Співставляємо ID з об'єктами City, які вже є в кеші
      favorites.value = cachedCities.where((city) => favoriteIds.contains(city.id)).toList();
      
      debugPrint('Favorites synced: ${favorites.value.length} items');
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  static void clearFavorites() {
    favorites.value = [];
  }

  static bool isFavorite(City city) {
    return favorites.value.any((c) => c.id == city.id);
  }

  // === Допоміжні методи ===

  static void _showAuthSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFC9BA9B), 
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF4A5556)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please sign in to save favorites!',
                style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF4A5556), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String getCurrencySymbol() {
    switch (currency.value) {
      case 'EUR': return '€';
      case 'UAH': return '₴';
      default: return '\$';
    }
  }

  static int convertPrice(int usdPrice) {
    switch (currency.value) {
      case 'EUR': return (usdPrice * 0.92).round();
      case 'UAH': return (usdPrice * 42.0).round();
      default: return usdPrice; 
    }
  }
  // === КОНВЕРТАЦІЯ ТЕМПЕРАТУРИ ===
  static String getFormattedTemperature(double tempC) {
    if (tempUnit.value == 'F') {
      final tempF = tempC * 9 / 5 + 32;
      return '${tempF.toStringAsFixed(1)}°F';
    }
    return '${tempC.toStringAsFixed(1)}°C';
  }

  // === ЗБЕРЕЖЕННЯ НАЛАШТУВАНЬ В БАЗУ ДАНИХ ===
  static Future<void> savePreference(String column, String value) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) return; // Якщо не залогінений - зберігаємо тільки локально

    try {
      // Припускаємо, що колонка з ID користувача у таблиці users називається 'id' (або 'user_id')
      await supabase
          .from('users')
          .update({column: value})
          .eq('id', user.id); // Якщо у тебе колонка називається інакше, заміни 'id' на свою
    } catch (e) {
      debugPrint('Error saving preference to DB: $e');
    }
  }

  // === ПІДТЯГУВАННЯ НАЛАШТУВАНЬ З БАЗИ ===
  static Future<void> syncPreferences() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) return;

    try {
      final data = await supabase
          .from('users')
          .select('currency, temp_unit')
          .eq('id', user.id)
          .single();

      // Оновлюємо локальні змінні, якщо в базі є дані
      if (data['currency'] != null) currency.value = data['currency'];
      if (data['temp_unit'] != null) tempUnit.value = data['temp_unit'];
      
    } catch (e) {
      debugPrint('Error syncing preferences from DB: $e');
    }
  }
  static void resetPreferences() {
    currency.value = 'USD'; // Повертаємо стандартну валюту
    tempUnit.value = 'C';   // Повертаємо стандартну температуру
  }
}
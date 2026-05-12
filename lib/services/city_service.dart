import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/city.dart';

class CityService {
  static final _supabase = Supabase.instance.client;

  // 1. Приватні змінні для кешування (Інкапсуляція)
  static List<City>? _cachedCities;
  static DateTime? _lastFetchTime;
  
  // Час життя кешу (наприклад, 10 хвилин)
  static const _cacheDuration = Duration(minutes: 10); 

  /// [forceRefresh] дозволяє примусово оновити дані, ігноруючи кеш
  static Future<List<City>> fetchCities({bool forceRefresh = false}) async {
    
    // 2. Логіка кешування (Cache Hit)
    if (!forceRefresh && _cachedCities != null && _lastFetchTime != null) {
      final isCacheValid = DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
      if (isCacheValid) {
        print('⚡️ Дані міст взято з локального кешу');
        return _cachedCities!;
      }
    }

    // 3. Запит до сервера (Cache Miss)
    try {
      print('🌐 Виконується запит до Supabase...');
      final List<dynamic> data = await _supabase.from('city').select('*, citymetrics(*)');

      final cities = data.map((json) {
        return City.fromJson(json);
      }).toList();
      
      // Зберігаємо отримані дані в кеш
      _cachedCities = cities;
      _lastFetchTime = DateTime.now();

      return cities;
      
    } catch (e) {
      // 4. Глобальна обробка помилок
      print('🚨 Помилка завантаження з Supabase: $e');
      
      // Замість повернення пустого масиву, ми "прокидаємо" (throw) помилку далі.
      // Це дозволить нашому Provider-у "зловити" її та показати UI.
      throw Exception('Не вдалося завантажити список міст. Перевірте з\'єднання з інтернетом.'); 
    }
  }
}
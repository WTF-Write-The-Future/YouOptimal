import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/city.dart';

class CityService {
  static final _supabase = Supabase.instance.client;

  static Future<List<City>> fetchCities() async {
    try {
      final List<dynamic> data = await _supabase.from('city').select('*, citymetrics(*)');

      return data.map((json) {
        return City.fromJson(json); // парсинг з урахуванням метрик
      }).toList();
      
    } catch (e) {
      print('🚨 Помилка завантаження з Supabase: $e');
      return []; 
    }
  }
}
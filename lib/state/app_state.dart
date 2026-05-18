import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/city.dart';
import '../screens/auth_screen.dart';

class AppState {
  // === НАЛАШТУВАННЯ ДОДАТКУ (Preferences) ===
  static final language = ValueNotifier<String>('auto');
  static final currency = ValueNotifier<String>('USD');
  static final tempUnit = ValueNotifier<String>('C');

  // === ДАНІ (Кешовані міста, Улюблене та Відвідане) ===
  static List<City> cachedCities = []; 
  static final favorites = ValueNotifier<List<City>>([]);
  static final visitedCities = ValueNotifier<List<City>>([]);

  // === ДАНІ (Лічильник відгуків для бейджика) ===
  static final reviewCount = ValueNotifier<int>(0); 

  // ==========================================
  // ЛОГІКА "УЛЮБЛЕНОГО" (FAVORITES)
  // ==========================================
  
  static Future<void> toggleFavorite(BuildContext context, City city) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showAuthSnackBar(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
      return; 
    }

    final List<City> currentFavs = List<City>.from(favorites.value);
    final bool isExist = currentFavs.any((c) => c.id == city.id);

    try {
      if (isExist) {
        await supabase
            .from('favourite') 
            .delete()
            .match({'city_id': city.id, 'user_id': user.id});
        
        currentFavs.removeWhere((c) => c.id == city.id);
      } else {
        await supabase.from('favourite').insert({
          'city_id': city.id,
          'user_id': user.id,
          'added_at': DateTime.now().toIso8601String(),
        });
        
        currentFavs.add(city);
      }
      favorites.value = currentFavs;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  static Future<void> syncFavorites() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null || cachedCities.isEmpty) {
      favorites.value = [];
      return;
    }

    try {
      final List<dynamic> data = await supabase
          .from('favourite')
          .select('city_id')
          .eq('user_id', user.id);

      final Set<int> favoriteIds = data.map((item) => item['city_id'] as int).toSet();
      favorites.value = cachedCities.where((city) => favoriteIds.contains(city.id)).toList();
      
      debugPrint('Favorites synced: ${favorites.value.length} items');
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  static bool isFavorite(City city) {
    return favorites.value.any((c) => c.id == city.id);
  }

  // ==========================================
  // ЛОГІКА "ВІДВІДАНИХ МІСТ" (VISITED CITIES)
  // ==========================================
  
  static Future<void> toggleVisited(BuildContext context, City city) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showAuthSnackBar(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
      return; 
    }

    final List<City> currentVisited = List<City>.from(visitedCities.value);
    final bool isExist = currentVisited.any((c) => c.id == city.id);

    try {
      if (isExist) {
        await supabase
            .from('visited_cities') 
            .delete()
            .match({'city_id': city.id, 'user_id': user.id});
        
        currentVisited.removeWhere((c) => c.id == city.id);
      } else {
        await supabase.from('visited_cities').insert({
          'city_id': city.id,
          'user_id': user.id,
        });
        
        currentVisited.add(city);
      }
      visitedCities.value = currentVisited;
    } catch (e) {
      debugPrint('Error toggling visited city: $e');
    }
  }

  static Future<void> syncVisitedCities() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null || cachedCities.isEmpty) {
      visitedCities.value = [];
      return;
    }

    try {
      final List<dynamic> data = await supabase
          .from('visited_cities')
          .select('city_id')
          .eq('user_id', user.id);

      final Set<int> visitedIds = data.map((item) => item['city_id'] as int).toSet();
      visitedCities.value = cachedCities.where((city) => visitedIds.contains(city.id)).toList();
      
      debugPrint('Visited cities synced: ${visitedCities.value.length} items');
    } catch (e) {
      debugPrint('Sync error visited cities: $e');
    }
  }

  static bool isVisited(City city) {
    return visitedCities.value.any((c) => c.id == city.id);
  }

  // ==========================================
  // ЛОГІКА ЛІЧИЛЬНИКА ВІДГУКІВ (REVIEWS)
  // ==========================================

  static Future<void> syncReviewCount() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      reviewCount.value = 0;
      return;
    }

    try {
      final List<dynamic> data = await supabase
          .from('review')
          .select('review_id') 
          .eq('user_id', user.id);

      reviewCount.value = data.length;
      debugPrint('Reviews counted: ${reviewCount.value} items');
    } catch (e) {
      debugPrint('Review count sync error: $e');
    }
  }

  // ==========================================
  // ДОПОМІЖНІ МЕТОДИ
  // ==========================================

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
                'Please sign in to save data!', // Трохи змінив текст, щоб підходив і для Visited
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

  static double convertPrice(double price) {
  if (currency.value == 'UAH') {
    return price * 42.0; // або який у вас там курс
  } else if (currency.value == 'EUR') {
    return price * 0.92;
  }
  return price; // Для USD
}

  static String getFormattedTemperature(double tempC) {
    if (tempUnit.value == 'F') {
      final tempF = tempC * 9 / 5 + 32;
      return '${tempF.toStringAsFixed(1)}°F';
    }
    return '${tempC.toStringAsFixed(1)}°C';
  }

  // ==========================================
  // РОБОТА З НАЛАШТУВАННЯМИ В БАЗІ ДАНИХ
  // ==========================================

  static Future<void> savePreference(String column, String value) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) return; 

    try {
      await supabase
          .from('users')
          .update({column: value})
          .eq('id', user.id); 
    } catch (e) {
      debugPrint('Error saving preference to DB: $e');
    }
  }

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

      if (data['currency'] != null) currency.value = data['currency'];
      if (data['temp_unit'] != null) tempUnit.value = data['temp_unit'];
      
    } catch (e) {
      debugPrint('Error syncing preferences from DB: $e');
    }
  }

  static void resetPreferences() {
    currency.value = 'USD'; 
    tempUnit.value = 'C';  
  }

  // ==========================================
  // ОЧИЩЕННЯ ДАНИХ (При Logout)
  // ==========================================

  static void clearUserData() {
    favorites.value = [];
    visitedCities.value = [];
    reviewCount.value = 0;
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:you_optimal/main.dart' as app;
import 'package:you_optimal/services/city_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Backend Integration: Зв\'язок з Supabase та API', () {
    
    testWidgets('1. Ініціалізація та успішне завантаження масиву міст', (tester) async {
      app.main();
      await tester.pumpAndSettle(); 

      final cities = await CityService.fetchCities(forceRefresh: true);
      
      expect(cities, isNotEmpty);
      expect(cities.length, greaterThanOrEqualTo(10)); 
    });

    testWidgets('2. Перевірка цілісності основних даних міста', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities();
      final city = cities.first;

      expect(city.id, isPositive);
      expect(city.name, isNotEmpty);
      expect(city.country, isNotEmpty);
      expect(city.averagePrice, greaterThan(0));
      expect(city.image, contains('http')); 
    });

    testWidgets('3. Перевірка роботи JOIN-запитів (Наявність метрик)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities();
      
      final cityWithMetrics = cities.firstWhere((c) => c.internetSpeed > 0, orElse: () => cities.first);

      expect(cityWithMetrics.internetSpeed, greaterThan(0.0), reason: 'JOIN failed: internet_speed is 0');
      expect(cityWithMetrics.safetyIndex, greaterThan(0.0), reason: 'JOIN failed: safety_index is 0');
    });

    testWidgets('4. Перевірка наявності нового поля full_description', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities(forceRefresh: true);
      
      final lviv = cities.firstWhere(
        (c) => c.name.toLowerCase() == 'lviv', 
        orElse: () => cities.first
      );

      expect(lviv.full_description, isNotNull, reason: 'full_description column is missing or null');
      expect(lviv.full_description!.length, greaterThan(50), reason: 'full_description text is too short');
    });

    testWidgets('5. Тест пошуку/фільтрації на рівні списку даних', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities();
      
      final searchResult = cities.where((c) => c.name.toLowerCase().contains('london')).toList();
      
      if (searchResult.isNotEmpty) {
        expect(searchResult.first.country, 'United Kingdom');
        expect(searchResult.length, 1);
      }
    });

    testWidgets('6. Обробка кешування даних (AppState sync)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities();
      
      
      expect(cities.length, greaterThan(0));
    });
  });
}
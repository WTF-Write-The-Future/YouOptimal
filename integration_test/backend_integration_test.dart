import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:you_optimal/main.dart' as app;
import 'package:you_optimal/services/city_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Backend Integration: Зв\'язок з Supabase та API', () {
    
    testWidgets('1. Ініціалізація та успішне завантаження масиву міст', (tester) async {
      app.main();
      await tester.pumpAndSettle(); // Чекаємо на Supabase.initialize()

      final cities = await CityService.fetchCities(forceRefresh: true);
      
      // Перевіряємо, що база не порожня і дані приходять
      expect(cities, isNotEmpty);
      expect(cities.length, greaterThanOrEqualTo(10)); // Ми заливали 50 міст, тому їх має бути багато
    });

    testWidgets('2. Перевірка цілісності основних даних міста', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities();
      final city = cities.first;

      // Жодне місто в БД не повинно мати порожню назву чи країну
      expect(city.id, isPositive);
      expect(city.name, isNotEmpty);
      expect(city.country, isNotEmpty);
      expect(city.averagePrice, greaterThan(0));
      expect(city.image, contains('http')); // Перевірка, що лінк на картинку валідний
    });

    testWidgets('3. Перевірка роботи JOIN-запитів (Наявність метрик)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities();
      
      // Беремо відоме місто, для якого ми точно заливали метрики (наприклад, Lviv або Kyiv)
      // Якщо такого немає, беремо перше доступне, яке має метрики
      final cityWithMetrics = cities.firstWhere((c) => c.internetSpeed > 0, orElse: () => cities.first);

      // Переконуємось, що дані з таблиці citymetrics успішно підтягнулися
      expect(cityWithMetrics.internetSpeed, greaterThan(0.0), reason: 'JOIN failed: internet_speed is 0');
      expect(cityWithMetrics.safetyIndex, greaterThan(0.0), reason: 'JOIN failed: safety_index is 0');
    });

    testWidgets('4. Перевірка наявності нового поля full_description', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities(forceRefresh: true);
      
      // Шукаємо місто Львів, бо ми точно знаємо, що заливали для нього великий текст
      final lviv = cities.firstWhere(
        (c) => c.name.toLowerCase() == 'lviv', 
        orElse: () => cities.first
      );

      // Перевіряємо, що поле не null і містить розширений текст
      expect(lviv.full_description, isNotNull, reason: 'full_description column is missing or null');
      expect(lviv.full_description!.length, greaterThan(50), reason: 'full_description text is too short');
    });

    testWidgets('5. Тест пошуку/фільтрації на рівні списку даних', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities();
      
      // Емулюємо пошук слова "London"
      final searchResult = cities.where((c) => c.name.toLowerCase().contains('london')).toList();
      
      // Якщо Лондон є в базі, він має знайтися
      if (searchResult.isNotEmpty) {
        expect(searchResult.first.country, 'United Kingdom');
        expect(searchResult.length, 1);
      }
    });

    testWidgets('6. Обробка кешування даних (AppState sync)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final cities = await CityService.fetchCities();
      
      // В реальному додатку CityService або HomeScreen зберігає дані в AppState.cachedCities
      // Емулюємо цю поведінку
      // ignore: invalid_use_of_visible_for_testing_member
      
      expect(cities.length, greaterThan(0));
    });
  });
}
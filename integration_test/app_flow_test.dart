import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:you_optimal/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests: Повний цикл YouOptimal', () {
    
    testWidgets('1. Завантаження головного екрану', (tester) async {
      app.main();
      await tester.pumpAndSettle(); 
      await Future.delayed(const Duration(seconds: 2)); 

      expect(find.text('Discover your city.'), findsWidgets);
    });

    testWidgets('2. Тестування пошуку', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Lviv');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
    });

    testWidgets('3. Тестування фільтрів та сортування', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final filterButton = find.text('Filter');
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2)); 

        final resetButton = find.text('Reset');
        if (resetButton.evaluate().isNotEmpty) {
          await tester.tap(resetButton);
          await tester.pumpAndSettle();
        }
      }

      final sortButton = find.text('Sort by');
      if (sortButton.evaluate().isNotEmpty) {
        await tester.tap(sortButton.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2)); 
        
        await tester.tap(find.text('Price: Low to High'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('4. Перехід на екран деталей міста', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      // Шукаємо кнопку VIEW
      final viewButton = find.text('VIEW').first;
      final scrollable = find.byType(Scrollable).first;

      // Скролимо, поки не побачимо кнопку
      await tester.scrollUntilVisible(viewButton, 200.0, scrollable: scrollable);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      
      // Натискаємо
      await tester.tap(viewButton, warnIfMissed: false);
      
      // ВАЖЛИВО: Чекаємо довше, поки пройде анімація переходу
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await Future.delayed(const Duration(seconds: 2));

      // Перевіряємо заголовок секції (використовуємо find.textContaining для надійності)
      expect(find.textContaining('ABOUT'), findsWidgets);
      
      // Якщо REVIEWS не знайдено через великі літери, спробуємо знайти частину слова
      expect(find.textContaining('REVIEW'), findsWidgets);

      await Future.delayed(const Duration(seconds: 2));

      // Повертаємось назад через AppBar Back Button
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
      } else {
        // Якщо немає BackButton, пробуємо знайти логотип
        final logo = find.byType(Image).first;
        await tester.tap(logo);
      }
      await tester.pumpAndSettle();
    });

    testWidgets('5. Перевірка екрану Settings', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2)); 

        expect(find.text('SETTINGS'), findsOneWidget);

        final eurButton = find.text('EUR');
        if (eurButton.evaluate().isNotEmpty) {
          await tester.tap(eurButton);
          await tester.pumpAndSettle();
        }
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('6. Перевірка екрану About Us', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final aboutButton = find.text('About us');
      if (aboutButton.evaluate().isNotEmpty) {
        await tester.tap(aboutButton.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 3)); 

        expect(find.text('Who We Are'), findsOneWidget);
        expect(find.text('Our Tech Stack'), findsOneWidget);
      }
    });

    testWidgets('7. Екран авторизації (Auth Flow)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final signInButton = find.text('Sign in');
      if (signInButton.evaluate().isNotEmpty) {
        await tester.tap(signInButton.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2)); 

        expect(find.text('YOUOPTIMAL'), findsOneWidget);
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'test@gmail.com');
          await tester.enterText(textFields.at(1), 'password123');
          await tester.pumpAndSettle();
        }

        final registerToggle = find.text('Already have an account ?');
        if (registerToggle.evaluate().isNotEmpty) {
          await tester.tap(registerToggle);
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2)); 
          expect(find.text('REGISTER'), findsOneWidget);
        }
      }
    });
  });
}
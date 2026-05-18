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

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('2. Успішний пошук міста', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      final searchField = find.byType(TextField).first;
      
      await tester.enterText(searchField, 'Lviv');
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      expect(find.text('LVIV'), findsWidgets);
      
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
    });

    testWidgets('3. Пошук неіснуючого міста (Негативний сценарій)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'NonExistentCity123');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('LVIV'), findsNothing);
    });

    testWidgets('4. Тестування фільтрів та сортування', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final filterButton = find.text('Filter');
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton.first);
        await tester.pumpAndSettle();

        final resetButton = find.text('Reset');
        if (resetButton.evaluate().isNotEmpty) {
          await tester.tap(resetButton);
          await tester.pumpAndSettle();
        }
      }
    });

  testWidgets('5. Перехід на екран деталей міста (View Button)', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.enterText(find.byType(TextField).first, 'Lviv');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final viewButton = find.text('VIEW').first;
      
      await tester.dragUntilVisible(
        viewButton,
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      
      await tester.tap(viewButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.textContaining('ABOUT'), findsWidgets);
    });

    testWidgets('6. Перевірка динамічного Full Description', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'Lviv');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final viewButton = find.text('VIEW').first;
      await tester.dragUntilVisible(viewButton, find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      
      await tester.tap(viewButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      bool foundLongDescription = textWidgets.any((t) => t.data != null && t.data!.length > 50);

      expect(foundLongDescription, true);
    });

    testWidgets('7. Взаємодія з обраним (Favorites) на екрані деталей', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'Lviv');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final viewButton = find.text('VIEW').first;
      await tester.dragUntilVisible(viewButton, find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      
      await tester.tap(viewButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      Finder favoriteIcon = find.byIcon(Icons.favorite_border);
      if (favoriteIcon.evaluate().isEmpty) {
        favoriteIcon = find.byIcon(Icons.favorite);
      }

      expect(favoriteIcon, findsWidgets);

      await tester.ensureVisible(favoriteIcon.first);
      await tester.pumpAndSettle();

      await tester.tap(favoriteIcon.first);
      await tester.pumpAndSettle();

    });

    testWidgets('8. Перевірка екрану Settings та зміни валюти', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton.first);
        await tester.pumpAndSettle();

        final uahButton = find.text('UAH');
        if (uahButton.evaluate().isNotEmpty) {
          await tester.tap(uahButton);
          await tester.pumpAndSettle();
        }
        
        await tester.pageBack();
        await tester.pumpAndSettle();
        
        expect(find.textContaining('₴'), findsWidgets);
      }
    });

    testWidgets('9. Перевірка зміни одиниць температури', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Lviv');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton.first);
        await tester.pumpAndSettle();

        final fahrenheitButton = find.textContaining('F'); 
        if (fahrenheitButton.evaluate().isNotEmpty) {
          await tester.tap(fahrenheitButton.first);
          await tester.pumpAndSettle();
        }

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.textContaining('F'), findsWidgets);
      }
    });

    testWidgets('10. Перевірка екрану About Us', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final aboutButton = find.text('About us');
      if (aboutButton.evaluate().isNotEmpty) {
        await tester.tap(aboutButton.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 1));

        expect(find.text('Who We Are'), findsOneWidget);
      }
    });

    testWidgets('11. Екран авторизації: Невалідні дані (Negative Test)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final signInButton = find.text('Sign in');
      if (signInButton.evaluate().isNotEmpty) {
        await tester.tap(signInButton.first);
        await tester.pumpAndSettle();
        
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'bad_email');
          await tester.enterText(textFields.at(1), '123');
          await tester.pumpAndSettle();
        }

        final loginBtn = find.text('LOGIN');
        if (loginBtn.evaluate().isNotEmpty) {
           await tester.tap(loginBtn);
           await tester.pumpAndSettle();
           
           expect(find.text('YOUOPTIMAL'), findsOneWidget);
        }
      }
    });

    testWidgets('12. Екран авторизації: Перемикання на Register', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final signInButton = find.text('Sign in');
      if (signInButton.evaluate().isNotEmpty) {
        await tester.tap(signInButton.first);
        await tester.pumpAndSettle();

        final registerToggle = find.text('Already have an account ?');
        if (registerToggle.evaluate().isNotEmpty) {
          await tester.tap(registerToggle);
          await tester.pumpAndSettle();
          
          expect(find.text('REGISTER'), findsOneWidget);
        }
      }
    });

  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:you_optimal/models/city.dart';
import 'package:you_optimal/models/review.dart';
import 'package:you_optimal/state/app_state.dart';

void main() {
  group('Unit Tests: Модель City & Парсинг JSON', () {
    test('1. Повний мапінг усіх полів City (включаючи full_description)', () {
      final Map<String, dynamic> json = {
        'city_id': 77,
        'name': 'Lviv',
        'country': 'Ukraine',
        'photo_url': 'https://link.com/lviv.jpg',
        'avg_cost': 550.0,
        'rating': 95.0,
        'description': 'Short description',
        'full_description': 'Very long and detailed description of Lviv.',
        'citymetrics': [
          {
            'temperature': 16.96,
            'air_quality_index': 60.0,
            'internet_speed': 110.0,
            'safety_index': 75.0,
            'rent_1_room': 400.0
          }
        ]
      };

      final city = City.fromJson(json);

      expect(city.id, 77);
      expect(city.name, 'Lviv');
      expect(city.averagePrice, 550.0);
      expect(city.full_description, 'Very long and detailed description of Lviv.');
      expect(city.temperature, 16.96);
      expect(city.internetSpeed, 110.0);
      expect(city.rent1Room, 400.0);
    });

    test('2. Null-safety: Дефолтні значення при порожньому JSON', () {
      final Map<String, dynamic> emptyJson = {};
      final city = City.fromJson(emptyJson);

      expect(city.id, 0);
      expect(city.name, 'Unknown');
      expect(city.country, 'Unknown');
      expect(city.averagePrice, 0.0);
      expect(city.full_description, null);
      expect(city.temperature, null); // Оскільки це nullable поле
      expect(city.safetyIndex, 0.0); // Обов'язкове поле має підставити дефолтне 0.0
    });

    test('3. Обробка відсутності масиву citymetrics (Graceful degradation)', () {
      final Map<String, dynamic> jsonWithoutMetrics = {
        'city_id': 10,
        'name': 'Test City',
        // citymetrics відсутній
      };

      final city = City.fromJson(jsonWithoutMetrics);
      expect(city.name, 'Test City');
      expect(city.temperature, null);
      expect(city.internetSpeed, 0.0);
    });
  });

  group('Unit Tests: Бізнес-логіка AppState (Валюта та Температура)', () {
    setUp(() {
      // Скидаємо стан перед кожним тестом, щоб вони були незалежними
      AppState.resetPreferences();
    });

    test('4. Конвертація валют: USD -> UAH', () {
      AppState.currency.value = 'UAH';
      expect(AppState.getCurrencySymbol(), '₴');
      expect(AppState.convertPrice(100), 4200); // 100 * 42
    });

    test('5. Конвертація валют: USD -> EUR', () {
      AppState.currency.value = 'EUR';
      expect(AppState.getCurrencySymbol(), '€');
      expect(AppState.convertPrice(1000), 920); // 1000 * 0.92
    });

    test('6. Крайні значення валют (Нульова ціна)', () {
      AppState.currency.value = 'UAH';
      expect(AppState.convertPrice(0), 0);
    });

    test('7. Округлення температури (toStringAsFixed)', () {
      // Має округлити 16.96 до 17.0
      AppState.tempUnit.value = 'C';
      expect(AppState.getFormattedTemperature(16.96), '17.0°C');
      expect(AppState.getFormattedTemperature(22.12), '22.1°C');
    });

    test('8. Конвертація в Фаренгейти (°C -> °F)', () {
      AppState.tempUnit.value = 'F';
      // 0°C = 32°F
      expect(AppState.getFormattedTemperature(0.0), '32.0°F');
      // 20°C = 68°F
      expect(AppState.getFormattedTemperature(20.0), '68.0°F');
    });
  });

  group('Unit Tests: Управління списками (Favorites & Visited)', () {
    final testCity = City(
      id: 99, 
      name: 'Mock City', 
      country: 'Mockland', 
      image: '', 
      averagePrice: 100, 
      rating: 50, 
      description: '', 
      internetSpeed: 10, 
      safetyIndex: 10
    );

    setUp(() => AppState.clearUserData());

    test('9. Логіка додавання та видалення з Favorites', () {
      expect(AppState.isFavorite(testCity), false);

      AppState.favorites.value = [testCity];
      expect(AppState.isFavorite(testCity), true);

      AppState.favorites.value = [];
      expect(AppState.isFavorite(testCity), false);
    });

    test('10. Логіка відвіданих міст (Visited Cities)', () {
      expect(AppState.isVisited(testCity), false);

      AppState.visitedCities.value = [testCity];
      expect(AppState.isVisited(testCity), true);
    });

    test('11. Очищення даних користувача (clearUserData)', () {
      AppState.favorites.value = [testCity];
      AppState.visitedCities.value = [testCity];
      AppState.reviewCount.value = 5;

      AppState.clearUserData();

      expect(AppState.favorites.value.isEmpty, true);
      expect(AppState.visitedCities.value.isEmpty, true);
      expect(AppState.reviewCount.value, 0);
    });
  });

  group('Unit Tests: Модель Review', () {
    test('12. Правильний розрахунок середнього рейтингу відгуку', () {
      final review = Review(
        authorName: 'Oleksandr',
        text: 'Great place!',
        safetyRating: 5,
        architectureRating: 4,
        cultureRating: 3,
        createdAt: DateTime.now(),
      );

      // (5 + 4 + 3) / 3 = 12 / 3 = 4.0
      expect(review.averageRating, 4.0);
    });
  });
}
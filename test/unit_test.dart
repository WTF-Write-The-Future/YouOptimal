import 'package:flutter_test/flutter_test.dart';
import 'package:you_optimal/models/city.dart';
import 'package:you_optimal/models/review.dart';
import 'package:you_optimal/state/app_state.dart';

void main() {
  // ==========================================
  // ТЕСТИ МОДЕЛІ: CITY
  // ==========================================
  group('Unit Tests: Модель City', () {
    test('1. Правильний парсинг City з JSON', () {
      // Використовуємо ключі рівно так, як вони приходять від Supabase
      final Map<String, dynamic> json = {
        'city_id': 101, // Твоя модель шукає саме 'city_id'
        'name': 'Paris',
        'country': 'France',
        'photo_url': 'https://link.com/paris.jpg',
        'avg_cost': 1200.0,
        'rating': 90.0,
        'citymetrics': [
          {
            'temperature': 22.5,
            'air_quality_index': 45.0,
            'rent_1_room': 800.0,
          }
        ]
      };

      final city = City.fromJson(json);

      expect(city.id, 101);
      expect(city.name, 'Paris');
      expect(city.country, 'France');
      expect(city.image, 'https://link.com/paris.jpg');
      expect(city.averagePrice, 1200.0);
      expect(city.rating, 90.0);
      
      // Перевірка вкладених метрик
      expect(city.temperature, 22.5);
      expect(city.airQualityIndex, 45.0);
      expect(city.rent1Room, 800.0);
      expect(city.safetyIndex, null); // Цього поля не було в JSON, має бути null
    });

    test('2. Безпечний парсинг City з порожнього JSON (Null Safety)', () {
      final Map<String, dynamic> emptyJson = {};

      final city = City.fromJson(emptyJson);

      expect(city.id, 0); // Дефолтне значення з твоєї моделі
      expect(city.name, 'Unknown');
      expect(city.averagePrice, 0.0);
      expect(city.temperature, null); // Метрики мають бути null
    });
  });

  // ==========================================
  // ТЕСТИ МОДЕЛІ: REVIEW
  // ==========================================
  group('Unit Tests: Модель Review', () {
    test('3. Вирахування середнього балу (averageRating)', () {
      final review = Review(
        authorName: 'Sasha',
        text: 'Great city!',
        safetyRating: 4,
        architectureRating: 5,
        cultureRating: 3,
        createdAt: DateTime.now(),
      );

      // (4 + 5 + 3) / 3 = 4.0
      expect(review.averageRating, 4.0);
    });

    test('4. Парсинг Review з JOIN-даними міста', () {
      final Map<String, dynamic> json = {
        'author_name': 'Bozhena',
        'text': 'Beautiful architecture',
        'safety_rating': 5,
        'architecture_rating': 5,
        'culture_rating': 5,
        'created_at': '2026-05-12T12:00:00Z',
        'city': {
          'name': 'Rome',
          'photo_url': 'rome.jpg'
        }
      };

      final review = Review.fromJson(json);

      expect(review.authorName, 'Bozhena');
      expect(review.averageRating, 5.0);
      expect(review.cityName, 'Rome'); // Підтягнулося з вкладеного об'єкта
      expect(review.cityImage, 'rome.jpg');
    });
  });

  // ==========================================
  // ТЕСТИ СТАНУ ДОДАТКУ: APP STATE
  // ==========================================
  group('Unit Tests: Бізнес-логіка AppState', () {
    
    setUp(() {
      // Скидаємо налаштування перед кожним тестом
      AppState.resetPreferences();
    });

    test('5. Конвертація валют (USD -> EUR -> UAH)', () {
      const int basePriceUSD = 1000;

      // Тест USD (Дефолт)
      expect(AppState.currency.value, 'USD');
      expect(AppState.convertPrice(basePriceUSD), 1000);
      expect(AppState.getCurrencySymbol(), '\$');

      // Тест EUR
      AppState.currency.value = 'EUR';
      expect(AppState.convertPrice(basePriceUSD), 920); // 1000 * 0.92
      expect(AppState.getCurrencySymbol(), '€');

      // Тест UAH
      AppState.currency.value = 'UAH';
      expect(AppState.convertPrice(basePriceUSD), 42000); // 1000 * 42.0
      expect(AppState.getCurrencySymbol(), '₴');
    });

    test('6. Форматування та конвертація температури (°C -> °F)', () {
      const double baseTempC = 20.0;

      // Тест Цельсія
      AppState.tempUnit.value = 'C';
      expect(AppState.getFormattedTemperature(baseTempC), '20.0°C');

      // Тест Фаренгейта (20 * 9/5 + 32 = 68)
      AppState.tempUnit.value = 'F';
      expect(AppState.getFormattedTemperature(baseTempC), '68.0°F');
    });

    test('7. Перевірка логіки списків (isFavorite / isVisited)', () {
      final city = City(
        id: 99, 
        name: 'Test City', 
        country: 'Test', 
        image: '', 
        averagePrice: 10, 
        rating: 10
      );

      // Спочатку списки порожні
      AppState.favorites.value = [];
      AppState.visitedCities.value = [];

      expect(AppState.isFavorite(city), false);
      expect(AppState.isVisited(city), false);

      // Додаємо в обране
      AppState.favorites.value = [city];
      expect(AppState.isFavorite(city), true);
      expect(AppState.isVisited(city), false); // У відвіданих його ще немає

      // Додаємо у відвідані
      AppState.visitedCities.value = [city];
      expect(AppState.isVisited(city), true);
    });
    
    test('8. Очищення даних (clearUserData)', () {
      AppState.reviewCount.value = 5;
      AppState.favorites.value = [City(id: 1, name: 'A', country: 'B', image: '', averagePrice: 0, rating: 0)];
      
      AppState.clearUserData();

      expect(AppState.reviewCount.value, 0);
      expect(AppState.favorites.value.isEmpty, true);
      expect(AppState.visitedCities.value.isEmpty, true);
    });
  });
}
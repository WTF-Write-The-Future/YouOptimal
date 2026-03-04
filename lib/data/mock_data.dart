import 'dart:convert'; // Вбудована бібліотека Dart для роботи з JSON
import '../models/city.dart';

// 1. Наш JSON-контракт (імітація відповіді від сервера)
const String apiJsonResponse = '''
[
  {"id":1,"name":"Lviv","country":"Ukraine","temperature":14.5,"coffee_price":2.0,"safety_score":85,"photo_url":"https://example.com/lviv.jpg","average_price":550},
  {"id":2,"name":"Kyiv","country":"Ukraine","temperature":16.0,"coffee_price":4.2,"safety_score":98,"photo_url":"https://example.com/kyiv.jpg","average_price":250},
  {"id":3,"name":"Rome","country":"Italy","temperature":21.0,"coffee_price":1.7,"safety_score":100,"photo_url":"https://example.com/rome.jpg","average_price":175},
  {"id":4,"name":"Chop","country":"Ukraine","temperature":10.3,"coffee_price":20.0,"safety_score":20,"photo_url":"https://example.com/chop.jpg","average_price":725},
  {"id":5,"name":"Warsaw","country":"Poland","temperature":15.0,"coffee_price":2.0,"safety_score":65,"photo_url":"https://example.com/warsaw.jpg","average_price":480},
  {"id":6,"name":"Radekhiv","country":"Ukraine","temperature":30.0,"coffee_price":2.0,"safety_score":100,"photo_url":"https://example.com/radekhiv.jpg","average_price":300}
]
''';

// 2. Функція, яка перетворює текст JSON на справжній список List<City>
List<City> loadCitiesFromJson() {
  // Розшифровуємо текст у список словників (Map)
  final List<dynamic> parsedJson = jsonDecode(apiJsonResponse);
  
  // Проходимось по кожному елементу і створюємо об'єкт City
  return parsedJson.map((jsonItem) => City.fromJson(jsonItem)).toList();
}
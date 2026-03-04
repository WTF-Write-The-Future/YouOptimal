class City {
  final int id;
  final String name;
  final String country;
  final double temperature;
  final double coffeePrice;
  final int safetyScore;
  final String photoUrl;
  final int averagePrice;

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.temperature,
    required this.coffeePrice,
    required this.safetyScore,
    required this.photoUrl,
    required this.averagePrice,
  });

  // МАГІЯ ТУТ: Фабричний метод, який бере шматок JSON і створює з нього місто
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      // .toDouble() потрібен, бо JSON може передати ціле число (напр. 15 замість 15.0)
      temperature: json['temperature'].toDouble(),
      coffeePrice: json['coffee_price'].toDouble(),
      safetyScore: json['safety_score'],
      photoUrl: json['photo_url'],
      averagePrice: json['average_price'],
    );
  }
}
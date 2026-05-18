class Review {
  final String authorName;
  final String text;
  final int safetyRating;
  final int architectureRating;
  final int cultureRating;
  final DateTime createdAt;
  
  final String? cityName;
  final String? cityImage;

  Review({
    required this.authorName,
    required this.text,
    required this.safetyRating,
    required this.architectureRating,
    required this.cultureRating,
    required this.createdAt,
    this.cityName,
    this.cityImage,
  });

  // Вираховуємо середній бал відгуку
  double get averageRating => (safetyRating + architectureRating + cultureRating) / 3;

  factory Review.fromJson(Map<String, dynamic> json) {
    final cityData = json['city'];

    return Review(
      authorName: json['author_name'] ?? 'Anonymous',
      text: json['text'] ?? '',
      safetyRating: json['safety_rating'] ?? 5,
      architectureRating: json['architecture_rating'] ?? 5,
      cultureRating: json['culture_rating'] ?? 5,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      cityName: cityData != null ? cityData['name'] : null,
      cityImage: cityData != null ? (cityData['photo_url'] ?? cityData['image']) : null,
    );
  }
}
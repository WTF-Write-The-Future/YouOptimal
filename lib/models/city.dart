class City {
  final int id;
  final String name;
  final String country;
  final String image;
  final double averagePrice;
  final double rating;
  final String description;
  final String? full_description;
  
  // Основні метрики
  final double internetSpeed;
  final double safetyIndex;
  
  // Додаткові метрики
  final double? tempMin;
  final double? tempMax;
  final double? airQualityIndex;
  final double? atmosphericPressure;
  final double? rent1Room;
  final double? rent2Room;
  final double? rent3Room;
  final double? rentHouse;
  final double? taxiPrice;
  final double? publicTransportPrice;

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.image,
    required this.averagePrice,
    required this.rating,
    required this.description,
    required this.internetSpeed,
    required this.safetyIndex,
    this.full_description,
    this.airQualityIndex,
    this.tempMin,
    this.tempMax,
    this.atmosphericPressure,
    this.rent1Room,
    this.rent2Room,
    this.rent3Room,
    this.rentHouse,
    this.taxiPrice,
    this.publicTransportPrice,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    final metricsList = json['citymetrics'] as List<dynamic>?;
    final metrics = (metricsList != null && metricsList.isNotEmpty) 
        ? metricsList.first as Map<String, dynamic> 
        : null;

    return City(
      id: (json['city_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      country: json['country']?.toString() ?? 'Unknown',
      image: json['photo_url']?.toString() ?? '',
      averagePrice: (json['avg_cost'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? 'No description available.',
      
      full_description: json['full_description']?.toString(), 
      
      internetSpeed: (metrics?['internet_speed'] as num?)?.toDouble() ?? 
                     (json['internet_speed'] as num?)?.toDouble() ?? 0.0,
      safetyIndex: (metrics?['safety_index'] as num?)?.toDouble() ?? 
                   (json['safety_index'] as num?)?.toDouble() ?? 0.0,

      tempMin: (metrics?['temp_min'] as num?)?.toDouble(),
      tempMax: (metrics?['temp_max'] as num?)?.toDouble(),
      airQualityIndex: (metrics?['air_quality_index'] as num?)?.toDouble(),
      atmosphericPressure: (metrics?['atmospheric_pressure'] as num?)?.toDouble(),
      rent1Room: (metrics?['rent_1_room'] as num?)?.toDouble(),
      rent2Room: (metrics?['rent_2_room'] as num?)?.toDouble(),
      rent3Room: (metrics?['rent_3_room'] as num?)?.toDouble(),
      rentHouse: (metrics?['rent_house'] as num?)?.toDouble(),
      taxiPrice: (metrics?['taxi_price'] as num?)?.toDouble(),
      publicTransportPrice: (metrics?['public_transport_price'] as num?)?.toDouble(),
    );
  }
}
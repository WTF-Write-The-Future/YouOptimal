import 'package:flutter/material.dart';
import '../models/city.dart';
import '../screens/city_details_screen.dart';
import '../state/app_state.dart';

class CityCardFull extends StatelessWidget {
  final City city;
  final bool isMobile;

  const CityCardFull({super.key, required this.city, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ФОНОВЕ ЗОБРАЖЕННЯ
            Positioned.fill(
              child: city.image.isNotEmpty && city.image.length > 10
                ? Image.network(city.image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder())
                : _buildPlaceholder(),
            ),
            
            // ТЕМНИЙ ГРАДІЄНТ ЗНИЗУ
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.85)],
                    stops: const [0.4, 0.65, 1.0],
                  ),
                ),
              ),
            ),

            // КНОПКА "В ОБРАНЕ" (Сердечко)
            Positioned(
              top: 16,
              right: 16,
              child: ValueListenableBuilder<List<City>>(
                valueListenable: AppState.favorites,
                builder: (context, favorites, child) {
                  bool isFav = AppState.isFavorite(city);
                  return GestureDetector(
                    onTap: () => AppState.toggleFavorite(context, city),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), shape: BoxShape.circle),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 22),
                    ),
                  );
                },
              ),
            ),

            // НИЖНІЙ БЛОК З ТЕКСТОМ (Більш компактний)
            Positioned(
              left: 20, right: 20, bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // НАЗВА МІСТА
                      Expanded(
                        child: Text(
                          city.name.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'SFPro', 
                            color: Colors.white, 
                            fontSize: 36, 
                            fontWeight: FontWeight.w900, 
                            height: 1.0, // Менша висота рядка для компактності
                            letterSpacing: 0,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // ЦІНА
                      ValueListenableBuilder<String>(
                        valueListenable: AppState.currency,
                        builder: (context, currentCurrency, child) {
                          String price = AppState.convertPrice(city.averagePrice.toInt()).toString();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0, right: 2.0),
                                child: Text(AppState.getCurrencySymbol(), style: const TextStyle(fontFamily: 'SFPro', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                price, 
                                style: const TextStyle(
                                  fontFamily: 'SFPro', 
                                  color: Colors.white, 
                                  fontSize: 36, 
                                  fontWeight: FontWeight.w900, 
                                  height: 1.0 // Компактна висота
                                )
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 18.0, left: 2.0),
                                child: Text('/mo', style: TextStyle(fontFamily: 'SFPro', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // Зменшено відступ
                  
                  // ОПИС
                  Text(
                    'Explore the beautiful city of ${city.name} in ${city.country}. We\'ll put in some lorem ipsum to show how a filled-out page might look.',
                    style: const TextStyle(
                      fontFamily: 'SFPro', 
                      color: Colors.white, 
                      fontSize: 14, 
                      fontWeight: FontWeight.normal, 
                      height: 1.3, // Трохи щільніший текст
                    ),
                    maxLines: 3, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16), // Зменшено відступ
                  
                  // КНОПКА ТА ЗІРКИ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CityDetailsScreen(city: city))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F3E8), 
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: const Text('VIEW', style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF2B3233), fontWeight: FontWeight.w900)),
                        ),
                      ),
                      _buildStars(city.rating),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9FAEB3), Color(0xFF2B3233)], 
        ),
      ),
      child: const Center(child: Icon(Icons.domain, size: 48, color: Colors.black87)),
    );
  }

  Widget _buildStars(double rating) {
    int starCount = (city.rating / 20).ceil();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < starCount ? Icons.star : Icons.star_border,
          color: Colors.white, 
          size: 18,
        );
      }),
    );
  }
}
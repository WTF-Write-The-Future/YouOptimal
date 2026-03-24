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
            Positioned.fill(
              child: city.image.isNotEmpty && city.image.length > 10
                ? Image.network(city.image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder())
                : _buildPlaceholder(),
            ),
            
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.8)],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: ValueListenableBuilder<List<City>>(
                valueListenable: AppState.favorites,
                builder: (context, favorites, child) {
                  bool isFav = AppState.isFavorite(city);
                  return GestureDetector(
                    onTap: () => AppState.toggleFavorite(city),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 22),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              left: 24, right: 24, bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          city.name.toUpperCase(),
                          style: const TextStyle(fontFamily: 'DM Serif Text', color: Colors.white, fontSize: 24),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      ValueListenableBuilder<String>(
                        valueListenable: AppState.currency,
                        builder: (context, currentCurrency, child) {
                          String price = AppState.convertPrice(city.averagePrice.toInt()).toString();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppState.getCurrencySymbol(), style: const TextStyle(fontFamily: 'DM Serif Text', color: Colors.white, fontSize: 16)),
                              Text(price, style: const TextStyle(fontFamily: 'DM Serif Text', color: Colors.white, fontSize: 32, height: 1.0)),
                              const Padding(
                                padding: EdgeInsets.only(top: 14.0),
                                child: Text('/mo', style: TextStyle(fontFamily: 'DM Serif Text', color: Colors.white70, fontSize: 14)),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Explore the beautiful city of ${city.name} in ${city.country}.',
                    style: const TextStyle(fontFamily: 'DM Serif Text', color: Colors.white, fontSize: 14),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CityDetailsScreen(city: city))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFC1D7D8), borderRadius: BorderRadius.circular(20)),
                          child: const Text('VIEW', style: TextStyle(fontFamily: 'DM Serif Text', color: Colors.black87)),
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
      color: Colors.orangeAccent, 
      size: 16,
    );
  }),
   );
  }
}
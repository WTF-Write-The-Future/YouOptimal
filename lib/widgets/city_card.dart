import 'package:flutter/material.dart';
import '../models/city.dart';
import '../screens/city_details_screen.dart';
import '../state/app_state.dart';
import '../utils/premium_transition.dart';

class CityCardFull extends StatefulWidget {
  final City city;
  final bool isMobile;

  const CityCardFull({super.key, required this.city, this.isMobile = false});

  @override
  State<CityCardFull> createState() => _CityCardFullState();
}

class _CityCardFullState extends State<CityCardFull> with TickerProviderStateMixin {
  // 1. Контролер для кнопки "Відвідано"
  late AnimationController _visitedController;
  late Animation<double> _visitedAnimation;

  // 2. Контролер для кнопки "В обране"
  late AnimationController _favController;
  late Animation<double> _favAnimation;

  @override
  void initState() {
    super.initState();
    
    // Ініціалізація анімації для "Відвідано"
    _visitedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _visitedAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _visitedController, curve: Curves.easeInOut),
    );

    // Ініціалізація анімації для "В обране"
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _favAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _favController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _visitedController.dispose();
    _favController.dispose();
    super.dispose();
  }

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
              child: Hero(
                tag: 'hero-city-image-${widget.city.id}', 
                child: Material(
                  type: MaterialType.transparency, 
                  child: widget.city.image.isNotEmpty && widget.city.image.length > 10
                    ? Image.network(widget.city.image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder())
                    : _buildPlaceholder(),
                ),
              ),
            ),
  
            
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

            // КНОПКИ (Відвідане + Обране) 
            Positioned(
              top: 16,
              right: 16,
              child: ValueListenableBuilder<List<City>>(
                valueListenable: AppState.visitedCities,
                builder: (context, visited, child) {
                  bool isVisited = AppState.isVisited(widget.city);
                  
                  return ValueListenableBuilder<List<City>>(
                    valueListenable: AppState.favorites,
                    builder: (context, favorites, child) {
                      bool isFav = AppState.isFavorite(widget.city);
                      
                      return Row(
                        children: [
                          // === КНОПКА "ВІДВІДАНО" ===
                          GestureDetector(
                            onTap: () {
                              AppState.toggleVisited(context, widget.city);
                              _visitedController.forward().then((_) => _visitedController.reverse());
                            },
                            child: AnimatedBuilder(
                              animation: _visitedAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _visitedAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), shape: BoxShape.circle),
                                  child: Icon(
                                    isVisited ? Icons.beenhere : Icons.beenhere_outlined, 
                                    color: isVisited ? Colors.greenAccent : Colors.white, 
                                    size: 22
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), 
                          
                          // === КНОПКА "В ОБРАНЕ" (Сердечко) ===
                          GestureDetector(
                            onTap: () {
                              AppState.toggleFavorite(context, widget.city);
                              _favController.forward().then((_) => _favController.reverse());
                            },
                            child: AnimatedBuilder(
                              animation: _favAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _favAnimation.value, 
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), shape: BoxShape.circle),
                                  child: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border, 
                                    color: isFav ? const Color(0xFFC9BA9B) : Colors.white, 
                                    size: 22
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // НИЖНІЙ БЛОК З ТЕКСТОМ
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
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0), 
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // Автоматично зменшує шрифт, якщо не влазить
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.city.name.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'SFPro', 
                                color: Colors.white, 
                                fontSize: 36, 
                                fontWeight: FontWeight.w900, 
                                height: 1.0, 
                                letterSpacing: 0,
                              ),
                              maxLines: 1, 
                            ),
                          ),
                        ),
                      ),
                      
                      // ЦІНА
                      ValueListenableBuilder<String>(
                        valueListenable: AppState.currency,
                        builder: (context, currentCurrency, child) {
String price = AppState.convertPrice(widget.city.averagePrice).toStringAsFixed(0);
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
                                  height: 1.0
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
                  const SizedBox(height: 6),
                  
                  // ОПИС
                 Text(
  widget.city.description, 
  style: const TextStyle(
    fontFamily: 'SFPro', 
    color: Colors.white, 
    fontSize: 14, 
    height: 1.3,
  ),
  maxLines: 3, 
  overflow: TextOverflow.ellipsis,
),
                  const SizedBox(height: 16),
                  
                  // КНОПКА ТА ЗІРКИ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context, PremiumTransition(page: CityDetailsScreen(city: widget.city))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F3E8), 
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: const Text('VIEW', style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF2B3233), fontWeight: FontWeight.w900)),
                        ),
                      ),
                      _buildStars(widget.city.rating),
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

 Widget _buildStars(double ratingFromDb) {
  double starValue = ratingFromDb / 20; 

  int fullStars = starValue.floor(); 
  
  double fractionalPart = starValue - fullStars;
  bool hasHalfStar = fractionalPart >= 0.25 && fractionalPart < 0.75;
  
  if (fractionalPart >= 0.75) {
    fullStars++;
    hasHalfStar = false;
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          if (index < fullStars) {
            return const Icon(Icons.star_rounded, color: Color(0xFFE8C872), size: 14);
          } else if (index == fullStars && hasHalfStar) {
            return const Icon(Icons.star_half_rounded, color: Color(0xFFE8C872), size: 14);
          } else {
            return Icon(Icons.star_outline_rounded, color: Colors.white.withOpacity(0.5), size: 14);
          }
        }),
      ),
      const SizedBox(width: 4),
      Text(
        starValue.toStringAsFixed(1), 
        style: const TextStyle(
          fontFamily: 'SFPro', 
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
      ),
    ],
  );
}
}
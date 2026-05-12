import 'package:flutter/material.dart';
import '../models/city.dart';
import '../state/app_state.dart';
import '../screens/city_details_screen.dart';
import '../utils/premium_transition.dart';

class CityCardMobile extends StatelessWidget {
  final City city;

  const CityCardMobile({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, PremiumTransition(page: CityDetailsScreen(city: city))),
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // 1. ФОТО
              // 1. ФОТО
              Positioned.fill(
                child: Hero(
                  tag: 'hero-city-image-${city.id}',
                  child: Material(
                    type: MaterialType.transparency, // МАГІЯ ДЛЯ ПЛАВНОСТІ
                    child: city.image.isNotEmpty 
                      ? Image.network(
                          city.image, 
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                        )
                      : Container(color: Colors.grey),
                  ),
                ),
              ),

              // 2. ГРАДІЄНТ
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. КОНТЕНТ
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Кнопка VIEW
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'VIEW', 
                            style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black)
                          ),
                        ),
                        
                        // АНІМОВАНІ ІКОНКИ СТАТУСІВ
                        Row(
                          children: [
                            // Анімована "Галочка"
                            ValueListenableBuilder<List<City>>(
                              valueListenable: AppState.visitedCities,
                              builder: (context, visitedList, _) {
                                bool isVisited = visitedList.any((c) => c.id == city.id);
                                return AnimatedStatusIcon(
                                  isActive: isVisited,
                                  activeIcon: Icons.check_circle_rounded,
                                  inactiveIcon: Icons.check_circle_outline_rounded,
                                  activeColor: const Color(0xFF53D769),
                                  onTap: () => AppState.toggleVisited(context, city),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            // Анімоване "Серце"
                            ValueListenableBuilder<List<City>>(
                              valueListenable: AppState.favorites,
                              builder: (context, favList, _) {
                                bool isFav = favList.any((c) => c.id == city.id);
                                return AnimatedStatusIcon(
                                  isActive: isFav,
                                  activeIcon: Icons.favorite,
                                  inactiveIcon: Icons.favorite_border,
                                  activeColor: const Color(0xFFC9BA9B),
                                  onTap: () => AppState.toggleFavorite(context, city),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    
                    // ІНФО (Назва, Ціна)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city.name.toUpperCase(), 
                                style: const TextStyle(fontFamily: 'SFPro', color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.1)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Explore the beautiful city of ${city.name} in ${city.country}.", 
                                style: TextStyle(fontFamily: 'SFPro', color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${AppState.getCurrencySymbol()}${AppState.convertPrice(city.averagePrice.toInt())}/mo',
                              style: const TextStyle(fontFamily: 'SFPro', color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.0),
                            ),
                            const SizedBox(height: 4),
                            _buildStars(city.rating),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    int starCount = (rating / 20).ceil();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) => Icon(
        index < starCount ? Icons.star : Icons.star_border,
        color: Colors.white,
        size: 14,
      )),
    );
  }
}

// --- НОВИЙ ДОПОМІЖНИЙ ВІДЖЕТ З АНІМАЦІЄЮ ---

class AnimatedStatusIcon extends StatefulWidget {
  final bool isActive;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final VoidCallback onTap;

  const AnimatedStatusIcon({
    super.key,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<AnimatedStatusIcon> createState() => _AnimatedStatusIconState();
}

class _AnimatedStatusIconState extends State<AnimatedStatusIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedStatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Якщо статус змінився (наприклад, через БД), граємо анімацію "попу"
    if (widget.isActive != oldWidget.isActive) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isActive 
                ? widget.activeColor.withValues(alpha: 0.2) 
                : Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isActive ? widget.activeColor : Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Icon(
              widget.isActive ? widget.activeIcon : widget.inactiveIcon,
              key: ValueKey<bool>(widget.isActive),
              color: widget.isActive ? widget.activeColor : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
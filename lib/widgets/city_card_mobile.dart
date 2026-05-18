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
      onTap: () => Navigator.push(
        context, 
        PremiumTransition(page: CityDetailsScreen(city: city))
      ),
      child: Container(
        height: 240,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
              Positioned.fill(
                child: Hero(
                  tag: 'hero-city-image-${city.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: city.image.isNotEmpty 
                      ? Image.network(
                          city.image, 
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported)),
                        )
                      : Container(color: Colors.grey),
                  ),
                ),
              ),

              // 2. ГРАДІЄНТ
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. КОНТЕНТ
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // ПАНЕЛЬ ІКОНОК (ВЕРХ)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          Row(
                            children: [
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

                      // НАЗВА ТА ЦІНА
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            city.name.toUpperCase(), 
                            style: const TextStyle(
                              fontFamily: 'SFPro', 
                              color: Colors.white, 
                              fontSize: 28, 
                              fontWeight: FontWeight.w900, 
                              height: 1.1
                            ),
                          ),
                          Text(
                            '${AppState.getCurrencySymbol()}${AppState.convertPrice(city.averagePrice.toDouble())}/mo',
                            style: const TextStyle(
                              fontFamily: 'SFPro', 
                              color: Colors.white, 
                              fontSize: 22, 
                              fontWeight: FontWeight.w900, 
                              height: 1.0
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),

                      // ОПИС ТА РЕЙТИНГ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              city.description, 
                              style: TextStyle(
                                fontFamily: 'SFPro', 
                                color: Colors.white.withOpacity(0.8), 
                                fontSize: 12,
                                height: 1.2
                              ),
                              
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildStars(city.rating),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedStatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _controller.forward(from: 0.0);
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
                ? widget.activeColor.withOpacity(0.2) 
                : Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isActive ? widget.activeColor : Colors.white.withOpacity(0.3),
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
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
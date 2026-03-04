import 'package:flutter/material.dart';
import '../models/city.dart';
import '../screens/city_details_screen.dart';
import '../state/app_state.dart';

class CityCardFull extends StatelessWidget {
  final City city;
  final bool isMobile;

  const CityCardFull({super.key, required this.city, required this.isMobile});

  Widget _buildStars(int score) {
    int starCount = (score / 20).round();
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < starCount ? Icons.star : Icons.star_border,
          size: 20, // Трохи збільшив зірочки
          color: AppState.textMain, 
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ЛІВА ЧАСТИНА: ФОТО + КНОПКА VIEW (Яка наповзає на фото)
        SizedBox(
          width: isMobile ? 140 : 220, 
          height: isMobile ? 130 : 180,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: isMobile ? 140 : 220,
                height: isMobile ? 100 : 150, // Фото не на всю висоту, залишаємо місце
                decoration: BoxDecoration(
                  color: AppState.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBEBEB), 
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(child: Icon(Icons.image_outlined, size: 48, color: AppState.textMuted.withOpacity(0.3))),
              ),
              // ПЛАВАЮЧА КНОПКА VIEW
              Positioned(
                bottom: isMobile ? 14 : 14, // Наповзає на нижній край картинки
                child: SizedBox(
                  height: 32,
                  width: 90,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D2D), // Чорний фон
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CityDetailsScreen(city: city)));
                    },
                    child: const Text('VIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: isMobile ? 16 : 32), // Відступ від фото до тексту
        
        // ПРАВА ЧАСТИНА: ВЕЛИЧЕЗНІ ТЕКСТИ
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(city.name, style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold, fontSize: isMobile ? 20 : 28)),
                        const SizedBox(height: 4),
                        Text(city.country, style: TextStyle(color: AppState.textMuted, fontSize: 15)), // Сабтайтл
                      ],
                    ),
                  ),
                  // ВЕЛИЧЕЗНА ЦІНА
                  ValueListenableBuilder(
                    valueListenable: AppState.currency,
                    builder: (context, _, __) {
                      int convertedPrice = AppState.convertPrice(city.averagePrice);
                      String symbol = AppState.getCurrencySymbol();
                      
                      return RichText(
                        text: TextSpan(
                          style: TextStyle(color: AppState.textMain),
                          children: [
                            TextSpan(text: symbol, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            TextSpan(text: '$convertedPrice', style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
                            TextSpan(text: ' / mo', style: TextStyle(fontSize: 12, color: AppState.textMuted, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Body text for your whole article or post. We\'ll put in some lorem ipsum to show how a filled-out page might look:',
                style: TextStyle(fontSize: 12, color: AppState.textMuted, height: 1.4),
                maxLines: isMobile ? 4 : 3, 
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildStars(city.safetyScore),
            ],
          ),
        ),
      ],
    );
  }
}
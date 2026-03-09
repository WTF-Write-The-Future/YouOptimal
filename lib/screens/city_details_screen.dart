import 'package:flutter/material.dart';
import '../models/city.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';
import 'review_screen.dart';
import '../utils/premium_transition.dart';

class CityDetailsScreen extends StatelessWidget {
  final City city;

  const CityDetailsScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: AppState.bgMain, 
      appBar: const MainAppHeader(showFavourite: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ЧОРНА КНОПКА НАЗАД
          Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 24.0, bottom: 20.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.click, 
                child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white, size: 16))
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ДВОКОЛОНКОВИЙ ЛЕЙАУТ
                      isMobile 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImage(),
                              const SizedBox(height: 24),
                              _buildAboutCity(),
                              const SizedBox(height: 24),
                              _buildCityInfo(context),
                              const SizedBox(height: 24),
                              _buildReviewButton(context),
                            ],
                          )
                        : IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ЛІВА КОЛОНКА (Фото + About City)
                                Expanded(
                                  flex: 5, 
                                  child: Column(
                                    children: [
                                      _buildImage(),
                                      const SizedBox(height: 24),
                                      _buildAboutCity(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 40),
                                // ПРАВА КОЛОНКА (Інфо + Кнопка Review знизу)
                                Expanded(
                                  flex: 4, 
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildCityInfo(context),
                                      const Spacer(), // Відштовхує кнопку Review в самий низ
                                      _buildReviewButton(context),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      
                      const SizedBox(height: 60),

                      // СЕКЦІЯ ВІДГУКІВ
                      Text('Latest reviews', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppState.textMain)),
                      const SizedBox(height: 24),
                      Wrap(spacing: 24, runSpacing: 24, children: [_buildReviewCard(), _buildReviewCard(), _buildReviewCard()]),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ФОТО-ПЛЕЙСХОЛДЕР
  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(decoration: BoxDecoration(color: AppState.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBEBEB), borderRadius: BorderRadius.circular(8)), child: Center(child: Icon(Icons.image_outlined, size: 80, color: AppState.textMuted.withOpacity(0.3)))),
    );
  }

  // БЛОК "ABOUT CITY"
  Widget _buildAboutCity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppState.bgCard, border: Border.all(color: AppState.border), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('About city', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppState.textMain)), 
              Icon(Icons.keyboard_arrow_up, color: AppState.textMain)
            ],
          ),
          const SizedBox(height: 16),
          Text('Answer the frequently asked question in a simple sentence, a longish paragraph, or even in a list.', style: TextStyle(color: AppState.textMuted, height: 1.5)),
        ],
      ),
    );
  }

  // ІНФОРМАЦІЯ ПРО МІСТО (Права колонка)
  Widget _buildCityInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city.name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppState.textMain)),
            ValueListenableBuilder(
              valueListenable: AppState.favorites,
              builder: (context, _, __) {
                bool isFav = AppState.isFavorite(city);
                return GestureDetector(
                  onTap: () => AppState.toggleFavorite(city),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 20),
                    ),
                  ),
                );
              }
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
          child: const Text('Tag', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(height: 16),
        
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
                  TextSpan(text: '$convertedPrice', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
                ],
              ),
            );
          }
        ),
        
        const SizedBox(height: 24),
        
        // --- БЕЙДЖІ (ТЕПЕР ІЗ ТЕМПЕРАТУРОЮ З JSON ТА КОНВЕРТАЦІЄЮ) ---
       ValueListenableBuilder(
          valueListenable: AppState.tempUnit,
          builder: (context, _, __) {
            String unit = AppState.tempUnit.value; // 'C' або 'F'
            
            // Беремо температуру з JSON
            int tempC = city.temperature.toInt(); 
            
            // Конвертуємо, якщо Фаренгейт
            int displayTemp = unit == 'F' ? (tempC * 9 ~/ 5 + 32) : tempC;
            
            // ДОДАЛИ КРУЖЕЧОК "°" ОСЬ ТУТ:
            return _buildStatBadge(Icons.wb_sunny_outlined, '$displayTemp°$unit');
          }
        ),
        _buildStatBadge(Icons.wifi, 'Internet speed'),
        _buildStatBadge(Icons.language, 'Language'),
        _buildStatBadge(Icons.location_on_outlined, 'Infrastructure'),
        _buildStatBadge(Icons.trending_up, 'Prices'),
        
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D2D2D), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            onPressed: () {}, icon: const Icon(Icons.play_circle_fill, size: 18), label: const Text('Music'),
          ),
        ),
      ],
    );
  }

  // ОНОВЛЕНИЙ БЕЙДЖ
  Widget _buildStatBadge(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppState.isDark ? const Color(0xFF333333) : const Color(0xFFEBEBEB), 
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppState.textMain),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ЧОРНА КНОПКА REVIEW БЕЗ ЛІНІЇ
  Widget _buildReviewButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D2D2D), 
        foregroundColor: Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
      // ПЛАВНИЙ ПЕРЕХІД НА ЕКРАН ВІДГУКІВ
      onPressed: () => Navigator.push(context, PremiumTransition(page: ReviewScreen(city: city))),
      child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // КАРТКА ВІДГУКУ
  Widget _buildReviewCard() {
    return Container(
      width: 300, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppState.bgCard, border: Border.all(color: AppState.border), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (index) => Icon(Icons.star_border, size: 20, color: AppState.textMain))),
          const SizedBox(height: 16),
          Text('Review title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppState.textMain)),
          const SizedBox(height: 8),
          Text('Review body', style: TextStyle(color: AppState.textMuted)),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: const NetworkImage('https://randomuser.me/api/portraits/women/44.jpg'),
                backgroundColor: AppState.isDark ? const Color(0xFF333333) : const Color(0xFFEBEBEB),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text('Reviewer name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppState.textMain)), 
                  Text('Date', style: TextStyle(color: AppState.textMuted, fontSize: 12))
                ]
              ),
            ],
          )
        ],
      ),
    );
  }
}
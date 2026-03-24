import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';
import '../models/city.dart';
import 'city_details_screen.dart';
import '../utils/premium_transition.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8), // Фірмовий фон
      appBar: const MainAppHeader(showFavourite: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Кнопка назад
          Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 24.0, bottom: 20.0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32, 
                  decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle), 
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 16)
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ValueListenableBuilder<List<City>>(
              valueListenable: AppState.favorites,
              builder: (context, favorites, _) {
                if (favorites.isEmpty) {
                  return Center(
                    child: Text(
                      'No favourite cities yet ❤️', 
                      style: TextStyle(
                        fontFamily: 'DM Serif Text',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppState.textMain
                      )
                    )
                  );
                }

                // Логіка пагінації
                int totalPages = (favorites.length / _itemsPerPage).ceil();
                if (totalPages == 0) totalPages = 1;
                if (_currentPage > totalPages) _currentPage = totalPages;

                List<City> paginatedFavorites = favorites
                    .skip((_currentPage - 1) * _itemsPerPage)
                    .take(_itemsPerPage)
                    .toList();

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(24), 
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05), 
                            blurRadius: 30, 
                            offset: const Offset(0, 10)
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 24, runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: paginatedFavorites.map((city) => _buildFavoriteCard(city)).toList(),
                          ),
                          
                          if (totalPages > 1) ...[
                            const SizedBox(height: 40),
                            _buildPagination(totalPages),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Картка міста в обраному
  Widget _buildFavoriteCard(City city) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: const Color(0xFFE0E0E0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Зображення міста
          Container(
            height: 180, 
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB), 
              borderRadius: BorderRadius.circular(8),
              image: city.image.isNotEmpty 
                ? DecorationImage(image: NetworkImage(city.image), fit: BoxFit.cover) 
                : null,
            ), 
            child: city.image.isEmpty 
              ? Center(child: Icon(Icons.image_outlined, color: Colors.grey.withValues(alpha: 0.3), size: 64))
              : null,
          ),
          const SizedBox(height: 16),
          Text(city.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'DM Serif Text')),
          const SizedBox(height: 4),
          
          // Ціна з конвертацією
          ValueListenableBuilder(
            valueListenable: AppState.currency,
            builder: (context, _, __) {
              int convertedPrice = AppState.convertPrice(city.averagePrice.toInt());
              String symbol = AppState.getCurrencySymbol();
              return Text('$symbol$convertedPrice', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1));
            }
          ),
          const SizedBox(height: 4),
          Text(city.country, style: const TextStyle(color: Colors.grey, fontSize: 14)), 
          const SizedBox(height: 24),
          
          // Кнопки дій
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                onPressed: () => Navigator.push(context, PremiumTransition(page: CityDetailsScreen(city: city))),
                child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click, 
                child: GestureDetector(
                  onTap: () {
                    AppState.toggleFavorite(city);
                    setState(() {}); 
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12), 
                    decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle), 
                    child: const Icon(Icons.favorite, color: Colors.white, size: 18)
                  )
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Блок пагінації
  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () { if (_currentPage > 1) setState(() => _currentPage--); },
          child: MouseRegion(cursor: SystemMouseCursors.click, child: Text('← Previous', style: TextStyle(color: _currentPage > 1 ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
        const SizedBox(width: 16),
        ...List.generate(totalPages, (index) {
          int pageNum = index + 1;
          return _buildPageNumber(pageNum, isActive: pageNum == _currentPage);
        }),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () { if (_currentPage < totalPages) setState(() => _currentPage++); },
          child: MouseRegion(cursor: SystemMouseCursors.click, child: Text('Next →', style: TextStyle(color: _currentPage < totalPages ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
      ],
    );
  }

  Widget _buildPageNumber(int number, {bool isActive = false}) {
    return GestureDetector(
      onTap: () => setState(() => _currentPage = number),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 28, height: 28,
          decoration: BoxDecoration(color: isActive ? const Color(0xFF2D2D2D) : Colors.transparent, borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: Text(number.toString(), style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12))
          ),
        ),
      ),
    );
  }
}
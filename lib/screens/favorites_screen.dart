import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';
import '../models/city.dart';
import 'city_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 3; // Показуємо по 3 картки в ряд, як на макеті

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppState.bgMain,
      appBar: const MainAppHeader(showFavourite: true), // Увімкнули Favourite в хедері
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ЧОРНА КНОПКА НАЗАД (Під логотипом зліва)
          Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 24.0, bottom: 20.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 32, height: 32, 
                  decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle), 
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 16)
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: AppState.favorites,
              builder: (context, favorites, _) {
                if (favorites.isEmpty) {
                  return Center(
                    child: Text('No favourite cities yet ❤️', style: TextStyle(fontSize: 20, color: AppState.textMuted))
                  );
                }

                // Логіка пагінації для улюблених
                int totalPages = (favorites.length / _itemsPerPage).ceil();
                if (totalPages == 0) totalPages = 1;
                
                // Захист від виходу за межі сторінок при видаленні останнього елемента на сторінці
                if (_currentPage > totalPages) _currentPage = totalPages;

                List<City> paginatedFavorites = favorites.skip((_currentPage - 1) * _itemsPerPage).take(_itemsPerPage).toList();

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1100), // Широкий контейнер для 3 карток
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppState.bgCard, 
                        borderRadius: BorderRadius.circular(24), 
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))]
                      ),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 24, runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: paginatedFavorites.map((city) {
                              return Container(
                                width: 300,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppState.bgCard, 
                                  borderRadius: BorderRadius.circular(16), 
                                  border: Border.all(color: AppState.border)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 180, 
                                      decoration: BoxDecoration(color: AppState.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBEBEB), borderRadius: BorderRadius.circular(8)), 
                                      child: Center(child: Icon(Icons.image_outlined, color: AppState.textMuted.withOpacity(0.3), size: 64))
                                    ),
                                    const SizedBox(height: 16),
                                    Text(city.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppState.textMain)),
                                    const SizedBox(height: 4),
                                    ValueListenableBuilder(
                                      valueListenable: AppState.currency,
                                      builder: (context, _, __) {
                                        int convertedPrice = AppState.convertPrice(city.averagePrice);
                                        String symbol = AppState.getCurrencySymbol();
                                        return Text('$symbol$convertedPrice', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1, color: AppState.textMain));
                                      }
                                    ),
                                    const SizedBox(height: 4),
                                    // Замість "Button 5" з макету виводимо країну
                                    Text(city.country, style: TextStyle(color: AppState.textMuted, fontSize: 14)), 
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Розносимо кнопки по краях
                                      children: [
                                        // ЧОРНА КНОПКА VIEW (Форма пігулки)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2D2D2D),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            elevation: 0,
                                          ),
                                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CityDetailsScreen(city: city))),
                                          child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                                        ),
                                        // ЧОРНЕ СЕРЦЕ
                                        GestureDetector(
                                          onTap: () {
                                            AppState.toggleFavorite(city);
                                            setState(() {}); // Оновлюємо стан пагінації після видалення
                                          },
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click, 
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
                            }).toList(),
                          ),
                          // ПАГІНАЦІЯ (З'являється, якщо міст більше ніж 3)
                          if (totalPages > 1) ...[
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () { if (_currentPage > 1) setState(() => _currentPage--); },
                                  child: MouseRegion(cursor: SystemMouseCursors.click, child: Text('← Previous', style: TextStyle(color: _currentPage > 1 ? AppState.textMuted : AppState.border, fontWeight: FontWeight.bold, fontSize: 12))),
                                ),
                                const SizedBox(width: 16),
                                ...List.generate(totalPages, (index) {
                                  int pageNum = index + 1;
                                  return _buildPageNumber(pageNum, isActive: pageNum == _currentPage);
                                }),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () { if (_currentPage < totalPages) setState(() => _currentPage++); },
                                  child: MouseRegion(cursor: SystemMouseCursors.click, child: Text('Next →', style: TextStyle(color: _currentPage < totalPages ? AppState.textMain : AppState.border, fontWeight: FontWeight.bold, fontSize: 12))),
                                ),
                              ],
                            )
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
            child: Text(number.toString(), style: TextStyle(color: isActive ? Colors.white : AppState.textMain, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12))
          ),
        ),
      ),
    );
  }
}
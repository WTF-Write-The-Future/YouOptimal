import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';
import '../models/city.dart';
import 'city_details_screen.dart';
import '../utils/premium_transition.dart';
import '../screens/auth_screen.dart'; // Не забудь імпортувати екран авторизації

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
      backgroundColor: const Color(0xFFF7F3E8),
      appBar: const MainAppHeader(showFavourite: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // СТРІЛКУ НАЗАД ВИДАЛЕНО
          
          Expanded(
            child: ValueListenableBuilder<List<City>>(
              valueListenable: AppState.favorites,
              builder: (context, favorites, _) {
                if (favorites.isEmpty) {
                  return const Center(
                    child: Text(
                      'No favourite cities yet ❤️', 
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF485759)
                      )
                    )
                  );
                }

                int totalPages = (favorites.length / _itemsPerPage).ceil();
                if (totalPages == 0) totalPages = 1;
                if (_currentPage > totalPages) _currentPage = totalPages;

                List<City> paginatedFavorites = favorites
                    .skip((_currentPage - 1) * _itemsPerPage)
                    .take(_itemsPerPage)
                    .toList();

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2D7C0),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05), 
                            blurRadius: 40, 
                            offset: const Offset(0, 20)
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: 30,
                            runSpacing: 30,
                            alignment: WrapAlignment.center,
                            children: paginatedFavorites.map((city) => _buildFavoriteCard(city)).toList(),
                          ),
                          
                          if (totalPages > 1) ...[
                            const SizedBox(height: 50),
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

  Widget _buildFavoriteCard(City city) {
    return Container(
      width: 300,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35), 
        image: city.image.isNotEmpty 
            ? DecorationImage(image: NetworkImage(city.image), fit: BoxFit.cover)
            : const DecorationImage(image: AssetImage('assets/placeholder.png'), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click, 
                    child: GestureDetector(
                      onTap: () async {
                        // ТЕПЕР ПЕРЕДАЄМО CONTEXT
                        await AppState.toggleFavorite(context, city);
                        setState(() {}); 
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10), 
                        decoration: const BoxDecoration(color: Color(0xFFFFFBEB), shape: BoxShape.circle), 
                        child: const Icon(Icons.favorite, color: Color(0xFFC4B89D), size: 20)
                      )
                    ),
                  ),
                ),
                
                const Spacer(),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // === ВИПРАВЛЕНО ДОВГИЙ ТЕКСТ ===
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          city.name.toUpperCase(), 
                          maxLines: 1, // Тільки один рядок!
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 26, 
                            fontFamily: 'SFPro'
                          )
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Невеликий відступ від ціни
                    ValueListenableBuilder(
                      valueListenable: AppState.currency,
                      builder: (context, _, __) {
                        int convertedPrice = AppState.convertPrice(city.averagePrice.toInt());
                        String symbol = AppState.getCurrencySymbol();
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$symbol$convertedPrice', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6.0, left: 2.0),
                              child: Text('/ mo', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        );
                      }
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                const Text(
                  "Body text for your whole article or post. We'll put in some lorem ipsum to show how a filled-out page might look:", 
                  style: TextStyle(color: Color(0xA6FFFBEB), fontSize: 11, height: 1.4)
                ), 
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFBEB),
                        foregroundColor: const Color(0xFF485759),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(context, PremiumTransition(page: CityDetailsScreen(city: city))),
                      child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
                    ),
                    
                    Row(
                      children: List.generate(5, (index) {
                        int rating = city.rating.round();
                        return Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.white, size: 16);
                      }),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(totalPages, (index) {
          int pageNum = index + 1;
          bool isActive = pageNum == _currentPage;
          
          return GestureDetector(
            onTap: () => setState(() => _currentPage = pageNum),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 32, height: 32,
                decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(pageNum.toString(), style: TextStyle(color: isActive ? const Color(0xFF485759) : Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 14))
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () { if (_currentPage < totalPages) setState(() => _currentPage++); },
          child: MouseRegion(
            cursor: SystemMouseCursors.click, 
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.chevron_right, color: _currentPage < totalPages ? Colors.white : Colors.white.withOpacity(0.3), size: 24),
            )
          ),
        ),
      ],
    );
  }
}
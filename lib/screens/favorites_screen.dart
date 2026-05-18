import 'package:flutter/material.dart';
import 'dart:math';
import '../state/app_state.dart';
import '../models/city.dart';
import '../widgets/custom_header.dart';
import '../widgets/city_card.dart';
import '../widgets/city_card_mobile.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Color bgScreen = const Color(0xFFF7F3E8);
  final Color textDark = const Color(0xFF2B3233);
  final Color innerContainerBg = const Color(0xFFE8E0CE);
  
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: bgScreen,
      appBar: const MainAppHeader(showFavourite: false),
      body: ValueListenableBuilder<List<City>>(
        valueListenable: AppState.favorites,
        builder: (context, favList, child) {
          
          if (favList.isEmpty) {
            return _buildEmptyState();
          }

          // === МОБІЛЬНА ВЕРСІЯ ===
          if (isMobile) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MY FAVORITES',
                    style: TextStyle(fontFamily: 'SFPro', fontSize: 28, fontWeight: FontWeight.w900, color: textDark),
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favList.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CityCardMobile(city: favList[index]),
                    ),
                  ),
                ],
              ),
            );
          }

          // === ПК ВЕРСІЯ===
          int columns = 3;
          int totalPages = (favList.length / columns).ceil();

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MY FAVORITES',
                    style: TextStyle(fontFamily: 'SFPro', fontSize: 36, fontWeight: FontWeight.w900, color: textDark),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: innerContainerBg,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 20),
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) => setState(() => _currentPage = index),
                              itemCount: totalPages,
                              itemBuilder: (context, pageIndex) {
                                int startIndex = pageIndex * columns;
                                int endIndex = min(startIndex + columns, favList.length);
                                List<City> pageCities = favList.sublist(startIndex, endIndex);

                                return Row(
                                  children: List.generate(columns, (colIndex) {
                                    if (colIndex < pageCities.length) {
                                      return Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(right: colIndex < columns - 1 ? 24.0 : 0.0),
                                          child: AspectRatio(
                                            aspectRatio: 0.65, 
                                            child: CityCardFull(city: pageCities[colIndex]),
                                          ),
                                        ),
                                      );
                                    }
                                    return const Expanded(child: SizedBox());
                                  }),
                                );
                              },
                            ),
                          ),
                          _buildPaginationDots(totalPages),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No favorites yet.', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaginationDots(int totalPages) {
    if (totalPages <= 1) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          bool isActive = _currentPage == index;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32, height: 32,
            decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('${index + 1}', style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? textDark : Colors.white70)),
          );
        }),
      ),
    );
  }
}
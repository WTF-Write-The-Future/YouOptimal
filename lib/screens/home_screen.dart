import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/city_card.dart';
import '../widgets/custom_header.dart'; 
import '../models/city.dart';
import '../state/app_state.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<City> allCities;
  late List<City> displayedCities;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _currentFilter = 'All Cities'; 
  String _currentSort = 'Default'; 
  
  int _currentPage = 1;
  final int _itemsPerPage = 4;

  @override
  void initState() {
    super.initState();
    allCities = loadCitiesFromJson();
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    List<City> result = List.from(allCities);
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((c) => c.name.toLowerCase().contains(query) || c.country.toLowerCase().contains(query)).toList();
    }
    if (_currentFilter == 'Budget') {
      result = result.where((c) => c.averagePrice < 400).toList(); 
    } else if (_currentFilter == 'Highly Safe') {
      result = result.where((c) => c.safetyScore >= 90).toList();
    }
    if (_currentSort == 'Price: Low to High') {
      result.sort((a, b) => a.averagePrice.compareTo(b.averagePrice));
    } else if (_currentSort == 'Price: High to Low') {
      result.sort((a, b) => b.averagePrice.compareTo(a.averagePrice));
    } else if (_currentSort == 'Safety: High to Low') {
      result.sort((a, b) => b.safetyScore.compareTo(a.safetyScore));
    }
    setState(() {
      displayedCities = result;
      int maxPages = (displayedCities.length / _itemsPerPage).ceil();
      if (_currentPage > maxPages) _currentPage = 1;
      if (maxPages == 0) _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    int totalPages = (displayedCities.length / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    List<City> paginatedCities = displayedCities.skip((_currentPage - 1) * _itemsPerPage).take(_itemsPerPage).toList();

    return Scaffold(
      appBar: const MainAppHeader(showFavourite: true), // УВІМКНУТО ХЕДЕР FAVOURITE
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ВЕЛИЧЕЗНИЙ ЗАГОЛОВОК
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60, vertical: isMobile ? 60 : 120),
              decoration: BoxDecoration(color: AppState.bgMain),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Discover your city.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: isMobile ? 48 : 80, fontWeight: FontWeight.w900, letterSpacing: -3.0, color: AppState.textMain),
                ),
              ),
            ),

            // ПОШУК І ФІЛЬТРИ
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFiltersAndSort();
                      },
                      style: TextStyle(color: AppState.textMain),
                      decoration: InputDecoration(
                        hintText: 'Search for a city or country...',
                        hintStyle: TextStyle(color: AppState.textMuted),
                        suffixIcon: Icon(Icons.search, color: AppState.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: BorderSide(color: AppState.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: BorderSide(color: AppState.border)),
                        filled: true,
                        fillColor: AppState.bgCard,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
                          child: PopupMenuButton<String>(
                            offset: const Offset(0, 45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: AppState.bgCard, 
                            elevation: 8,
                            onSelected: (val) {
                              _currentFilter = val;
                              _applyFiltersAndSort();
                            },
                            itemBuilder: (context) {
                              int budgetThreshold = AppState.convertPrice(400);
                              String symbol = AppState.getCurrencySymbol();
                              return [
                                PopupMenuItem(value: 'All Cities', child: Text('All Cities', style: TextStyle(color: AppState.textMain))),
                                PopupMenuItem(value: 'Budget', child: Text('Budget (< $symbol$budgetThreshold)', style: TextStyle(color: AppState.textMain))),
                                PopupMenuItem(value: 'Highly Safe', child: Text('Highly Safe (> 90)', style: TextStyle(color: AppState.textMain))),
                              ];
                            },
                            child: _buildPillButton('Filter', Icons.menu, _currentFilter != 'All Cities'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Theme(
                          data: Theme.of(context).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
                          child: PopupMenuButton<String>(
                            offset: const Offset(0, 45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: AppState.bgCard,
                            elevation: 8,
                            onSelected: (val) {
                              _currentSort = val;
                              _applyFiltersAndSort();
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'Default', child: Text('Default', style: TextStyle(color: AppState.textMain))),
                              PopupMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High', style: TextStyle(color: AppState.textMain))),
                              PopupMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low', style: TextStyle(color: AppState.textMain))),
                              PopupMenuItem(value: 'Safety: High to Low', child: Text('Safety: High to Low', style: TextStyle(color: AppState.textMain))),
                            ],
                            child: _buildPillButton('Sort by', Icons.swap_vert, _currentSort != 'Default'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isMobile ? 40 : 80),

            // FOR YOU СЕКЦІЯ
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('For you', style: TextStyle(fontSize: isMobile ? 36 : 56, fontWeight: FontWeight.w900, letterSpacing: -2.0, color: AppState.textMain)),
                  const SizedBox(height: 32),
                  
                  paginatedCities.isEmpty
                      ? Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text('No cities found 😔', style: TextStyle(fontSize: 18, color: AppState.textMuted))))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paginatedCities.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth > 1100 ? 2 : 1, // 2 колонки на широких екранах
                            crossAxisSpacing: 60, // Більша відстань між колонками
                            mainAxisSpacing: 60,  // Більша відстань між рядками
                            childAspectRatio: screenWidth > 1100 ? 2.5 : (isMobile ? 1.2 : 2.0), 
                          ),
                          itemBuilder: (context, index) {
                            return CityCardFull(city: paginatedCities[index], isMobile: isMobile);
                          },
                        ),
                  
                  if (totalPages > 1) ...[
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(totalPages, (index) {
                        int pageNum = index + 1;
                        return _buildPageNumber(pageNum, isActive: pageNum == _currentPage);
                      }),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillButton(String text, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppState.border : AppState.bgCard, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isActive ? AppState.textMuted : AppState.border),
      ),
      child: Row(
        children: [
          Text(text, style: TextStyle(fontSize: 14, color: AppState.textMain, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: AppState.textMain),
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
          width: 32, height: 32,
          decoration: BoxDecoration(color: isActive ? const Color(0xFF2D2D2D) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(number.toString(), style: TextStyle(color: isActive ? Colors.white : AppState.textMain, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
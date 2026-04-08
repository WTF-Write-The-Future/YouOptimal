import 'package:flutter/material.dart';
import '../services/city_service.dart';
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
  List<City> allCities = [];
  List<City> displayedCities = [];
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String _currentSort = 'Default'; 
  
  int _currentPage = 1;
  final int _itemsPerPage = 12; 
  bool _isLoading = true;

  final Color bgColor = const Color(0xFFF7F3E8);

  @override
  void initState() {
    super.initState();
    _loadCitiesFromApi();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadCitiesFromApi() async {
    try {
      final cities = await CityService.fetchCities();
      
      AppState.cachedCities = cities; 
      
      setState(() {
        allCities = cities;
        _isLoading = false;
      });
      _applyFiltersAndSort();
      
      await AppState.syncFavorites(); 
      await AppState.syncPreferences();

    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFiltersAndSort() {
    List<City> result = List.from(allCities);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((c) => 
        c.name.toLowerCase().contains(query) || 
        c.country.toLowerCase().contains(query)
      ).toList();
    }

    double? minP = double.tryParse(_minPriceController.text);
    double? maxP = double.tryParse(_maxPriceController.text);

    if (minP != null || maxP != null) {
      result = result.where((c) {
        int convertedPrice = AppState.convertPrice(c.averagePrice.toInt());
        bool minMatch = minP == null || convertedPrice >= minP;
        bool maxMatch = maxP == null || convertedPrice <= maxP;
        return minMatch && maxMatch;
      }).toList();
    }

    switch (_currentSort) {
      case 'Price: Low to High':
        result.sort((a, b) => a.averagePrice.compareTo(b.averagePrice));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => b.averagePrice.compareTo(a.averagePrice));
        break;
      case 'Rating: High to Low':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Rating: Low to High':
        result.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      default:
        result.sort((a, b) => a.id.compareTo(b.id));
    }

    setState(() {
      displayedCities = result;
      _currentPage = 1; 
    });
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // === ПОВЕРНУТІ ФУНКЦІЇ ДІАЛОГІВ ТА ФІЛЬТРІВ ===
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: const EdgeInsets.all(32),
        title: const Center(
          child: Text('Price Range', style: TextStyle(fontFamily: 'SFPro', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF485759))),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            _buildCustomTextField(_minPriceController, 'Min Price (${AppState.getCurrencySymbol()})'),
            const SizedBox(height: 16),
            _buildCustomTextField(_maxPriceController, 'Max Price (${AppState.getCurrencySymbol()})'),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _minPriceController.clear();
                      _maxPriceController.clear();
                      _applyFiltersAndSort();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { 
                      _applyFiltersAndSort(); 
                      Navigator.pop(context);
                      _scrollToTop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC1D7D8), 
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    child: const Text('Apply', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    final sortOptions = [
      'Default',
      'Price: Low to High',
      'Price: High to Low',
      'Rating: High to Low',
      'Rating: Low to High'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        title: const Center(
          child: Text('Sort by', style: TextStyle(fontFamily: 'SFPro', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF485759))),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sortOptions.map((option) {
            bool isSelected = _currentSort == option;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              title: Text(
                option, 
                style: TextStyle(
                  fontFamily: 'SFPro', 
                  fontSize: 20, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black87 : Colors.grey.shade600
                )
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFC1D7D8)) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              hoverColor: const Color(0xFFF7F3E8),
              onTap: () {
                setState(() => _currentSort = option);
                _applyFiltersAndSort();
                Navigator.pop(context);
                _scrollToTop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'SFPro', 
              fontSize: 14, 
              color: Colors.grey,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          decoration: InputDecoration(
            hintText: '0', 
            hintStyle: TextStyle(fontFamily: 'SFPro', color: Colors.grey.shade400, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: bgColor, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), 
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  // === ПОВЕРНЕННЯ ДО ОСНОВНОГО КОДУ ===
  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_off_rounded, 
                size: 50,
                color: Color(0xFF485759),
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'No results found',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF485759),
              ),
            ),
            const SizedBox(height: 12),
            
            Text(
              "We couldn't find any places matching your search.\nTry adjusting your filters or search query.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SFPro', 
                fontSize: 16,
                color: Colors.grey.shade500,
                height: 1.5, 
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    int totalPages = (displayedCities.length / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    List<City> paginatedCities = displayedCities.skip((_currentPage - 1) * _itemsPerPage).take(_itemsPerPage).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const MainAppHeader(showFavourite: true),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: isMobile ? 250 : 350,
              decoration: const BoxDecoration(
                color: Colors.grey, 
                image: DecorationImage(image: AssetImage('assets/header_bg.png'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken)),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(right: isMobile ? 20 : 60, bottom: isMobile ? 20 : 40),
                  child: Text('Discover your city.', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, fontSize: isMobile ? 40 : 80, color: const Color(0xA6F5F5F5))),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) { _searchQuery = val; _applyFiltersAndSort(); },
                    style: const TextStyle(fontFamily: 'SFPro'),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(fontFamily: 'SFPro', color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('For you', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, fontSize: 36, color: Color(0xFF485759))),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFDCD5C6), thickness: 1),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _showFilterDialog, // <--- ТЕПЕР ФУНКЦІЯ Є І ПРАЦЮЄ
                        child: _buildFilterButton('Filter', Icons.filter_alt_outlined),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showSortDialog, // <--- ТЕПЕР ФУНКЦІЯ Є І ПРАЦЮЄ
                        child: _buildFilterButton(_currentSort == 'Default' ? 'Sort by' : 'Sorted', Icons.sort),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 80.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF485759)))
                  : paginatedCities.isEmpty
                      ? _buildNoResults()
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paginatedCities.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 1 : 3,
                            crossAxisSpacing: isMobile ? 20 : 40,
                            mainAxisSpacing: isMobile ? 20 : 40,
                            childAspectRatio: isMobile ? 0.9 : 0.85,
                          ),
                          itemBuilder: (context, index) {
                            return CityCardFull(city: paginatedCities[index], isMobile: isMobile);
                          },
                        ),
            ),
            
            if (!_isLoading && totalPages > 1) ...[
              const SizedBox(height: 60),
              _buildSmartPagination(totalPages),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFEBE6D9), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSmartPagination(int totalPages) {
    bool isMobilePagination = MediaQuery.of(context).size.width < 600;

    if (isMobilePagination) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (_currentPage > 1) {
                setState(() => _currentPage--);
                _scrollToTop();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage > 1 ? const Color(0xFFC1D7D8).withValues(alpha: 0.3) : Colors.transparent,
              ),
              child: Icon(Icons.chevron_left, color: _currentPage > 1 ? Colors.black87 : Colors.grey.shade300, size: 28),
            ),
          ),
          
          const SizedBox(width: 24),
          
          Text(
            'Page $_currentPage of $totalPages',
            style: const TextStyle(fontFamily: 'SFPro', fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(width: 24),

          GestureDetector(
            onTap: () {
              if (_currentPage < totalPages) {
                setState(() => _currentPage++);
                _scrollToTop();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage < totalPages ? const Color(0xFFC1D7D8).withValues(alpha: 0.3) : Colors.transparent,
              ),
              child: Icon(Icons.chevron_right, color: _currentPage < totalPages ? Colors.black87 : Colors.grey.shade300, size: 28),
            ),
          ),
        ],
      );
    }

    List<Widget> pages = [];

    pages.add(
      GestureDetector(
        onTap: () {
          if (_currentPage > 1) {
            setState(() => _currentPage--);
            _scrollToTop();
          }
        },
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage > 1 ? const Color(0xFFC1D7D8).withValues(alpha: 0.3) : Colors.transparent,
          ),
          child: Icon(Icons.chevron_left, color: _currentPage > 1 ? Colors.black87 : Colors.grey.shade300),
        ),
      ),
    );

    for (int i = 1; i <= totalPages; i++) {
      if (i == 1 || i == totalPages || (i >= _currentPage - 1 && i <= _currentPage + 1)) {
        pages.add(_buildPageNumber(i, isActive: i == _currentPage));
      } else if (i == _currentPage - 2 || i == _currentPage + 2) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('...', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        );
      }
    }

    pages.add(
      GestureDetector(
        onTap: () {
          if (_currentPage < totalPages) {
            setState(() => _currentPage++);
            _scrollToTop();
          }
        },
        child: Container(
          margin: const EdgeInsets.only(left: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage < totalPages ? const Color(0xFFC1D7D8).withValues(alpha: 0.3) : Colors.transparent,
          ),
          child: Icon(Icons.chevron_right, color: _currentPage < totalPages ? Colors.black87 : Colors.grey.shade300),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pages,
    );
  }

  Widget _buildPageNumber(int number, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          setState(() => _currentPage = number);
          _scrollToTop();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 36, height: 36,
        decoration: BoxDecoration(color: isActive ? const Color(0xFFC1D7D8) : Colors.transparent, borderRadius: BorderRadius.circular(18)),
        child: Center(child: Text(number.toString(), style: TextStyle(fontFamily: 'SFPro', fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 16, color: isActive ? Colors.black87 : Colors.grey))),
      ),
    );
  }
}
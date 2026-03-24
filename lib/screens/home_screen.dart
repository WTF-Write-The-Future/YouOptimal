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
      setState(() {
        allCities = cities;
        _isLoading = false;
      });
      _applyFiltersAndSort();
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: const EdgeInsets.all(32),
        title: const Center(
          child: Text('Price Range', style: TextStyle(fontFamily: 'DM Serif Text', fontSize: 28, color: Color(0xFF485759))),
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
                    child: const Text('Reset', style: TextStyle(fontFamily: 'DM Serif Text', fontSize: 18, color: Colors.grey)),
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
                    child: const Text('Apply', style: TextStyle(fontFamily: 'DM Serif Text', fontSize: 18, color: Colors.black87)),
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
          child: Text('Sort by', style: TextStyle(fontFamily: 'DM Serif Text', fontSize: 28, color: Color(0xFF485759))),
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
                  fontFamily: 'DM Serif Text', 
                  fontSize: 20, 
                  color: isSelected ? Colors.black87 : Colors.grey.shade500
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
        // Статичний заголовок НАД полем
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'DM Serif Text', 
              fontSize: 14, 
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Саме поле вводу
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontFamily: 'DM Serif Text', fontSize: 18, color: Colors.black87),
          decoration: InputDecoration(
            hintText: '0', // Легка підказка всередині
            hintStyle: TextStyle(fontFamily: 'DM Serif Text', color: Colors.grey.shade400),
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
                  child: Text('Discover your city.', style: TextStyle(fontFamily: 'DM Serif Text', fontSize: isMobile ? 40 : 80, color: const Color(0xA6F5F5F5))),
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
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(fontFamily: 'DM Serif Text', color: Colors.grey),
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
                  const Text('For you', style: TextStyle(fontFamily: 'DM Serif Text', fontSize: 36, color: Color(0xFF485759))),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFDCD5C6), thickness: 1),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _showFilterDialog,
                        child: _buildFilterButton('Filter', Icons.filter_alt_outlined),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showSortDialog,
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
                      ? const Center(child: Text('No results found for your criteria.', style: TextStyle(fontFamily: 'DM Serif Text', fontSize: 18, color: Colors.grey)))
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
            
            // НОВИЙ ВИКЛИК РОЗУМНОЇ ПАГІНАЦІЇ
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
          Text(text, style: const TextStyle(fontFamily: 'DM Serif Text', fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  // === РОЗУМНА ПАГІНАЦІЯ З КРАПКАМИ ТА СТРІЛКАМИ ===
 // === РОЗУМНА ПАГІНАЦІЯ (Адаптивна) ===
  Widget _buildSmartPagination(int totalPages) {
    // Перевіряємо ширину екрану (якщо менше 600px - це точно телефон)
    bool isMobilePagination = MediaQuery.of(context).size.width < 600;

    // 📱 КОНЦЕПЦІЯ 1: ДЛЯ МОБІЛЬНОГО (Компактна)
    if (isMobilePagination) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Кнопка "Назад"
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
          
          // Текст замість цифр
          Text(
            'Page $_currentPage of $totalPages',
            style: const TextStyle(fontFamily: 'DM Serif Text', fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(width: 24),

          // Кнопка "Вперед"
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

    // 💻 КОНЦЕПЦІЯ 2: ДЛЯ КОМП'ЮТЕРА (Розширена з крапочками)
    List<Widget> pages = [];

    // Кнопка "Назад"
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

    // Логіка генерації цифр і крапок
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

    // Кнопка "Вперед"
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
        child: Center(child: Text(number.toString(), style: TextStyle(fontFamily: 'DM Serif Text', fontSize: 16, color: isActive ? Colors.black87 : Colors.grey))),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/city_service.dart';
import '../widgets/city_card.dart';
import '../widgets/custom_header.dart'; 
import '../models/city.dart';
import '../state/app_state.dart';
import '../widgets/city_card_mobile.dart';

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
  
  double _minSafety = 0.0;
  double _minInternet = 0.0;
  String? _selectedCountry = 'All';
  
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

  // Отримуємо список унікальних країн для Dropdown
  List<String> get _availableCountries {
    final countries = allCities.map((c) => c.country).toSet().toList();
    countries.sort();
    return ['All', ...countries];
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
      await AppState.syncReviewCount();
      AppState.syncVisitedCities(); 
      await AppState.syncPreferences();

    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage, 
              style: const TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.w500)
            ),
            backgroundColor: Colors.redAccent, 
            behavior: SnackBarBehavior.floating, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ===  МЕТОД ФІЛЬТРАЦІЇ ===
  void _applyFiltersAndSort() {
    List<City> result = List.from(allCities);

    // 1. Пошук за назвою
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((c) => 
        c.name.toLowerCase().contains(query) || 
        c.country.toLowerCase().contains(query)
      ).toList();
    }

    // 2. Фільтр за Країною
    if (_selectedCountry != null && _selectedCountry != 'All') {
      result = result.where((c) => c.country == _selectedCountry).toList();
    }

    // 3. Фільтр за Метриками (Ціна, Безпека, Інтернет)
    result = result.where((city) {
      double convertedPrice = AppState.convertPrice(city.averagePrice.toDouble());

      // Ціна мін
      if (_minPriceController.text.isNotEmpty) {
        final minP = double.tryParse(_minPriceController.text) ?? 0;
        if (convertedPrice < minP) return false;
      }
      
      // Ціна макс
      if (_maxPriceController.text.isNotEmpty) {
        final maxP = double.tryParse(_maxPriceController.text) ?? double.infinity;
        if (convertedPrice > maxP) return false;
      }

      // Безпека
      if (_minSafety > 0 && city.safetyIndex < _minSafety) return false;
      
      // Інтернет
      if (_minInternet > 0 && city.internetSpeed < _minInternet) return false;

      return true;
    }).toList();

    // 4. Сортування (Додано нові параметри!)
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
      case 'Safety: High to Low': 
        result.sort((a, b) => b.safetyIndex.compareTo(a.safetyIndex));
        break;
      case 'Internet: Fast to Slow':
        result.sort((a, b) => b.internetSpeed.compareTo(a.internetSpeed));
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
          child: Text('Filters', style: TextStyle(fontFamily: 'SFPro', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF485759))),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Container(
              constraints: const BoxConstraints(maxWidth: 500), 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ФІЛЬТР КРАЇНИ ---
                    const Text('Country', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                  Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  decoration: BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFDCD5C6), width: 1),
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      isExpanded: true,
      value: _selectedCountry,
      dropdownColor: const Color(0xFFFDFCF9),
      borderRadius: BorderRadius.circular(20),
      elevation: 8,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF485759)),
      style: const TextStyle(
        fontFamily: 'SFPro',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF485759),
      ),
      items: _availableCountries.map((String country) {
        return DropdownMenuItem<String>(
          value: country,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(country),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setStateDialog(() => _selectedCountry = newValue);
      },
    ),
  ),
),
                    const SizedBox(height: 24),

                    // --- ФІЛЬТР ЦІНИ ---
                    const Text('Price Range', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildCustomTextField(_minPriceController, 'Min (${AppState.getCurrencySymbol()})')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCustomTextField(_maxPriceController, 'Max (${AppState.getCurrencySymbol()})')),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // --- ФІЛЬТР БЕЗПЕКИ ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Min Safety Index', style: TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('${_minSafety.toInt()}', style: const TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC1D7D8))),
                      ],
                    ),
                    Slider(
                      value: _minSafety,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      activeColor: const Color(0xFFC1D7D8),
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setStateDialog(() => _minSafety = value);
                      },
                    ),

                    const SizedBox(height: 16),

                    // --- ФІЛЬТР ІНТЕРНЕТУ ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Min Internet Speed', style: TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('${_minInternet.toInt()} Mbps', style: const TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC1D7D8))),
                      ],
                    ),
                    Slider(
                      value: _minInternet,
                      min: 0,
                      max: 300,
                      divisions: 30,
                      activeColor: const Color(0xFFC1D7D8),
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setStateDialog(() => _minInternet = value);
                      },
                    ),

                    const SizedBox(height: 32),
                    
                    // --- КНОПКИ ---
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setStateDialog(() {
                                _minPriceController.clear();
                                _maxPriceController.clear();
                                _minSafety = 0.0;
                                _minInternet = 0.0;
                                _selectedCountry = 'All';
                              });
                              setState(() {
                                _minSafety = 0.0;
                                _minInternet = 0.0;
                                _selectedCountry = 'All';
                              });
                              _applyFiltersAndSort();
                              Navigator.pop(context);
                            },
                            child: const Text('Reset', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () { 
                              setState(() {}); 
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
      'Rating: Low to High',
      'Safety: High to Low',
      'Internet: Fast to Slow'
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
        content: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
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
                    color: Colors.black.withOpacity(0.05),
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 1. Хедер 
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: isMobile ? 180 : 350, 
              decoration: const BoxDecoration(
                color: Colors.grey, 
                image: DecorationImage(
                  image: AssetImage('assets/header_bg.png'), 
                  fit: BoxFit.cover, 
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken)
                ),
              ),
child: Align(
  alignment: Alignment.bottomRight,
  child: Padding(
    padding: EdgeInsets.only(
      right: isMobile ? 20 : 60, 
      bottom: isMobile ? 15 : 60, 
    ),
    child: Text(
      'Find your perfect place to live.', 
      style: TextStyle(
        fontFamily: 'SFPro', 
        fontWeight: FontWeight.w900, 
        fontSize: isMobile ? 28 : 54, 
        color: const Color(0xFFF5F5F5).withOpacity(0.8), 
        letterSpacing: -1.2, 
      ),
    ),
  ),
),
            ),
          ),

          // 2. Пошук
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 20 : 40), 
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) { _searchQuery = val; _applyFiltersAndSort(); },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isMobile ? 15 : 20, 
                          horizontal: 24
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Заголовок, кнопки та лінія
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16.0 : 80.0, 
                isMobile ? 30 : 60, 
                isMobile ? 16.0 : 80.0, 
                0
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'For you', 
                        style: TextStyle(
                          fontFamily: 'SFPro', 
                          fontWeight: FontWeight.bold, 
                          fontSize: isMobile ? 28 : 36, 
                          color: const Color(0xFF485759)
                        )
                      ),
                      Row(
                        children: [
                          AnimatedHoverButton(
                            text: 'Filter',
                            icon: Icons.filter_alt_outlined,
                            onTap: _showFilterDialog,
                          ),
                          const SizedBox(width: 12),
                          AnimatedHoverButton(
                            text: _currentSort == 'Default' ? 'Sort by' : 'Sorted',
                            icon: Icons.sort,
                            onTap: _showSortDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFDCD5C6), thickness: 1),
                  const SizedBox(height: 24), 
                ],
              ),
            ),
          ),
          
          // 4.  СПИСОК МІСТ
          _isLoading
              ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Color(0xFF485759))))
              : paginatedCities.isEmpty
                  ? SliverToBoxAdapter(child: _buildNoResults())
                  : SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 80.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : 3,
                          crossAxisSpacing: isMobile ? 0 : 40,
                          mainAxisSpacing: isMobile ? 24 : 40,
                          childAspectRatio: isMobile ? 1.5 : 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final city = paginatedCities[index];
                            return isMobile 
                                ? CityCardMobile(city: city) 
                                : CityCardFull(city: city, isMobile: isMobile);
                          },
                          childCount: paginatedCities.length,
                        ),
                      ),
                    ),

          // 5. Пагінація та футер
          if (!_isLoading && totalPages > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: _buildSmartPagination(totalPages),
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
                color: _currentPage > 1 ? const Color(0xFFC1D7D8).withOpacity(0.3) : Colors.transparent,
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
                color: _currentPage < totalPages ? const Color(0xFFC1D7D8).withOpacity(0.3) : Colors.transparent,
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
            color: _currentPage > 1 ? const Color(0xFFC1D7D8).withOpacity(0.3) : Colors.transparent,
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
            color: _currentPage < totalPages ? const Color(0xFFC1D7D8).withOpacity(0.3) : Colors.transparent,
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

class AnimatedHoverButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const AnimatedHoverButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  State<AnimatedHoverButton> createState() => _AnimatedHoverButtonState();
}

class _AnimatedHoverButtonState extends State<AnimatedHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFDED8C9) : const Color(0xFFEBE6D9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
          transformAlignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
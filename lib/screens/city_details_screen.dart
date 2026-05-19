import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../models/city.dart';
import '../models/review.dart';
import '../state/app_state.dart';
import '../widgets/custom_header.dart';
import '../screens/review_screen.dart';

class CityDetailsScreen extends StatefulWidget {
  final City city;

  const CityDetailsScreen({super.key, required this.city});

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  final Color bgScreen = const Color(0xFFF7F3E8);
  final Color bgCard = const Color(0xFFC9BA9B);
  final Color bgChip = const Color(0xFFFFFBEB);
  final Color textDark = const Color(0xFF2B3233);

  // Змінні для відгуків
  List<Review> _allReviews = [];
  bool _isLoadingReviews = true;
  
  // Пагінація
  int _currentPage = 1;
  final int _reviewsPerPage = 2; // По 2 відгуки

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    
    try {
      final response = await Supabase.instance.client
          .from('review')
          .select()
          .eq('city_id', widget.city.id)
          .order('created_at', ascending: false);

      setState(() {
        _allReviews = response.map((json) => Review.fromJson(json)).toList();
        _isLoadingReviews = false;
        _currentPage = 1; 
      });
    } catch (e) {
      print('Помилка завантаження відгуків: $e');
      setState(() => _isLoadingReviews = false);
    }
  }

  int get _totalPages => _allReviews.isEmpty ? 1 : (_allReviews.length / _reviewsPerPage).ceil();

  List<Review> get _currentReviews {
    int start = (_currentPage - 1) * _reviewsPerPage;
    int end = start + _reviewsPerPage;
    if (end > _allReviews.length) end = _allReviews.length;
    return _allReviews.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 1000;

    return Scaffold(
      backgroundColor: bgScreen,
      appBar: const MainAppHeader(showFavourite: false),
      body: isMobile ? _buildPremiumMobileLayout() : _buildDesktopLayout(context),
    );
  }

  Widget _buildPremiumMobileLayout() {
    double overallAvg = 0;
    if (_allReviews.isNotEmpty) {
      overallAvg = _allReviews.map((r) => r.averageRating).reduce((a, b) => a + b) / _allReviews.length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // ВЕРХНЯ КАРТКА МІСТА
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E0CE), 
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'hero-city-image-${widget.city.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: widget.city.image.isNotEmpty
                                ? Image.network(widget.city.image, fit: BoxFit.cover)
                                : Container(color: Colors.grey.shade300, child: const Icon(Icons.image, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // НАЗВА, ЦІНА ТА ІКОНКИ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Блок з іконками Visited та Favorite
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildMobileVisitedButton(),
                              const SizedBox(width: 8),
                              _buildMobileLikeButton(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Назва міста з FittedBox
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.city.name.toUpperCase(),
                              style: TextStyle(fontFamily: 'SFPro', fontSize: 28, fontWeight: FontWeight.w900, color: textDark, height: 1.1),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Ціна
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(AppState.getCurrencySymbol(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark.withOpacity(0.5))),
                              Text(
                                AppState.convertPrice(widget.city.averagePrice.toDouble()).toString(),
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textDark, height: 1.0)
                              ),
                            ],
                          ),
                          Text('/ mo', style: TextStyle(fontSize: 14, color: textDark.withOpacity(0.5), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // МЕТРИКИ
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
if (widget.city.tempMin != null && widget.city.tempMax != null) 
  _buildMobileMetricChip(
    Icons.thermostat, 
    '${AppState.getFormattedTemperature(widget.city.tempMin!)} / ${AppState.getFormattedTemperature(widget.city.tempMax!)}'
  ),
                    if (widget.city.airQualityIndex != null) 
  _buildMobileMetricChip(Icons.air, 'Air: ${widget.city.airQualityIndex!.toInt()}'),
if (widget.city.atmosphericPressure != null) 
  _buildMobileMetricChip(Icons.compress, '${widget.city.atmosphericPressure!.toInt()} hPa'),

if (widget.city.rent1Room != null) 
  _buildMobileMetricChip(Icons.apartment, '1-bed: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.rent1Room!).toStringAsFixed(0)}'),
if (widget.city.rent2Room != null) 
  _buildMobileMetricChip(Icons.grid_view_rounded, '2-bed: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.rent2Room!).toStringAsFixed(0)}'),
if (widget.city.rent3Room != null) 
  _buildMobileMetricChip(Icons.home_work_outlined, '3-bed: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.rent3Room!).toStringAsFixed(0)}'),
if (widget.city.rentHouse != null) 
  _buildMobileMetricChip(Icons.home_outlined, 'House: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.rentHouse!).toStringAsFixed(0)}'),
if (widget.city.taxiPrice != null) 
  _buildMobileMetricChip(Icons.local_taxi, 'Taxi: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.taxiPrice!).toStringAsFixed(0)}'),
if (widget.city.publicTransportPrice != null) 
  _buildMobileMetricChip(Icons.directions_bus, 'Bus: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.publicTransportPrice!).toStringAsFixed(1)}'),

if (widget.city.internetSpeed != null) 
  _buildMobileMetricChip(Icons.wifi, '${widget.city.internetSpeed!.toInt()} Mbps'),
if (widget.city.safetyIndex != null) 
  _buildMobileMetricChip(Icons.security, 'Safety: ${widget.city.safetyIndex!.toInt()}/100'),

_buildMobileMetricChip(Icons.public, widget.city.country),
                  ],
                ),
                const SizedBox(height: 24),
                
                // ABOUT БЛОК
_ExpandableAboutSection(
  cityName: widget.city.name,
  description: widget.city.full_description ?? widget.city.description, 
  bgScreen: Colors.white.withOpacity(0.6),
),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // ВІДГУКИ КАРТКА
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('REVIEWS', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w900, fontSize: 18, color: textDark, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 16),
                
                // БЛОК СЕРЕДНЬОГО РЕЙТИНГУ
                if (!_isLoadingReviews && _allReviews.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16), 
                    padding: const EdgeInsets.all(16), 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Overall Rating', style: TextStyle(fontFamily: 'SFPro', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(overallAvg.toStringAsFixed(1), style: TextStyle(fontFamily: 'SFPro', fontSize: 28, fontWeight: FontWeight.w900, color: textDark, height: 1.0)),
                                const SizedBox(width: 4),
                                const Text('/ 5.0', style: TextStyle(fontFamily: 'SFPro', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: List.generate(5, (index) => Icon(
                                index < overallAvg.round() ? Icons.star : Icons.star_border,
                                color: bgCard,
                                size: 18,
                              )),
                            ),
                            const SizedBox(height: 6),
                            Text('${_allReviews.length} Reviews', style: const TextStyle(fontFamily: 'SFPro', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),

                if (_isLoadingReviews) 
                  const Center(child: CircularProgressIndicator())
                else if (_allReviews.isEmpty)
                   const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No reviews yet. Be the first!'))
                else
                  ..._allReviews.map((r) => _ReviewCard(review: r, bgCard: bgCard, bgScreen: const Color(0xFFE8E0CE), textDark: textDark)),
                
                const SizedBox(height: 20),
                
                // КНОПКА LEAVE A REVIEW
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewScreen(city: widget.city))).then((_) => _fetchReviews()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: textDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('LEAVE A REVIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
                      SizedBox(width: 8),
                      Icon(Icons.edit_outlined, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMetricChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textDark),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
        ],
      ),
    );
  }

  // ===  КНОПКА VISITED ===
  Widget _buildMobileVisitedButton() {
    return ValueListenableBuilder<List<City>>(
      valueListenable: AppState.visitedCities,
      builder: (context, visitedList, _) {
        bool isVisited = visitedList.any((c) => c.id == widget.city.id);
        return GestureDetector(
          onTap: () => AppState.toggleVisited(context, widget.city),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              Icons.check_circle_rounded, 
              color: isVisited ? const Color(0xFF53D769) : Colors.grey.shade300, 
              size: 20
            ),
          ),
        );
      },
    );
  }

  // ===  КНОПКА LIKE ===
  Widget _buildMobileLikeButton() {
    return ValueListenableBuilder(
      valueListenable: AppState.favorites,
      builder: (context, _, __) {
        bool isFav = AppState.isFavorite(widget.city);
        return GestureDetector(
          onTap: () => AppState.toggleFavorite(context, widget.city),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: bgCard, size: 20),
          ),
        );
      },
    );
  }

  // ============== ПК ВЕРСІЯ ========================
  
  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(32), 
                    child: _buildLeftSection(context, false),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: _buildRightSection(context, false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start, 
      children: [
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(isMobile),
                  const SizedBox(height: 24),
                  _buildTitleAndPrice(),
                  const SizedBox(height: 24),
                  _buildMetricsGrid(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(isMobile),
                  const SizedBox(width: 24), 
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleAndPrice(),
                        const SizedBox(height: 24),
                        _buildMetricsGrid(),
                      ],
                    ),
                  )
                ],
              ),
        
        SizedBox(height: isMobile ? 24 : 32),
        
_ExpandableAboutSection(
  cityName: widget.city.name,
    description: widget.city.full_description ?? widget.city.description,
  bgScreen: bgScreen,
),
      ],
    );
  }

  Widget _buildRightSection(BuildContext context, bool isMobile) {
    double overallAvg = 0;
    if (_allReviews.isNotEmpty) {
      overallAvg = _allReviews.map((r) => r.averageRating).reduce((a, b) => a + b) / _allReviews.length;
    }

    return Container(
      margin: EdgeInsets.only(
        top: isMobile ? 0 : 16, 
        bottom: isMobile ? 0 : 16, 
        right: isMobile ? 0 : 16
      ),
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: bgScreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMobile ? 0 : 32),
          topRight: Radius.circular(isMobile ? 32 : 32),
          bottomLeft: Radius.circular(isMobile ? 32 : 32),
          bottomRight: Radius.circular(isMobile ? 32 : 32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          // === ВЕРХНЯ ЧАСТИНА ===
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Блок із загальною статистикою
              if (!_isLoadingReviews && _allReviews.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12), 
                  padding: const EdgeInsets.all(12), 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Overall Rating', style: TextStyle(fontFamily: 'SFPro', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(overallAvg.toStringAsFixed(1), style: TextStyle(fontFamily: 'SFPro', fontSize: 24, fontWeight: FontWeight.w900, color: textDark, height: 1.0)),
                              const SizedBox(width: 4),
                              const Text('/ 5.0', style: TextStyle(fontFamily: 'SFPro', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: List.generate(5, (index) => Icon(
                              index < overallAvg.round() ? Icons.star : Icons.star_border,
                              color: bgCard,
                              size: 16,
                            )),
                          ),
                          const SizedBox(height: 4),
                          Text('${_allReviews.length} Reviews', style: const TextStyle(fontFamily: 'SFPro', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),

              // Список відгуків
              if (_isLoadingReviews)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xFFC9BA9B)),
                ),
              
              if (!_isLoadingReviews && _allReviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'No reviews yet. Be the first!',
                      style: TextStyle(fontFamily: 'SFPro', fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ),
                ),

              if (!_isLoadingReviews && _allReviews.isNotEmpty)
                ..._currentReviews.map((review) => _ReviewCard(
                      review: review,
                      bgCard: bgCard,
                      bgScreen: bgScreen,
                      textDark: textDark,
                    )),
            ],
          ),
          
          // === НИЖНЯ ЧАСТИНА ===
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Пагінація
              if (_totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.chevron_left),
                        color: _currentPage > 1 ? textDark : Colors.grey.shade400,
                        onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                      ),
                      Text(
                        'Page $_currentPage of $_totalPages',
                        style: TextStyle(fontFamily: 'SFPro', fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.chevron_right),
                        color: _currentPage < _totalPages ? textDark : Colors.grey.shade400,
                        onPressed: _currentPage < _totalPages ? () => setState(() => _currentPage++) : null,
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 8),
              
              // Кнопка LEAVE A REVIEW
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ReviewScreen(city: widget.city))
                  ).then((_) => _fetchReviews());
                },
                icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.black87),
                label: const Text('LEAVE A REVIEW', style: TextStyle(fontFamily: 'SFPro', fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.black87)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildImage(bool isMobile) {
    return Hero(
      tag: 'hero-city-image-${widget.city.id}', 
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: isMobile ? double.infinity : 260, 
          height: 360, 
          decoration: BoxDecoration(
            color: bgScreen,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: widget.city.image.isNotEmpty 
                ? Image.network(widget.city.image, fit: BoxFit.cover) 
                : const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
          ),
        ),
      ),
    );
  }

Widget _buildTitleAndPrice() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.city.name.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'SFPro',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          Row(
            children: [
              // Кнопка VISITED
              ValueListenableBuilder<List<City>>(
                valueListenable: AppState.visitedCities,
                builder: (context, visitedList, _) {
                  bool isVisited = visitedList.any((c) => c.id == widget.city.id);
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => AppState.toggleVisited(context, widget.city),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: isVisited ? const Color(0xFF53D769) : Colors.grey.shade300,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // Кнопка FAVORITE
              ValueListenableBuilder<List<City>>(
                valueListenable: AppState.favorites,
                builder: (context, favList, _) {
                  bool isFav = AppState.isFavorite(widget.city);
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => AppState.toggleFavorite(context, widget.city),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: const Color(0xFFC9BA9B),
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Блок ціни
      ValueListenableBuilder<String>(
        valueListenable: AppState.currency,
        builder: (context, currentCurrency, child) {
String price = AppState.convertPrice(widget.city.averagePrice).toStringAsFixed(0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppState.getCurrencySymbol(),
                style: const TextStyle(fontFamily: 'SFPro', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Text(
                price,
                style: const TextStyle(fontFamily: 'SFPro', fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6.0, left: 4.0),
                child: Text(
                  '/ mo',
                  style: TextStyle(fontFamily: 'SFPro', fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}

  Widget _buildMetricsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ValueListenableBuilder<String>(
          valueListenable: AppState.tempUnit, 
          builder: (context, _, __) {
            String tempText = 'Temp: N/A';

if (widget.city.tempMin != null && widget.city.tempMax != null) {
  String minTemp = AppState.getFormattedTemperature(widget.city.tempMin!);
  
  String maxTemp = AppState.getFormattedTemperature(widget.city.tempMax!);
  
  tempText = '$minTemp / $maxTemp';
}
return _buildMetricChip(Icons.thermostat_rounded, tempText);
          }
        ),
        _buildMetricChip(Icons.air, widget.city.airQualityIndex != null ? 'AQI: ${widget.city.airQualityIndex}' : 'AQI: N/A'),
        _buildMetricChip(Icons.wifi, widget.city.internetSpeed != null ? '${widget.city.internetSpeed} Mbps' : 'Net: N/A'),
        _buildMetricChip(Icons.security, widget.city.safetyIndex != null ? 'Safety: ${widget.city.safetyIndex}/100' : 'Safety: N/A'),
        _buildMetricChip(Icons.compress, widget.city.atmosphericPressure != null ? '${widget.city.atmosphericPressure} hPa' : 'Press: N/A'),
        
        _buildMetricChip(Icons.bed_outlined, widget.city.rent1Room != null ? '1-bed: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.rent1Room!).toStringAsFixed(0)}' : '1-bed: N/A'),
        _buildMetricChip(Icons.bed, widget.city.rent2Room != null ? '2-bed: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.rent2Room!).toStringAsFixed(0)}' : '2-bed: N/A'),
        _buildMetricChip(Icons.bedroom_parent_outlined, widget.city.rent3Room != null ? '3-bed: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.rent3Room!).toStringAsFixed(0)}' : '3-bed: N/A'),
        _buildMetricChip(Icons.house_outlined, widget.city.rentHouse != null ? 'House: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.rentHouse!).toStringAsFixed(0)}' : 'House: N/A'),
        _buildMetricChip(Icons.local_taxi_outlined, widget.city.taxiPrice != null ? 'Taxi: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.taxiPrice!).toStringAsFixed(0)}' : 'Taxi: N/A'),
        
        _buildMetricChip(Icons.directions_bus_rounded, widget.city.publicTransportPrice != null ? 'Bus: ${AppState.getCurrencySymbol()}${AppState.convertPrice(widget.city.publicTransportPrice!).toStringAsFixed(1)}' : 'Bus: N/A'),
    
    // КРАЇНА
    _buildMetricChip(
      Icons.public_rounded, 
      widget.city.country
    ),
      ],
    );
  }

  Widget _buildMetricChip(IconData icon, String label) {
    return Container(
      width: 140, 
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgChip,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 4, offset: const Offset(-2, -2)),
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(2, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textDark),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'SFPro', fontSize: 11, fontWeight: FontWeight.bold, color: textDark), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

// ===  КАРТКА ВІДГУКУ ===
class _ReviewCard extends StatefulWidget {
  final Review review;
  final Color bgCard;
  final Color bgScreen;
  final Color textDark;

  const _ReviewCard({
    required this.review,
    required this.bgCard,
    required this.bgScreen,
    required this.textDark,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy').format(widget.review.createdAt);
    
    // Перевірка чи текст достатньо довгий, щоб його згортати
    bool isLongText = widget.review.text.length > 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < widget.review.averageRating.round() ? Icons.star : Icons.star_border,
                color: widget.bgCard,
                size: 14,
              );
            }),
          ),
          const SizedBox(height: 6),
          
          // ІНТЕРАКТИВНИЙ ТЕКСТ З КНОПКОЮ READ MORE
          GestureDetector(
            onTap: () {
              if (isLongText) {
                setState(() => _isExpanded = !_isExpanded);
              }
            },
            child: MouseRegion(
              cursor: isLongText ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.review.text,
                    style: const TextStyle(fontFamily: 'SFPro', fontSize: 12, color: Colors.black87, height: 1.3),
                    maxLines: _isExpanded ? null : 3, // Якщо розгорнуто - показує все
                    overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  if (isLongText)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _isExpanded ? 'Show less' : 'Read more...',
                        style: TextStyle(
                          fontFamily: 'SFPro', 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold, 
                          color: widget.bgCard
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Детальні оцінки
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: widget.bgScreen, 
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniRating('Safety', widget.review.safetyRating),
                _buildMiniRating('Architecture', widget.review.architectureRating),
                _buildMiniRating('Culture', widget.review.cultureRating),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Інфо про автора
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 14, color: Colors.white)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.review.authorName, style: const TextStyle(fontFamily: 'SFPro', fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    Text(formattedDate, style: const TextStyle(fontFamily: 'SFPro', fontSize: 10, color: Colors.grey)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniRating(String label, int rating) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontFamily: 'SFPro', fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(rating.toString(), style: TextStyle(fontFamily: 'SFPro', fontSize: 12, fontWeight: FontWeight.w900, color: widget.textDark)),
            const SizedBox(width: 2),
            Icon(Icons.star, size: 10, color: widget.bgCard),
          ],
        )
      ],
    );
  }
}

class _ExpandableAboutSection extends StatefulWidget {
  final String cityName;
  final String description;
  final Color bgScreen;

  const _ExpandableAboutSection({required this.cityName, required this.description, required this.bgScreen});

  @override
  State<_ExpandableAboutSection> createState() => _ExpandableAboutSectionState();
}

class _ExpandableAboutSectionState extends State<_ExpandableAboutSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.bgScreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          title: Text('ABOUT ${widget.cityName.toUpperCase()}', style: const TextStyle(fontFamily: 'SFPro', fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Colors.black54)),
          iconColor: Colors.black54,
          collapsedIconColor: Colors.black54,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          children: [
            Text(widget.description, style: const TextStyle(fontFamily: 'SFPro', fontSize: 13, color: Colors.black87, height: 1.6))
          ],
        ),
      ),
    );
  }
}
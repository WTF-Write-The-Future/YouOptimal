import 'package:flutter/material.dart';
import '../models/city.dart';
import '../state/app_state.dart';
import '../widgets/custom_header.dart';
import '../screens/review_screen.dart';

class CityDetailsScreen extends StatelessWidget {
  final City city;

  const CityDetailsScreen({super.key, required this.city});

  final Color bgScreen = const Color(0xFFF7F3E8);
  final Color bgCard = const Color(0xFFC9BA9B);
  final Color bgChip = const Color(0xFFFFFBEB);
  final Color textDark = const Color(0xFF2B3233);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 1000;

    return Scaffold(
      backgroundColor: bgScreen,
      appBar: const MainAppHeader(showFavourite: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 40.0, vertical: 40.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 15))
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      Padding(padding: const EdgeInsets.all(24), child: _buildLeftSection(context, isMobile)),
                      _buildRightSection(context, isMobile),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: _buildLeftSection(context, isMobile),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: _buildRightSection(context, isMobile),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        
        SizedBox(height: isMobile ? 32 : 40),
        
        _ExpandableAboutSection(
          cityName: city.name,
          description: '${city.name} is a breathtaking city, famous for its stunning architecture and vibrant energy. It perfectly blends a rich historical past with modern lifestyle, making it one of the most atmospheric places to live.',
          bgScreen: bgScreen,
        ),
      ],
    );
  }

  Widget _buildRightSection(BuildContext context, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(
        top: isMobile ? 0 : 20, 
        bottom: isMobile ? 0 : 20, 
        right: isMobile ? 0 : 20
      ),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bgScreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMobile ? 0 : 32),
          topRight: Radius.circular(isMobile ? 40 : 32),
          bottomLeft: Radius.circular(isMobile ? 40 : 32),
          bottomRight: Radius.circular(isMobile ? 40 : 32),
        ),
      ),
      child: Column(
        children: [
          Column(
            children: [
              _buildMockReviewCard(),
              const SizedBox(height: 16),
              _buildMockReviewCard(),
              const SizedBox(height: 16),
              _buildMockReviewCard(),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewScreen(city: city)));
            },
            icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.black87),
            label: const Text('LEAVE A REVIEW', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black87)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260, 
      height: 360, 
      decoration: BoxDecoration(
        color: bgScreen,
        borderRadius: BorderRadius.circular(32),
        image: city.image.isNotEmpty ? DecorationImage(image: NetworkImage(city.image), fit: BoxFit.cover) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: city.image.isEmpty ? const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)) : null,
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
                city.name.toUpperCase(), 
                style: const TextStyle(fontFamily: 'SFPro', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
              ),
            ),
            ValueListenableBuilder<List<City>>(
              valueListenable: AppState.favorites,
              builder: (context, favorites, child) {
                bool isFav = AppState.isFavorite(city);
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => AppState.toggleFavorite(context, city),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: bgCard, size: 20),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: AppState.currency,
          builder: (context, currentCurrency, child) {
            String price = AppState.convertPrice(city.averagePrice.toInt()).toString();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, right: 2.0),
                  child: Text(AppState.getCurrencySymbol(), style: const TextStyle(fontFamily: 'SFPro', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                Text(price, style: const TextStyle(fontFamily: 'SFPro', fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6.0, left: 4.0),
                  child: Text('/ mo', style: TextStyle(fontFamily: 'SFPro', fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold)),
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
            if (city.temperature != null) {
              tempText = AppState.getFormattedTemperature(city.temperature!.toDouble());
            }
            return _buildMetricChip(Icons.wb_sunny_outlined, tempText);
          }
        ),
        _buildMetricChip(Icons.air, city.airQualityIndex != null ? 'AQI: ${city.airQualityIndex}' : 'AQI: N/A'),
        _buildMetricChip(Icons.wifi, city.internetSpeed != null ? '${city.internetSpeed} Mbps' : 'Net: N/A'),
        _buildMetricChip(Icons.security, city.safetyIndex != null ? 'Safety: ${city.safetyIndex}/10' : 'Safety: N/A'),
        _buildMetricChip(Icons.compress, city.atmosphericPressure != null ? '${city.atmosphericPressure} hPa' : 'Press: N/A'),
        _buildMetricChip(Icons.bed_outlined, city.rent1Room != null ? '1-bed: \$${city.rent1Room}' : '1-bed: N/A'),
        _buildMetricChip(Icons.bed, city.rent2Room != null ? '2-bed: \$${city.rent2Room}' : '2-bed: N/A'),
        _buildMetricChip(Icons.bedroom_parent_outlined, city.rent3Room != null ? '3-bed: \$${city.rent3Room}' : '3-bed: N/A'),
        _buildMetricChip(Icons.house_outlined, city.rentHouse != null ? 'House: \$${city.rentHouse}' : 'House: N/A'),
        _buildMetricChip(Icons.local_taxi_outlined, city.taxiPrice != null ? 'Taxi: \$${city.taxiPrice}' : 'Taxi: N/A'),
        _buildMetricChip(Icons.directions_bus_outlined, city.publicTransportPrice != null ? 'Transit: \$${city.publicTransportPrice}' : 'Transit: N/A'),
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
          BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 4, offset: const Offset(-2, -2)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(2, 2)),
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

  Widget _buildMockReviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFC9BA9B), size: 16))),
          const SizedBox(height: 8),
          const Text('Review title', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Review body goes here. It was an amazing experience visiting this beautiful city.', style: TextStyle(fontFamily: 'SFPro', fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 16, color: Colors.white)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Reviewer name', style: TextStyle(fontFamily: 'SFPro', fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('Date', style: TextStyle(fontFamily: 'SFPro', fontSize: 10, color: Colors.grey)),
                ],
              )
            ],
          )
        ],
      ),
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
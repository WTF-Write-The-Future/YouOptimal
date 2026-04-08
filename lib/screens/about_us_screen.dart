import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  final Color bgScreen = const Color(0xFFF7F3E8);
  final Color textDark = const Color(0xFF2B3233); 
  final Color textGrey = const Color(0xFF747D80); 

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: bgScreen,
      appBar: const MainAppHeader(showFavourite: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Робимо контейнер мінімум на всю висоту екрана для центрування
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24.0 : 60.0, vertical: 60.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1080), 
                    child: isMobile
                        ? Column(
                            children: [
                              _buildWhoWeAreCard(),
                              const SizedBox(height: 24),
                              _buildVisionCard(),
                              const SizedBox(height: 24),
                              _buildMissionCard(),
                              const SizedBox(height: 24),
                              _buildGoalCard(),
                              const SizedBox(height: 24),
                              _buildTechStackCard(),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // КОЛОНКА 1
                              Expanded(
                                flex: 7, 
                                child: _buildWhoWeAreCard(),
                              ),
                              const SizedBox(width: 32), 
                              
                              // КОЛОНКА 2
                              Expanded(
                                flex: 9,
                                child: Column(
                                  children: [
                                    _buildVisionCard(),
                                    const SizedBox(height: 32),
                                    _buildGoalCard(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),

                              // КОЛОНКА 3
                              Expanded(
                                flex: 9,
                                child: Column(
                                  children: [
                                    _buildMissionCard(),
                                    const SizedBox(height: 32),
                                    _buildTechStackCard(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // === КАРТКИ ===

  Widget _buildWhoWeAreCard() {
    return _buildBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, size: 28, color: textDark),
              const SizedBox(width: 12),
              Expanded(child: Text('Who We Are', style: TextStyle(fontFamily: 'SFPro', fontSize: 26, fontWeight: FontWeight.w900, color: textDark))),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'SFPro', fontSize: 18, color: textGrey, height: 1.6, fontWeight: FontWeight.w500),
              children: [
                const TextSpan(text: 'Team '),
                TextSpan(text: 'WTF (Write The Future) ', style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
                const TextSpan(text: 'is a collective of young developers and designers from Lviv Polytechnic. We are united by our flagship project, '),
                TextSpan(text: 'YouOptimal ', style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(Icons.language, size: 20, color: textGrey), 
                  ),
                ),
                const TextSpan(text: ' combining technical expertise and creativity to build digital solutions that anticipate tomorrow\'s needs.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionCard() => _buildSimpleCard(Icons.visibility_outlined, 'Our Vision', 'We believe choosing a new city shouldn\'t be a lottery. We are building a single platform where technology simplifies your search and works for your comfort.');
  Widget _buildMissionCard() => _buildSimpleCard(Icons.gps_fixed, 'Our Mission', 'Our mission is to transform scattered data into a simple tool that gathers and analyzes key city insights—from rental costs and safety to internet quality and local atmosphere.');
  Widget _buildGoalCard() => _buildSimpleCard(Icons.track_changes, 'Our Goal', 'We make YouOptimal the ultimate relocation companion, blending precision with inspiration. Find your ideal "place of power" in just a few clicks with effortless, up-to-date global insights.');

  Widget _buildSimpleCard(IconData icon, String title, String desc) {
    return _buildBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: textDark),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontFamily: 'SFPro', fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
            ],
          ),
          const SizedBox(height: 16),
          Text(desc, style: TextStyle(fontFamily: 'SFPro', fontSize: 14, color: textGrey, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTechStackCard() {
    return _buildBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.view_in_ar_outlined, size: 22, color: textDark),
              const SizedBox(width: 8),
              Text('Our Tech Stack', style: TextStyle(fontFamily: 'SFPro', fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
            ],
          ),
          const SizedBox(height: 24),
          _buildTechItem('Python', 'https://cdn-icons-png.flaticon.com/512/5968/5968350.png', isNetwork: true),
          const SizedBox(height: 16),
          _buildTechItem('FastAPI', '', isCustomFastApi: true),
          const SizedBox(height: 16),
          _buildTechItem('Flutter', '', isFlutter: true),
        ],
      ),
    );
  }

  Widget _buildTechItem(String name, String url, {bool isNetwork = false, bool isCustomFastApi = false, bool isFlutter = false}) {
    Widget icon;
    if (isCustomFastApi) {
      icon = Container(width: 26, height: 26, decoration: const BoxDecoration(color: Color(0xFF009688), shape: BoxShape.circle), child: const Icon(Icons.bolt, color: Colors.white, size: 18));
    } else if (isFlutter) {
      icon = const FlutterLogo(size: 26);
    } else {
      icon = Image.network(url, width: 26, height: 26, errorBuilder: (_, __, ___) => Icon(Icons.code, size: 26, color: textDark));
    }

    return Row(
      children: [
        icon,
        const SizedBox(width: 16),
        Text(name, style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
        const Spacer(),
        CircleAvatar(radius: 3.5, backgroundColor: textDark), 
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildBaseCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0), 
            child: child,
          ),
          
          // === ТЕПЕР ТУТ ІДЕАЛЬНО ЧИСТА ДУГА БЕЗ РИСОК ===
          Positioned(
            bottom: 24,
            right: 24,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: _CornerArcPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// Спеціальний клас для малювання тільки дуги
class _CornerArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B3233)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 // Товщина лінії
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Починаємо з нижнього лівого кута уявної області 20х20
    path.moveTo(0, size.height);
    // Малюємо дугу до верхнього правого кута
    path.arcToPoint(
      Offset(size.width, 0),
      radius: Radius.circular(size.width),
      clockwise: false,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
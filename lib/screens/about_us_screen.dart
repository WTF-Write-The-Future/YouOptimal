import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: AppState.bgMain,
      appBar: const MainAppHeader(), // Наш чистий хедер
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: isMobile 
                  ? Column(
                      children: [
                        _buildCard1(),
                        const SizedBox(height: 24),
                        _buildCard2(),
                        const SizedBox(height: 24),
                        _buildCard3(),
                        const SizedBox(height: 24),
                        _buildCard4(),
                        const SizedBox(height: 24),
                        _buildCard5(),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCard1(), // Висока картка зліва
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            _buildCard2(),
                            const SizedBox(height: 24), // Відстань між картками 24px
                            _buildCard3(),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            _buildCard4(),
                            const SizedBox(height: 24),
                            _buildCard5(),
                          ],
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // БАЗОВИЙ ВІДЖЕТ КАРТКИ (Оновлені розміри)
  Widget _buildCardBase(String title, List<TextSpan> spans, {bool isTall = false}) {
    return Container(
      width: 340, // Трохи розширили для кращої читабельності тексту
      height: isTall ? 504 : 240, // Збільшили висоту: 240 + 24 (відступ) + 240 = 504
      decoration: BoxDecoration(
        color: AppState.bgCard, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, 8))]
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(28), // Трохи зменшили відступи від країв
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppState.textMain)),
                const SizedBox(height: 16),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: AppState.textMuted, height: 1.5, fontSize: 14),
                      children: spans,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // ІДЕАЛЬНА ДУГА: Малюємо велике коло і обрізаємо його (обхід бага Flutter)
          Positioned(
            bottom: 0,
            right: 0,
            child: ClipRect(
              child: SizedBox(
                width: 24,
                height: 24,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 48, // Робимо коло вдвічі більшим
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppState.textMain, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  // --- ВМІСТ КАРТОК ---

  Widget _buildCard1() => _buildCardBase(
    'Who We Are', 
    [
      const TextSpan(text: 'Team '),
      TextSpan(text: 'WTF (Write The Future)', style: TextStyle(fontWeight: FontWeight.bold, color: AppState.textMain)),
      const TextSpan(text: ' is a collective of young developers and designers from Lviv Polytechnic. We are united by our flagship project, '),
      TextSpan(text: 'YouOptimal', style: TextStyle(fontWeight: FontWeight.bold, color: AppState.textMain)),
      const TextSpan(text: ', combining technical expertise and creativity to build digital solutions that anticipate tomorrow\'s needs.'),
    ], 
    isTall: true
  );

  Widget _buildCard2() => _buildCardBase(
    'Our Vision', 
    [
      const TextSpan(text: 'We believe choosing a new city shouldn\'t be a lottery. We are building a single platform where technology simplifies your search and works for your comfort.'),
    ]
  );

  Widget _buildCard3() => _buildCardBase(
    'Our Goal', 
    [
      const TextSpan(text: 'We make '),
      TextSpan(text: 'YouOptimal', style: TextStyle(fontWeight: FontWeight.bold, color: AppState.textMain)),
      const TextSpan(text: ' the ultimate relocation companion, blending precision with inspiration. Find your ideal "place of power" in just a few clicks with effortless, up-to-date global insights.'),
    ]
  );

  Widget _buildCard4() => _buildCardBase(
    'Our Mission', 
    [
      const TextSpan(text: 'Our mission is to transform scattered data into a simple tool that gathers and analyzes key city insights—from rental costs and safety to internet quality and local atmosphere.'),
    ]
  );

  Widget _buildCard5() => _buildCardBase(
    'Our Tech Stack', 
    [
      TextSpan(text: 'YouOptimal', style: TextStyle(fontWeight: FontWeight.bold, color: AppState.textMain)),
      const TextSpan(text: ' uses Python, FastAPI, and APIs to deliver reliable, real-time city insights. With a seamless Flutter interface, we ensure a fast, stable experience for a world in motion.'),
    ]
  );
}
import 'package:flutter/material.dart';
import '../models/city.dart';
import '../widgets/custom_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/custom_snackbar.dart'; 

class ReviewScreen extends StatefulWidget {
  final City city;

  const ReviewScreen({super.key, required this.city});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // Окремі змінні для кожної категорії
  int _safetyStars = 0;
  int _architectureStars = 0;
  int _cultureStars = 0;
  
  // Контролери для тексту
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  final Color _bgScreen = const Color(0xFFF7F3E8);
  final Color _bgModal = const Color(0xFFFFFDF8);
  final Color _textDark = const Color(0xFF485759);
  final Color _accentGold = const Color(0xFFC9BA9B);

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 768; 

    return Scaffold(
      backgroundColor: _bgScreen,
      appBar: const MainAppHeader(showFavourite: true),
      // НОВЕ: LayoutBuilder дозволяє дізнатися точну висоту доступного екрана
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Змушуємо контент бути мінімум такої ж висоти, як екран
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0), // Трохи зменшили вертикальний відступ
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 900), 
                    decoration: BoxDecoration(
                      color: _bgModal,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: isMobile 
                      ? Column(
                          mainAxisSize: MainAxisSize.min, // Щоб колонка не розтягувалась нескінченно
                          children: [
                            _buildLeftCitySection(isMobile: true),
                            _buildRightReviewSection(isMobile: true),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            IntrinsicWidth(child: _buildLeftCitySection(isMobile: false)),
                            Expanded(
                              child: _buildRightReviewSection(isMobile: false),
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

  // === ЛІВА ЧАСТИНА (Лого та назва) ===
  Widget _buildLeftCitySection({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 32.0 : 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 120 : 160,
            height: isMobile ? 120 : 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: widget.city.image.isNotEmpty 
                ? DecorationImage(
                    image: NetworkImage(widget.city.image), 
                    fit: BoxFit.cover,
                  )
                : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: widget.city.image.isEmpty 
              ? const Center(child: Icon(Icons.location_city, size: 60, color: Colors.grey))
              : null,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(color: _accentGold, borderRadius: BorderRadius.circular(20)),
            child: Text(
              widget.city.name.toUpperCase(),
              style: const TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.0),
            ),
          ),
        ],
      ),
    );
  }

  // === ПРАВА ЧАСТИНА (Форма) ===
  Widget _buildRightReviewSection({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 32 : 0, isMobile ? 32 : 40, isMobile ? 32 : 40, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'REVIEW',
            style: TextStyle(fontFamily: 'SFPro', fontSize: isMobile ? 36 : 42, fontWeight: FontWeight.w900, color: _textDark, letterSpacing: 1.5),
          ),
          const SizedBox(height: 24),

          // Поле: ІМ'Я
          TextField(
            controller: _nameController,
            style: TextStyle(fontFamily: 'SFPro', fontSize: 16, color: _textDark),
            decoration: _inputStyle('Your Name'),
          ),
          const SizedBox(height: 16),
          
          // Поле: ВІДГУК
          TextField(
            controller: _reviewController,
            maxLines: 4,
            style: TextStyle(fontFamily: 'SFPro', fontSize: 16, color: _textDark),
            decoration: _inputStyle('Share your detailed experience...'),
          ),
          const SizedBox(height: 32),
          
          Text(
            'RATE',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 20, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: 1.0),
          ),
          const SizedBox(height: 20),
          
          // Окремі категорії оцінок
          _buildRatingRow('Safety', _safetyStars, (val) => setState(() => _safetyStars = val)),
          const SizedBox(height: 12),
          _buildRatingRow('Architecture', _architectureStars, (val) => setState(() => _architectureStars = val)),
          const SizedBox(height: 12),
          _buildRatingRow('Culture', _cultureStars, (val) => setState(() => _cultureStars = val)),
          
          const SizedBox(height: 32),
          
          // Кнопка SEND
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                // 1. Валідація тексту
                if (_nameController.text.trim().isEmpty || _reviewController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in your name and review text!')),
                  );
                  return;
                }

                // 2. Валідація оцінок 
                if (_safetyStars == 0 || _architectureStars == 0 || _cultureStars == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please rate all categories!')),
                  );
                  return;
                }

                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) {
                  CustomSnackBar.show(
                    context, 
                    message: 'You must be logged in to leave a review!',
                    isError: true, // Ставимо true, щоб вона була червоною (як помилка/попередження)
                  );
                  return;
                }

                // 4. ВІДПРАВКА В БАЗУ ДАНИХ
                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFC9BA9B))),
                  );

                  await Supabase.instance.client.from('review').insert({
                    'city_id': widget.city.id, 
                    'user_id': user.id,
                    'author_name': _nameController.text.trim(),
                    'text': _reviewController.text.trim(),
                    'safety_rating': _safetyStars,
                    'architecture_rating': _architectureStars,
                    'culture_rating': _cultureStars,
                  });

                  if (context.mounted) Navigator.pop(context); // Закрити діалог
                  if (context.mounted) Navigator.pop(context); // Повернутись назад

                } catch (e) {
                  if (context.mounted) Navigator.pop(context); 
                  print('Помилка відправки: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving review: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SEND', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Дизайн для текстових полів
  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'SFPro', color: _textDark.withOpacity(0.4), fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: _textDark.withOpacity(0.1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: _textDark.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: _accentGold)),
    );
  }

  // Віджет для рядка з оцінками 
  Widget _buildRatingRow(String title, int currentStars, Function(int) onStarTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9E9).withOpacity(0.3), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
          ),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onStarTap(index + 1),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      index < currentStars ? Icons.star : Icons.star_border,
                      color: _accentGold,
                      size: 28,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
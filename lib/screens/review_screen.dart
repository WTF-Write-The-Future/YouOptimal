import 'package:flutter/material.dart';
import '../models/city.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';

class ReviewScreen extends StatefulWidget {
  final City city;

  const ReviewScreen({super.key, required this.city});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedStars = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600; // Перевірка на мобільний екран

    return Scaffold(
      backgroundColor: AppState.bgMain,
      appBar: const MainAppHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 24.0, bottom: 20.0), // Менший відступ для мобілки
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.click, 
                child: Container(
                  width: 32, height: 32, 
                  decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle), 
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 16)
                )
              ),
            ),
          ),
          
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 500, 
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0), // Додаткові відступи з боків на мобілці
                  padding: EdgeInsets.all(isMobile ? 24 : 40), // Менший паддінг на телефоні
                  decoration: BoxDecoration(
                    color: AppState.bgCard, 
                    borderRadius: BorderRadius.circular(24), 
                    boxShadow: AppState.isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 30, offset: const Offset(0, 10))]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Review', style: TextStyle(fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.w900, color: AppState.textMain)),
                      const SizedBox(height: 32),
                      
                      Align(
                        alignment: Alignment.centerLeft, 
                        child: Text('Input', style: TextStyle(color: AppState.textMuted, fontSize: 13, fontWeight: FontWeight.w500))
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        style: TextStyle(color: AppState.textMain),
                        decoration: InputDecoration(
                          hintText: 'write your opinion', 
                          hintStyle: TextStyle(color: AppState.textMuted, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppState.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppState.textMain)),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      if (isMobile)
                        Column(
                          children: [
                            _buildRateBlock(isMobile),
                            const SizedBox(height: 16),
                            _buildUploadBlock(isMobile),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(child: _buildRateBlock(isMobile)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildUploadBlock(isMobile)),
                          ],
                        ),
                        
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D2D2D), 
                            foregroundColor: Colors.white, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), 
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('SEND →', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виніс логіку блоків рейтингу та завантаження в окремі методи для чистоти коду
  Widget _buildRateBlock(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: AppState.bgCard,
        border: Border.all(color: AppState.border), 
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppState.isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.02), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          Text('Rate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppState.textMain)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => GestureDetector(
              onTap: () => setState(() => _selectedStars = index + 1),
              child: MouseRegion(
                cursor: SystemMouseCursors.click, 
                child: Icon(index < _selectedStars ? Icons.star : Icons.star_border, size: isMobile ? 24 : 28, color: AppState.textMain)
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBlock(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: AppState.bgCard,
        border: Border.all(color: AppState.border), 
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppState.isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.02), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          Text('Upload photo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppState.textMain)),
          const SizedBox(height: 12),
          Icon(Icons.cloud_upload_outlined, size: 28, color: AppState.textMain),
        ],
      ),
    );
  }
}
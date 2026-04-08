import 'package:flutter/material.dart';
import '../models/city.dart';
import '../widgets/custom_header.dart';

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
      backgroundColor: const Color(0xFFF7F3E8),
      appBar: const MainAppHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 24.0, bottom: 20.0),
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
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(24), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02), 
                        blurRadius: 15, 
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Review', 
                        style: TextStyle(
                          fontFamily: 'SFPro', 
                          fontSize: isMobile ? 32 : 40, 
                          fontWeight: FontWeight.w900, 
                          color: const Color(0xFF485759)
                        )
                      ),
                      const SizedBox(height: 32),
                      
                      Align(
                        alignment: Alignment.centerLeft, 
                        child: Text(
                          'Input', 
                          style: TextStyle(
                            fontFamily: 'SFPro', 
                            color: Colors.grey.shade600, 
                            fontSize: 13, 
                            fontWeight: FontWeight.w500
                          )
                        )
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        style: const TextStyle(
                          fontFamily: 'SFPro', 
                          color: Color(0xFF485759)
                        ),
                        decoration: InputDecoration(
                          hintText: 'write your opinion', 
                          hintStyle: TextStyle(
                            fontFamily: 'SFPro', 
                            color: Colors.grey.shade600, 
                            fontSize: 13
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF485759))),
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
                          child: const Text(
                            'SEND →', 
                            style: TextStyle(
                              fontFamily: 'SFPro', 
                              fontWeight: FontWeight.bold, 
                              fontSize: 12
                            )
                          ),
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

  Widget _buildRateBlock(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)), 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02), 
            blurRadius: 15, 
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Rate', 
            style: TextStyle(
              fontFamily: 'SFPro', 
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF485759)
            )
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => GestureDetector(
              onTap: () => setState(() => _selectedStars = index + 1),
              child: MouseRegion(
                cursor: SystemMouseCursors.click, 
                child: Icon(
                  index < _selectedStars ? Icons.star : Icons.star_border, 
                  size: isMobile ? 24 : 28, 
                  color: const Color(0xFF485759)
                )
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
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)), 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02), 
            blurRadius: 15, 
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Upload photo', 
            style: TextStyle(
              fontFamily: 'SFPro', 
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF485759)
            )
          ),
          const SizedBox(height: 12),
          const Icon(Icons.cloud_upload_outlined, size: 28, color: Color(0xFF485759)),
        ],
      ),
    );
  }
}
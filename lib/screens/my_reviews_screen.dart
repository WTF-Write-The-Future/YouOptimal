import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../utils/custom_snackbar.dart';

import '../models/review.dart';
import '../widgets/custom_header.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final Color bgScreen = const Color(0xFFF7F3E8);
  final Color textDark = const Color(0xFF2B3233);
  final Color accentColor = const Color(0xFFC9BA9B);

  List<Review> _myReviews = [];
  List<String> _reviewIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
  }

  Future<void> _fetchMyReviews() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('review')
          .select('review_id, author_name, text, safety_rating, architecture_rating, culture_rating, created_at, city(*)') 
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _myReviews = response.map((json) => Review.fromJson(json)).toList();
        _reviewIds = response.map((json) => json['review_id'] as String).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Помилка завантаження моїх відгуків: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReview(String reviewId, int index) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgScreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Review?', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to permanently delete this review?', style: TextStyle(fontFamily: 'SFPro')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      await Supabase.instance.client.from('review').delete().eq('review_id', reviewId);
      
      setState(() {
        _myReviews.removeAt(index);
        _reviewIds.removeAt(index);
      });

      CustomSnackBar.show(context, message: 'Review deleted successfully!');
    } catch (e) {
      print('Помилка видалення: $e');
      CustomSnackBar.show(context, message: 'Error deleting review: $e', isError: true);
    }
  }

  Future<void> _editReview(Review review, String reviewId, int index) async {
    TextEditingController nameController = TextEditingController(text: review.authorName);
    TextEditingController textController = TextEditingController(text: review.text);
    int safety = review.safetyRating;
    int architecture = review.architectureRating;
    int culture = review.cultureRating;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            
            Widget buildStarSelector(String label, int currentRating, Function(int) onChanged) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, color: textDark)),
                    Row(
                      children: List.generate(5, (i) => GestureDetector(
                        onTap: () => setDialogState(() => onChanged(i + 1)),
                        child: Icon(
                          i < currentRating ? Icons.star : Icons.star_border,
                          color: accentColor,
                          size: 28,
                        ),
                      )),
                    )
                  ],
                ),
              );
            }

            return AlertDialog(
              backgroundColor: bgScreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Edit Review - ${review.cityName ?? 'City'}', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w900, color: textDark)),
              content: SizedBox(
                width: 400, 
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildStarSelector('Safety', safety, (val) => safety = val),
                      buildStarSelector('Architecture', architecture, (val) => architecture = val),
                      buildStarSelector('Culture', culture, (val) => culture = val),
                      const SizedBox(height: 16),
                      
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Author Name', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, color: textDark)),
                        ),
                      ),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(fontFamily: 'SFPro', fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.grey, size: 20),
                          hintText: 'Your Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Your Experience', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold, color: textDark)),
                        ),
                      ),
                      TextField(
                        controller: textController,
                        maxLines: 4,
                        style: const TextStyle(fontFamily: 'SFPro', fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Update your experience...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontFamily: 'SFPro', fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (nameController.text.trim().isEmpty) {
                      CustomSnackBar.show(context, message: 'Name cannot be empty!', isError: true);
                      return;
                    }
                    if (textController.text.trim().isEmpty) {
                      CustomSnackBar.show(context, message: 'Review text cannot be empty!', isError: true);
                      return;
                    }

                    setDialogState(() => isSaving = true);
                    
                    try {
                      await Supabase.instance.client.from('review').update({
                        'author_name': nameController.text.trim(),
                        'text': textController.text.trim(),
                        'safety_rating': safety,
                        'architecture_rating': architecture,
                        'culture_rating': culture,
                      }).eq('review_id', reviewId);

                      setState(() {
                        _myReviews[index] = Review(
                          authorName: nameController.text.trim(),
                          text: textController.text.trim(),
                          safetyRating: safety,
                          architectureRating: architecture,
                          cultureRating: culture,
                          createdAt: review.createdAt,
                          cityName: review.cityName,
                          cityImage: review.cityImage,
                        );
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        CustomSnackBar.show(context, message: 'Review updated successfully!');
                      }
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                      CustomSnackBar.show(context, message: 'Error updating review: $e', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isSaving 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(color: Colors.white, fontFamily: 'SFPro', fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgScreen,
      appBar: const MainAppHeader(showFavourite: false),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MY REVIEWS',
                style: TextStyle(fontFamily: 'SFPro', fontSize: 36, fontWeight: FontWeight.w900, color: textDark),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: accentColor))
                    : _myReviews.isEmpty
                        ? const Center(child: Text('You haven\'t written any reviews yet.', style: TextStyle(fontSize: 16, color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _myReviews.length,
                            itemBuilder: (context, index) {
                              final review = _myReviews[index];
                              final reviewId = _reviewIds[index];
                              
                              return _buildMyReviewCard(review, reviewId, index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyReviewCard(Review review, String reviewId, int index) {
    String formattedDate = DateFormat('dd MMM yyyy').format(review.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        // === ВИПРАВЛЕНО ОСЬ ТУТ: Вирівнювання по центру по вертикалі ===
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          // 1. ФОТО МІСТА (Збільшено до 100)
          Container(
            width: 100, // Було 80
            height: 100, // Було 80
            decoration: BoxDecoration(
              color: bgScreen,
              shape: BoxShape.circle,
              image: review.cityImage != null && review.cityImage!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(review.cityImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: review.cityImage == null || review.cityImage!.isEmpty
                ? const Center(
                    child: Icon(Icons.location_city, color: Colors.grey, size: 40),
                  )
                : null,
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.cityName?.toUpperCase() ?? 'UNKNOWN CITY',
                            style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.w900, color: textDark, letterSpacing: 1.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < review.averageRating.round() ? Icons.star : Icons.star_border,
                              color: accentColor,
                              size: 14,
                            )),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(), 
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                          onPressed: () => _editReview(review, reviewId, index),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteReview(reviewId, index),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.text,
                  style: const TextStyle(fontFamily: 'SFPro', fontSize: 13, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Posted by ${review.authorName} on $formattedDate',
                  style: const TextStyle(fontFamily: 'SFPro', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
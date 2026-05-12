import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/home_screen.dart';
import '../screens/my_reviews_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_us_screen.dart';
import '../state/app_state.dart';
import '../utils/custom_snackbar.dart';
import '../utils/premium_transition.dart';
import '../screens/visited_cities_screen.dart';

class MainAppHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool showFavourite;

  const MainAppHeader({super.key, this.showFavourite = false});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  State<MainAppHeader> createState() => _MainAppHeaderState();
}

class _MainAppHeaderState extends State<MainAppHeader> {
  User? _user;
  late final StreamSubscription<AuthState> _authStateSubscription;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _user = supabase.auth.currentUser;
    
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _user = data.session?.user;
        });
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    
    AppState.clearUserData(); 
    AppState.resetPreferences();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 30, left: 24, right: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFC9BA9B),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF4A5556)),
              SizedBox(width: 12),
              Text('You have successfully signed out.', style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF4A5556), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return AppBar(
      backgroundColor: const Color(0xFFF7F3E8),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: isMobile ? 50 : 60,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ЛІВА ЧАСТИНА: Логотип
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // Плавний перехід на головну
                  Navigator.pushAndRemoveUntil(
                    context,
                    PremiumTransition(page: const HomeScreen()),
                    (Route<dynamic> route) => false, 
                  );
                },
                child: Image.asset(
                  'assets/logo.png', 
                  height: isMobile ? 38 : 30, ),
              ),
            ),

            // ПРАВА ЧАСТИНА: Навігація
            if (!isMobile)
              Row(
                children: [
                  _buildNavText(context, 'Settings', Icons.settings_outlined, const SettingsScreen()),
                  const SizedBox(width: 16),
                  _buildNavText(context, 'About us', Icons.info_outline, const AboutUsScreen()),
                  const SizedBox(width: 24),
                  
                  // ЛОГІКА КНОПОК / АВАТАРКИ ДЛЯ ДЕСКТОПУ
                  if (_user != null)
                    _buildUserAvatarMenu()
                  else ...[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // Плавний перехід на авторизацію
                          Navigator.push(context, PremiumTransition(page: const AuthScreen()));

                        },
                        child: const Text('Sign in', style: TextStyle(fontFamily: 'SFPro', color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    ElevatedButton(
                      onPressed: () {
                        // Плавний перехід на реєстрацію
                        Navigator.push(context, PremiumTransition(page: const AuthScreen(isLoginMode: false))); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A5556),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('Register', style: TextStyle(fontFamily: 'SFPro', fontSize: 13)),
                    ),
                  ],
                ],
              )
            else
              // ГАМБУРГЕР-МЕНЮ ДЛЯ МОБІЛОК
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
                onPressed: () => _showMobileMenu(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatarMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      tooltip: 'Account',
      child: const MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFC9BA9B),
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          _signOut();
        } else if (value == 'favorites') {
          Navigator.push(context, PremiumTransition(page: const FavoritesScreen()));
        } else if (value == 'visited') {
          Navigator.push(context, PremiumTransition(page: const VisitedCitiesScreen()));
        } else if (value == 'reviews') {
          Navigator.push(context, PremiumTransition(page: const MyReviewsScreen()));
        } 
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Signed in as', style: TextStyle(fontFamily: 'SFPro', fontSize: 10, color: Colors.grey)),
              Text(
                _user?.email ?? 'User',
                style: const TextStyle(fontFamily: 'SFPro', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4A5556)),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        
        const PopupMenuItem(
          value: 'favorites',
          child: Row(
            children: [
              Icon(Icons.favorite_border, size: 18, color: Colors.black87),
              SizedBox(width: 12),
              Text('My Favorites', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        
        const PopupMenuItem(
          value: 'visited',
          child: Row(
            children: [
              Icon(Icons.map_outlined, size: 18, color: Colors.black87),
              SizedBox(width: 12),
              Text('Visited Cities', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'reviews',
          child: Row(
            children: [
              Icon(Icons.star_outline, size: 18, color: Colors.black87),
              SizedBox(width: 12),
              Text('My Reviews', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 18),
              SizedBox(width: 10),
              Text('Sign out', style: TextStyle(fontFamily: 'SFPro', fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavText(BuildContext context, String text, IconData icon, Widget destination) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // Плавний перехід для текстових посилань
        onTap: () => Navigator.push(context, PremiumTransition(page: destination)),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontFamily: 'SFPro', color: Colors.black87, fontSize: 13)),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: Colors.black87),
          ],
        ),
      ),
    );
  }

 void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // <--- ДОДАНО: Дозволяє меню займати більше місця по висоті
      backgroundColor: const Color(0xFFF7F3E8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          // === ДОДАНО SingleChildScrollView ===
          child: SingleChildScrollView( 
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMobileMenuItem(context, 'Settings', Icons.settings_outlined, const SettingsScreen()),
                  const SizedBox(height: 16),
                  _buildMobileMenuItem(context, 'About us', Icons.info_outline, const AboutUsScreen()),
                  const SizedBox(height: 16),
                  
                  if (_user != null) ...[
                    _buildMobileMenuItem(context, 'My Favorites', Icons.favorite_border, const FavoritesScreen()),
                    const SizedBox(height: 16),
                    
                    _buildMobileMenuItem(context, 'Visited Cities', Icons.map_outlined, const VisitedCitiesScreen()),
                    const SizedBox(height: 16),
                    
                    _buildMobileMenuItem(context, 'My Reviews', Icons.star_outline, const MyReviewsScreen()),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text('Signed in as', style: TextStyle(fontFamily: 'SFPro', fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Text(
                            _user!.email ?? '',
                            style: const TextStyle(fontFamily: 'SFPro', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A5556)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _signOut();
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Sign out', style: TextStyle(fontFamily: 'SFPro', fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                    ),
                  ] else ...[
                    _buildMobileMenuItem(context, 'Sign in', Icons.login, const AuthScreen()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); 
                        Navigator.push(context, PremiumTransition(page: const AuthScreen(isLoginMode: false))); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A5556),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('Register', style: TextStyle(fontFamily: 'SFPro', fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuItem(BuildContext context, String text, IconData icon, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); 
        // Плавний перехід для мобільного меню
        Navigator.push(context, PremiumTransition(page: destination));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 20),
            const SizedBox(width: 16),
            Text(
              text, 
              style: const TextStyle(fontFamily: 'SFPro', fontSize: 16, color: Colors.black87)
            ),
          ],
        ),
      ),
    );
  }
}
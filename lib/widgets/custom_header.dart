import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/home_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_us_screen.dart';
import '../state/app_state.dart'; // ДОДАНО: Імпорт AppState для очищення лайків

class MainAppHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool showFavourite;

  const MainAppHeader({super.key, this.showFavourite = false});

  @override
  Size get preferredSize => const Size.fromHeight(60);

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
    
    // ДОДАНО: Очищаємо локальні лайки, щоб гість їх не бачив
    AppState.clearFavorites();
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
      toolbarHeight: 60,
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false, 
                  );
                },
                child: Image.asset('assets/logo.png', height: 30),
              ),
            ),

            // ПРАВА ЧАСТИНА: Навігація
            if (!isMobile)
              Row(
                children: [
                  // === ВИПРАВЛЕНО: widget.showFavourite ===
                  if (widget.showFavourite) ...[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                        },
                        child: const Row(
                          children: [
                            Text('Favourite', style: TextStyle(fontFamily: 'SFPro', color: Colors.black87, fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(Icons.favorite_border, color: Colors.black87, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                        },
                        child: const Text('Sign in', style: TextStyle(fontFamily: 'SFPro', color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
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
                icon: const Icon(Icons.menu, color: Colors.black87, size: 28),
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
        if (value == 'logout') _signOut();
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
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
      backgroundColor: const Color(0xFFF7F3E8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMobileMenuItem(context, 'Favourite', Icons.favorite_border, const FavoritesScreen()),
                const SizedBox(height: 16),
                _buildMobileMenuItem(context, 'Settings', Icons.settings_outlined, const SettingsScreen()),
                const SizedBox(height: 16),
                _buildMobileMenuItem(context, 'About us', Icons.info_outline, const AboutUsScreen()),
                const SizedBox(height: 32),
                
                if (_user != null) ...[
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
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
        );
      },
    );
  }

  Widget _buildMobileMenuItem(BuildContext context, String text, IconData icon, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); 
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
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
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/register_screen.dart';
import '../screens/login_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_us_screen.dart';

class MainAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showFavourite;

  const MainAppHeader({super.key, this.showFavourite = false});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return AppBar(
      backgroundColor: const Color(0xFFF7F3E8),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 80,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ЛІВА ЧАСТИНА: Тільки Логотип
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
                child: Image.asset('assets/logo.png', height: 40),
              ),
            ),

            // ПРАВА ЧАСТИНА: Навігація
            if (!isMobile)
              Row(
                children: [
                  // КНОПКА FAVOURITE (Десктоп - залежить від showFavourite)
                  if (showFavourite) ...[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                        },
                        child: Row(
                          children: const [
                            Text('Favourite', style: TextStyle(fontFamily: 'Georgia', color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(width: 6),
                            Icon(Icons.favorite_border, color: Colors.black87, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                  
                  _buildNavText(context, 'Settings', Icons.settings_outlined, const SettingsScreen()),
                  const SizedBox(width: 32),
                  _buildNavText(context, 'About us', Icons.help_outline, const AboutUsScreen()),
                  const SizedBox(width: 32),
                  
                  // КНОПКА SIGN IN
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      child: const Text('Sign in', style: TextStyle(fontFamily: 'Georgia', color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // КНОПКА REGISTER
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF485759),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
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

  // Допоміжний віджет для тексту з іконкою поруч (десктоп)
  Widget _buildNavText(BuildContext context, String text, IconData icon, Widget destination) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontFamily: 'Georgia', color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            Icon(icon, size: 18, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  // Функція показу мобільного меню (Bottom Sheet)
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
                // === ТЕПЕР FAVOURITE ПОКАЗУЄТЬСЯ ЗАВЖДИ В МЕНЮ ===
                _buildMobileMenuItem(context, 'Favourite', Icons.favorite_border, const FavoritesScreen()),
                const SizedBox(height: 16),

                _buildMobileMenuItem(context, 'Settings', Icons.settings_outlined, const SettingsScreen()),
                const SizedBox(height: 16),
                _buildMobileMenuItem(context, 'About us', Icons.help_outline, const AboutUsScreen()),
                const SizedBox(height: 16),
                _buildMobileMenuItem(context, 'Sign in', Icons.login, const LoginScreen()),
                const SizedBox(height: 32),
                
                // ВЕЛИКА КНОПКА REGISTER (Мобільна)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Закриваємо меню
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())); // Переходимо на екран
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF485759),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Допоміжний віджет для пунктів мобільного меню
  Widget _buildMobileMenuItem(BuildContext context, String text, IconData icon, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Спочатку закриваємо меню
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(width: 16),
            Text(
              text, 
              style: const TextStyle(fontFamily: 'Georgia', fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600)
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
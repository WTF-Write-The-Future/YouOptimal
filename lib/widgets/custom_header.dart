import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/favorites_screen.dart';
import '../state/app_state.dart';
import '../utils/premium_transition.dart'; // ПІДКЛЮЧИЛИ АНІМАЦІЮ

class MainAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showFavourite; 

  const MainAppHeader({super.key, this.showFavourite = false});

  @override
  final Size preferredSize = const Size.fromHeight(70.0);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(color: AppState.bgHeader, border: Border(bottom: BorderSide(color: AppState.border, width: 1))),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        titleSpacing: isMobile ? 16 : 40,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(context, PremiumTransition(page: const HomeScreen()), (route) => false), // ПЛАВНИЙ ПЕРЕХІД
              child: MouseRegion(cursor: SystemMouseCursors.click, child: Text('YouOptimal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppState.textMain))),
            ),
            if (showFavourite && !isMobile) ...[
              const SizedBox(width: 40),
              TextButton(
                onPressed: () => Navigator.push(context, PremiumTransition(page: const FavoritesScreen())), // ПЛАВНИЙ ПЕРЕХІД
                style: TextButton.styleFrom(foregroundColor: AppState.textMuted),
                child: Row(
                  children: [
                    Text('Favourite', style: TextStyle(color: AppState.textMuted, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Icon(Icons.favorite_border, size: 18, color: AppState.textMuted),
                  ],
                ),
              ),
            ]
          ],
        ),
        actions: isMobile 
          ? [
              IconButton(
                icon: Icon(Icons.menu, color: AppState.textMain), 
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppState.bgCard,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppState.border, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 10),
                          if (showFavourite)
                            ListTile(
                              leading: Icon(Icons.favorite_border, color: AppState.textMain),
                              title: Text('Favourite', style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold)),
                              onTap: () { Navigator.pop(context); Navigator.push(context, PremiumTransition(page: const FavoritesScreen())); }, // ПЛАВНИЙ ПЕРЕХІД
                            ),
                          ListTile(
                            leading: Icon(Icons.settings_outlined, color: AppState.textMain),
                            title: Text('Settings', style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold)),
                            onTap: () { Navigator.pop(context); Navigator.push(context, PremiumTransition(page: const SettingsScreen())); }, // ПЛАВНИЙ ПЕРЕХІД
                          ),
                          ListTile(
                            leading: Icon(Icons.help_outline, color: AppState.textMain),
                            title: Text('About us', style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold)),
                            onTap: () { Navigator.pop(context); Navigator.push(context, PremiumTransition(page: const AboutUsScreen())); }, // ПЛАВНИЙ ПЕРЕХІД
                          ),
                          ListTile(
                            leading: Icon(Icons.login, color: AppState.textMain),
                            title: Text('Sign in', style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold)),
                            onTap: () { Navigator.pop(context); Navigator.push(context, PremiumTransition(page: const LoginScreen())); }, // ПЛАВНИЙ ПЕРЕХІД
                          ),
                          ListTile(
                            leading: Icon(Icons.person_add_alt_1, color: AppState.textMain),
                            title: Text('Register', style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold)),
                            onTap: () { Navigator.pop(context); Navigator.push(context, PremiumTransition(page: const RegisterScreen())); }, // ПЛАВНИЙ ПЕРЕХІД
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                }
              ), 
              const SizedBox(width: 8)
            ] 
          : [
              TextButton(
                onPressed: () => Navigator.push(context, PremiumTransition(page: const SettingsScreen())), // ПЛАВНИЙ ПЕРЕХІД
                child: Row(
                  children: [
                    Text('Settings', style: TextStyle(color: AppState.textMuted, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Icon(Icons.settings_outlined, size: 16, color: AppState.textMuted),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.push(context, PremiumTransition(page: const AboutUsScreen())), // ПЛАВНИЙ ПЕРЕХІД
                child: Row(
                  children: [
                    Text('About us', style: TextStyle(color: AppState.textMuted, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Icon(Icons.help_outline, size: 16, color: AppState.textMuted),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.push(context, PremiumTransition(page: const LoginScreen())), // ПЛАВНИЙ ПЕРЕХІД
                child: Text('Sign in', style: TextStyle(color: AppState.textMuted, fontWeight: FontWeight.bold))
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(right: 40.0, top: 6, bottom: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D2D2D), 
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), 
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24)
                  ),
                  onPressed: () => Navigator.push(context, PremiumTransition(page: const RegisterScreen())), // ПЛАВНИЙ ПЕРЕХІД
                  child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
      ),
    );
  }
}
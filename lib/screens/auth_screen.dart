import 'dart:async'; // ДОДАНО: для відстеження змін статусу (логін/логаут)
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/home_screen.dart';
import '../state/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final supabase = Supabase.instance.client;
  
  // ДОДАНО: Змінні для зберігання поточного користувача
  User? _user;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Отримуємо поточного користувача при запуску екрану
    _user = supabase.auth.currentUser;
    
    // Слухаємо зміни: якщо користувач залогінився або вийшов - оновлюємо екран
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
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel(); // Обов'язково закриваємо слухача
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, left: 24, right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isError 
            ? Colors.red.shade400 
            : const Color(0xFFC9BA9B),
        elevation: 0,
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.white : const Color(0xFF4A5556),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  color: isError ? Colors.white : const Color(0xFF4A5556),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showCustomSnackBar('Please fill in all fields', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isLogin) {
        // ЛОГІКА ВХОДУ
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        // ДОДАНО: Юзер успішно увійшов - миттєво підтягуємо його лайки!
       await AppState.syncFavorites();
      await AppState.syncPreferences();
       
        
        if (mounted) {
          _showCustomSnackBar('Successfully logged in!');
        }
      }
    } on AuthException catch (error) {
      if (mounted) _showCustomSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) _showCustomSnackBar('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // === ДОДАНО: Функція для виходу з акаунта ===
  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      _showCustomSnackBar('You have successfully signed out.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: Column(
          children: [
            // === ВЕРХНЄ МЕНЮ (Header) ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      child: Image.asset('assets/logo.png', height: 30),
                    ),
                  ),
                  const Spacer(),
                  if (MediaQuery.of(context).size.width > 600) ...[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())),
                        child: const Row(
                          children: [
                            Text('Favourite', style: TextStyle(fontFamily: 'SFPro', fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(Icons.favorite_border, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                        child: const Row(
                          children: [
                            Text('Settings', style: TextStyle(fontFamily: 'SFPro', fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(Icons.settings_outlined, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen())),
                        child: const Row(
                          children: [
                            Text('About us', style: TextStyle(fontFamily: 'SFPro', fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(Icons.info_outline, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],

                  // === ЛОГІКА ПЕРЕМИКАННЯ АВАТАР / КНОПКИ ===
                  _user != null
                      ? _buildUserAvatarMenu() // Якщо залогінений - показуємо аватарку
                      : (isLogin // Якщо ні - старі кнопки
                          ? ElevatedButton(
                              onPressed: _isLoading ? null : _toggleAuthMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A5556),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Register', style: TextStyle(fontFamily: 'SFPro', fontSize: 13)),
                            )
                          : TextButton(
                              onPressed: _isLoading ? null : _toggleAuthMode,
                              style: TextButton.styleFrom(foregroundColor: Colors.black87),
                              child: const Text('Sign in', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.bold)),
                            )),
                ],
              ),
            ),

            // === ЦЕНТРАЛЬНА ЧАСТИНА ===
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo.png', height: 100),
                      const SizedBox(height: 16),
                      const Text(
                        'YOUOPTIMAL',
                        style: TextStyle(fontFamily: 'SFPro', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A5556), letterSpacing: 1.5),
                      ),
                      const Text(
                        'TRAVEL & DISCOVER',
                        style: TextStyle(fontFamily: 'SFPro', fontSize: 12, color: Colors.grey, letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 30),

                      // === ЛОГІКА ВІДОБРАЖЕННЯ ФОРМИ АБО ВІТАННЯ ===
                      _user != null 
                          ? _buildWelcomeCard() // Показуємо "Ласкаво просимо" якщо є юзер
                          : _buildAuthForm(),   // Або форму входу/реєстрації
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === НОВИЙ ВІДЖЕТ: Меню користувача (Аватар + Випадне меню) ===
  Widget _buildUserAvatarMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45), // Опускаємо меню трохи нижче аватара
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      tooltip: 'Account',
      child: const MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFC9BA9B), // Бежевий колір
          child: Icon(Icons.person, color: Colors.white, size: 24),
        ),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          _signOut();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false, // Не клікабельно, просто інфо
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

 // === ОНОВЛЕНА КАРТКА ДЛЯ ЗАЛОГІНЕНОГО КОРИСТУВАЧА ===
  Widget _buildWelcomeCard() {
    return Container(
      width: 380,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 60, color: Color(0xFFC9BA9B)),
          const SizedBox(height: 20),
          const Text(
            'Welcome back!',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A5556)),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to travel and discover?',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'SFPro', fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32), // Відступ перед новою кнопкою

          // === НОВА КНОПКА "LET'S TRAVEL" ===
          ElevatedButton(
            onPressed: () {
              // Використовуємо pushAndRemoveUntil, щоб стерти історію переходів.
              // Це потрібно, щоб при натисканні кнопки "Назад" на телефоні 
              // користувача не викинуло знову на екран авторизації.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5556), // Темний колір для контрасту
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Кнопка обтягує текст
              children: [
                Text(
                  "LET'S TRAVEL",
                  style: TextStyle(fontFamily: 'SFPro', fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18), // Іконка стрілочки
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === ВІДЖЕТ ФОРМИ (Твій старий дизайн, тільки без Forgot Password) ===
  Widget _buildAuthForm() {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Email', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'SFPro', fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTextField(controller: _emailController, hintText: 'enter your email adress', obscureText: false),
          const SizedBox(height: 20),

          const Text('Password', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'SFPro', fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTextField(controller: _passwordController, hintText: isLogin ? 'enter your password' : 'create password', obscureText: true),
          const SizedBox(height: 24), // Відступ змінено, бо немає Forgot Password

          ElevatedButton(
            onPressed: _isLoading ? null : _authenticate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9BA9B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    isLogin ? 'SIGN IN' : 'REGISTER',
                    style: const TextStyle(fontFamily: 'SFPro', fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
          ),

          if (!isLogin) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isLoading ? null : _toggleAuthMode,
              child: const Text(
                'Already have an account ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'SFPro', fontSize: 11, color: Colors.grey),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, required bool obscureText}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'SFPro', fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC9BA9B)),
        ),
      ),
    );
  }
}
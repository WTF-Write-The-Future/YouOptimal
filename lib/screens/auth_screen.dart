import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/settings_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/home_screen.dart';
import '../state/app_state.dart';
import '../utils/custom_snackbar.dart';

class AuthScreen extends StatefulWidget {
  final bool isLoginMode; 

  const AuthScreen({super.key, this.isLoginMode = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin; 
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final supabase = Supabase.instance.client;
  
  User? _user;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLoginMode; 
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
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel(); 
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Перевірка на порожні поля
    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar.show(context, message: 'Please fill in all fields', isError: true);
      return;
    }

    // 2. Базова перевірка формату email (наявність @ та крапки)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      CustomSnackBar.show(context, message: 'Please enter a valid email address', isError: true);
      return;
    }

    // 3. Захист від популярних опечаток (UX покращення)
    if (email.endsWith('.con') || email.endsWith('.cmo') || email.endsWith('.xom')) {
      CustomSnackBar.show(context, message: 'Looks like a typo. Did you mean .com?', isError: true);
      return;
    }
    
    // Блокуємо небажані домени
    if (email.endsWith('.ru') || email.endsWith('.by')) {
      CustomSnackBar.show(context, message: 'Москаляку на гіляку', isError: true);
      return;
    }

    // 4. Валідація довжини пароля при реєстрації
    if (!isLogin && password.length < 6) {
      CustomSnackBar.show(context, message: 'Password must be at least 6 characters long', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isLogin) {
        // === ЛОГІКА ВХОДУ ===
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        await AppState.syncFavorites();
        await AppState.syncReviewCount();
        AppState.syncVisitedCities();
        await AppState.syncPreferences();
        
        if (mounted) {
          CustomSnackBar.show(context, message: 'Successfully logged in!');
        }
      } else {
        // === ЛОГІКА РЕЄСТРАЦІЇ ===
        await supabase.auth.signUp(
          email: email,
          password: password,
        );
        
        if (mounted) {
          CustomSnackBar.show(context, message: 'Registration successful! You can now sign in.');
          setState(() {
            isLogin = true; 
            _passwordController.clear(); 
          });
        }
      }
    } on AuthException catch (error) {
      if (mounted) CustomSnackBar.show(context, message: error.message, isError: true);
    } catch (error) {
      if (mounted) CustomSnackBar.show(context, message: 'Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      CustomSnackBar.show(context, message: 'You have successfully signed out.');
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

                  // ЛОГІКА ПЕРЕМИКАННЯ АВАТАР / КНОПКИ
                  _user != null
                      ? _buildUserAvatarMenu() 
                      : (isLogin 
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
                        'YOUR RELOCATION COMPANION',
                        style: TextStyle(fontFamily: 'SFPro', fontSize: 12, color: Colors.grey, letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 30),

                      _user != null 
                          ? _buildWelcomeCard() 
                          : _buildAuthForm(), 
                      
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

  Widget _buildUserAvatarMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      tooltip: 'Account',
      child: const MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFC9BA9B), 
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
            'Ready to relocation?',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'SFPro', fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32), 

          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5556), 
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text(
                  "LET'S TRAVEL",
                  style: TextStyle(fontFamily: 'SFPro', fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18), 
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          _buildTextField(controller: _emailController, hintText: 'enter your email address', obscureText: false),
          const SizedBox(height: 20),

          const Text('Password', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'SFPro', fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTextField(controller: _passwordController, hintText: isLogin ? 'enter your password' : 'create password', obscureText: true),
          const SizedBox(height: 24),

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
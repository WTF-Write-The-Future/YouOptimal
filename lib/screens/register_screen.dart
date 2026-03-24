import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppState.bgMain,
      appBar: const MainAppHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ЧОРНА КНОПКА НАЗАД
          Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 24.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white, size: 16))),
            ),
          ),
          
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('YouOptimal', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: AppState.textMain)),
                  const SizedBox(height: 40),
                  Container(
                    width: 380,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(color: AppState.bgCard, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 30, offset: const Offset(0, 10))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppState.textMain)),
                        const SizedBox(height: 8),
                        _buildTextField('enter your email address', false),
                        const SizedBox(height: 24),
                        Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppState.textMain)),
                        const SizedBox(height: 8),
                        _buildTextField('enter your password', true),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity, height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A4A4A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
                            onPressed: () {},
                            child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, bool isPassword) {
    return TextField(
      obscureText: isPassword,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppState.textMain),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: AppState.textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppState.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppState.textMain)),
      ),
    );
  }
}
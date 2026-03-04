import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppState.bgMain,
      appBar: const MainAppHeader(), // Наш ідеально чистий хедер
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ЧОРНА КНОПКА НАЗАД (Зліва під логотипом)
          Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 24.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
          
          // ЦЕНТРАЛЬНА КАРТКА НАЛАШТУВАНЬ
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 450,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppState.bgCard, 
                    borderRadius: BorderRadius.circular(24), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Settings', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppState.textMain)),
                      const SizedBox(height: 32),
                      
                      // ТЕМИ
                      ValueListenableBuilder(
                        valueListenable: AppState.theme,
                        builder: (context, _, __) => _buildSettingSection('Themes', [
                          _buildThemeToggle('Light', AppState.theme.value == 'Light', () => AppState.theme.value = 'Light'),
                          _buildThemeToggle('Dark', AppState.theme.value == 'Dark', () => AppState.theme.value = 'Dark'),
                        ]),
                      ),
                      
                      // ВАЛЮТА (Стиль iOS Segmented Control)
                      ValueListenableBuilder(
                        valueListenable: AppState.currency,
                        builder: (context, _, __) => _buildSettingSection('Currency', [
                          _buildSegmentedControl(['EUR', 'USD', 'UAH'], AppState.currency.value, (val) => AppState.currency.value = val),
                        ]),
                      ),
                      
                      // ТЕМПЕРАТУРА (Стиль iOS Segmented Control)
                      ValueListenableBuilder(
                        valueListenable: AppState.tempUnit,
                        builder: (context, _, __) => _buildSettingSection('Temperature Units', [
                          _buildSegmentedControl(['°C', '°F'], AppState.tempUnit.value, (val) => AppState.tempUnit.value = val),
                        ]),
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

  // Заголовок розділу з крапочкою
  Widget _buildSettingSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• $title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppState.textMain)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: items),
        ],
      ),
    );
  }

  // Кнопка перемикання тем (з іконкою тумблера)
  Widget _buildThemeToggle(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppState.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 8),
              Icon(
                isActive ? Icons.toggle_on : Icons.toggle_off, 
                size: 20, 
                color: isActive ? AppState.textMain : AppState.textMuted
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Сегментований контроль (Валюта та Температура) як на макеті
  Widget _buildSegmentedControl(List<String> options, String currentValue, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.all(4), // Відступ для внутрішніх кнопок
      decoration: BoxDecoration(
        color: AppState.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0), // Світло-сірий фон
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          bool isActive = option == currentValue;
          return GestureDetector(
            onTap: () => onChanged(option),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppState.bgCard : Colors.transparent, // Білий фон якщо активна
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive 
                    ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))] 
                    : [], // Легка тінь як на макеті
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: AppState.textMain, 
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600, 
                    fontSize: 13
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
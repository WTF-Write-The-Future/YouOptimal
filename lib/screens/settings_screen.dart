import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState.theme,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: AppState.bgMain, 
          appBar: const MainAppHeader(), 
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // КНОПКА НАЗАД
              Padding(
                padding: const EdgeInsets.only(left: 40.0, top: 24.0, bottom: 20.0),
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
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 450,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppState.bgCard, 
                        borderRadius: BorderRadius.circular(24), 
                        boxShadow: AppState.isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 20, offset: const Offset(0, 8))]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppState.textMain)),
                          const SizedBox(height: 32),
                          
                          // THEMES 
                          _buildSettingSection('Themes', [
                            _buildThemeToggle('Light', AppState.theme.value == 'Light', () => AppState.theme.value = 'Light'),
                            _buildThemeToggle('Dark', AppState.theme.value == 'Dark', () => AppState.theme.value = 'Dark'),
                          ]),
                          
                          // CURRENCY
                          ValueListenableBuilder(
                            valueListenable: AppState.currency,
                            builder: (context, _, __) => _buildSettingSection('Currency', [
                              _buildSegmentedControl(['EUR', 'USD', 'UAH'], AppState.currency.value, (val) => AppState.currency.value = val),
                            ]),
                          ),
                          
                          // TEMPERATURE UNITS
                          ValueListenableBuilder(
                            valueListenable: AppState.tempUnit,
                            builder: (context, _, __) => _buildSettingSection('Temperature Units', [
                              _buildPillButton('°C', AppState.tempUnit.value == 'C', () => AppState.tempUnit.value = 'C'),
                              _buildPillButton('°F', AppState.tempUnit.value == 'F', () => AppState.tempUnit.value = 'F'),
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
    );
  }

  Widget _buildSettingSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• $title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppState.textMain)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: items),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppState.isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, style: TextStyle(color: AppState.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 8),
              Icon(isActive ? Icons.toggle_on : Icons.toggle_off, size: 20, color: isActive ? AppState.textMain : AppState.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(List<String> options, String currentValue, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppState.isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
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
                  color: isActive ? AppState.bgCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha:0.08), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Text(option, style: TextStyle(color: AppState.textMain, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPillButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppState.bgCard : (AppState.isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha:0.08), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Text(text, style: TextStyle(color: AppState.textMain, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
        ),
      ),
    );
  }
}
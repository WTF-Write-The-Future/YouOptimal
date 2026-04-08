import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8), 
      appBar: const MainAppHeader(), // Хедер сам додасть стрілку назад, якщо ми прийшли з іншого екрану
      body: Center( // Прибрав Stack, залишив просто Center
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 50),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(60), 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), 
                  blurRadius: 40, 
                  offset: const Offset(0, 20)
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ЗАГОЛОВОК ТА ІКОНКА
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SETTINGS', 
                      style: TextStyle(
                        fontSize: 36, 
                        fontWeight: FontWeight.w900, 
                        color: Color(0xFF485759),
                        letterSpacing: 1.2
                      )
                    ),
                    Icon(Icons.settings_outlined, size: 32, color: const Color(0xFF485759).withOpacity(0.8)),
                  ],
                ),
                const SizedBox(height: 40),
                
                // ВАЛЮТА
                _buildSectionHeader('Currency', Icons.trending_up),
                const SizedBox(height: 12),
                ValueListenableBuilder(
                      valueListenable: AppState.currency,
                      builder: (context, currentCurrency, __) => _buildSegmentedControl(
                        ['EUR', 'USD', 'UAH'], 
                        currentCurrency, 
                        (val) {
                          AppState.currency.value = val;
                          AppState.savePreference('currency', val); // ЗБЕРІГАЄМО В БД
                        }
                      ),
                    ),
                
                const SizedBox(height: 32),
                
                // ТЕМПЕРАТУРА
                _buildSectionHeader('Temperature Units', Icons.thermostat),
                const SizedBox(height: 12),
                ValueListenableBuilder(
                      valueListenable: AppState.tempUnit,
                      builder: (context, currentUnit, __) => _buildSegmentedControl(
                        ['°C', '°F'], 
                        currentUnit == 'C' ? '°C' : '°F', 
                        (val) {
                          final newUnit = val.contains('C') ? 'C' : 'F';
                          AppState.tempUnit.value = newUnit;
                          AppState.savePreference('temp_unit', newUnit); // ЗБЕРІГАЄМО В БД
                        }
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        const Text('• ', style: TextStyle(fontSize: 20, color: Color(0xFF485759), fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF485759))),
        const SizedBox(width: 8),
        Icon(icon, size: 20, color: const Color(0xFF485759)),
      ],
    );
  }

  Widget _buildSegmentedControl(List<String> options, String currentValue, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2D7C0), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          bool isActive = option == currentValue;
          return GestureDetector(
            onTap: () => onChanged(option),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: isActive ? [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ] : [],
                ),
                child: Text(
                  option, 
                  style: TextStyle(
                    color: const Color(0xFF485759), 
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600, 
                    fontSize: 14
                  )
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
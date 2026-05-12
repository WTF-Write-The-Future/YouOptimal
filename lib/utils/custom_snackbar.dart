import 'package:flutter/material.dart';

class CustomSnackBar {
  // Статичний метод, щоб викликати його з будь-якого місця програми
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false, // За замовчуванням це звичайна інфо-вспливашка
  }) {
    // Кольори: золотий для інфо, червоний для помилок
    final bgColor = isError ? const Color(0xFFE57373) : const Color(0xFFC9BA9B);
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating, // Робить її "літаючою"
      margin: const EdgeInsets.only(bottom: 30, left: 24, right: 24), // Відступи від країв
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Заокруглення
      backgroundColor: bgColor,
      elevation: 10,
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'SFPro',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    );

    // Показуємо нову вспливашку (і ховаємо попередню, якщо вона ще висить)
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
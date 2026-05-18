import 'package:flutter/material.dart';

class PremiumTransition extends PageRouteBuilder {
  final Widget page;

  PremiumTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            
            const curve = Curves.easeOutCubic;

            // Легкий рух знизу вверх
            var slideTween = Tween(begin: const Offset(0.0, 0.05), end: Offset.zero)
                .chain(CurveTween(curve: curve));

            // Плавна поява
            var fadeTween = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(slideTween),
                child: child,
              ),
            );
          },
        );
}
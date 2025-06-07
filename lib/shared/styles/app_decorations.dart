import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF181822),
        Color(0xFF221C3A),
        Color(0xFF181822),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.4, 0.8],
    ),
  );

  static BoxDecoration card({double opacity = 0.96}) => BoxDecoration(
    color: AppColors.darkCard.withOpacity(opacity),
    borderRadius: BorderRadius.circular(32),
    boxShadow: [
      BoxShadow(
        color: AppColors.purplePrimary.withOpacity(0.22),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
    border: Border.all(
      color: AppColors.purplePrimary.withOpacity(0.12),
      width: 1.2,
    ),
  );

  static BoxDecoration iconCircle = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [AppColors.purplePrimary, AppColors.purpleAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.purplePrimary.withOpacity(0.25),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
}

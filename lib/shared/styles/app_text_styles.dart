import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    color: AppColors.purpleAccent,
    fontWeight: FontWeight.bold,
    fontSize: 26,
    letterSpacing: 1.2,
    shadows: [
      Shadow(
        color: Color(0x66000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const TextStyle welcome = TextStyle(
    color: AppColors.textColor,
    fontWeight: FontWeight.bold,
    fontSize: 28,
    letterSpacing: 1.1,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.hintColor,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle cardContent = TextStyle(
    color: AppColors.purpleAccent,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.2,
  );
}

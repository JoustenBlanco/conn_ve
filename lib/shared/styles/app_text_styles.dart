import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    color: AppColors.purpleAccent,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 1.2,
  );

  static const TextStyle welcome = TextStyle(
    color: AppColors.textColor,
    fontWeight: FontWeight.bold,
    fontSize: 26,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.hintColor,
    fontSize: 16,
  );

  static const TextStyle cardContent = TextStyle(
    color: AppColors.purpleAccent,
    fontWeight: FontWeight.w600,
  );
}

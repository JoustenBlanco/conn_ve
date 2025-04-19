import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.purplePrimary, AppColors.purpleAccent, AppColors.darkBg],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration card({double opacity = 0.96}) => BoxDecoration(
    color: AppColors.darkCard.withOpacity(opacity),
    borderRadius: BorderRadius.circular(32),
    boxShadow: [
      BoxShadow(
        color: AppColors.purplePrimary.withOpacity(0.18),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration iconCircle = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [AppColors.purplePrimary, AppColors.purpleAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

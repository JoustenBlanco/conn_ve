import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import '../shared/styles/app_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        title: Text(
          'Inicio',
          style: AppTextStyles.title,
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.backgroundGradient,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.cardPaddingHorizontal,
              vertical: AppConstants.cardPaddingVertical,
            ),
            decoration: AppDecorations.card(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: AppDecorations.iconCircle,
                  padding: const EdgeInsets.all(AppConstants.iconPadding),
                  child: Icon(Icons.electric_car_rounded, color: AppColors.textColor, size: AppConstants.iconSize),
                ),
                Text(
                  '¡Bienvenido a Connected Vehicles!',
                  style: AppTextStyles.welcome,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Esta es la página de inicio. En desarrollo...',
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Espacio para futuros widgets/contenido
                Container(
                  padding: const EdgeInsets.all(AppConstants.cardInnerPadding),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(AppConstants.cardInnerBorderRadius),
                  ),
                  child: Text(
                    'Contenido principal aquí',
                    style: AppTextStyles.cardContent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

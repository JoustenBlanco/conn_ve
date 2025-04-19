import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';

class ViajesRutasPage extends StatelessWidget {
  const ViajesRutasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        title: Text('Viajes/Rutas', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.backgroundGradient,
        child: Center(
          child: Text(
            'Pantalla de Viajes/Rutas',
            style: AppTextStyles.subtitle,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String nombre = 'Juan Pérez';
    final String correo = 'juan.perez@email.com';
    final String contrasenia = '********';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        title: Text('Perfil', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.backgroundGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar/Icono usuario
                  Container(
                    decoration: AppDecorations.iconCircle,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: const Icon(
                      Icons.account_circle_rounded,
                      color: AppColors.textColor,
                      size: 90,
                    ),
                  ),
                  // Card de datos
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: AppDecorations.card(opacity: 0.97),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nombre', style: AppTextStyles.subtitle),
                        const SizedBox(height: 2),
                        Text(nombre, style: AppTextStyles.title.copyWith(fontSize: 20)),
                        const SizedBox(height: 18),
                        Text('Correo', style: AppTextStyles.subtitle),
                        const SizedBox(height: 2),
                        Text(correo, style: AppTextStyles.title.copyWith(fontSize: 18, color: AppColors.purpleAccent)),
                        const SizedBox(height: 18),
                        Text('Contraseña', style: AppTextStyles.subtitle),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(contrasenia, style: AppTextStyles.title.copyWith(fontSize: 18)),
                            const SizedBox(width: 8),
                            Icon(Icons.lock, color: AppColors.hintColor, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purplePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: AppTextStyles.title.copyWith(fontSize: 18),
                          elevation: 8,
                          shadowColor: AppColors.purpleAccent.withOpacity(0.25),
                        ),
                        icon: const Icon(Icons.logout, size: 26),
                        label: const Text('Cerrar sesión'),
                        onPressed: () {
                          // Aquí va la lógica de logout
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

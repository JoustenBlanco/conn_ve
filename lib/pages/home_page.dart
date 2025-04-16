import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color purplePrimary = const Color(0xFF7B1FA2);
    final Color purpleAccent = const Color(0xFFB388FF);
    final Color darkBg = const Color(0xFF18181A);
    final Color darkCard = const Color(0xFF23232B);
    final Color textColor = Colors.white;
    final Color hintColor = Colors.white70;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkCard,
        elevation: 0,
        title: Text(
          'Inicio',
          style: TextStyle(
            color: purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFF18181A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            decoration: BoxDecoration(
              color: darkCard.withOpacity(0.96),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: purplePrimary.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [purplePrimary, purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Icon(Icons.electric_car_rounded, color: Colors.white, size: 48),
                ),
                Text(
                  '¡Bienvenido a Connected Vehicles!',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Esta es la página de inicio. En desarrollo...',
                  style: TextStyle(color: hintColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Espacio para futuros widgets/contenido
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Contenido principal aquí',
                    style: TextStyle(color: purpleAccent, fontWeight: FontWeight.w600),
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

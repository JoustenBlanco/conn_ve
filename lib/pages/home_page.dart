import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_decorations.dart';
import 'mapa_page.dart';
import 'viajes_lista_page.dart';
import 'comunidad_page.dart';
import 'perfil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    MapaPage(),
    ViajesListaPage(),
    ComunidadPage(),
    PerfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard.withOpacity(0.98),
            border: const Border(
              top: BorderSide(
                color: Color(0xFF3C2A5D),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.purplePrimary.withOpacity(0.13),
                blurRadius: 18,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.purplePrimary,
            unselectedItemColor: AppColors.hintColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded, size: 28),
                label: 'Mapa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.alt_route_rounded, size: 28),
                label: 'Viajes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded, size: 28),
                label: 'Comunidad',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 28),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

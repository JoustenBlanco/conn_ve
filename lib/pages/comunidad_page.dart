import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import '../widgets/comunidad_feed_widgets.dart';
import '../widgets/comunidad_estaciones_widgets.dart';
import '../widgets/comunidad_grupos_widgets.dart';

class ComunidadPage extends StatelessWidget {

  const ComunidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: AppDecorations.backgroundGradient,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: AppColors.darkCard.withOpacity(0.98),
            elevation: 0,
            title: Text('Comunidad', style: AppTextStyles.title),
            centerTitle: true,
            shadowColor: AppColors.purplePrimary.withOpacity(0.12),
            iconTheme: const IconThemeData(color: AppColors.purpleAccent),
            automaticallyImplyLeading: false, // <-- elimina el botón de ir atrás
            bottom: TabBar(
              indicatorColor: AppColors.purplePrimary,
              indicatorWeight: 4,
              labelColor: AppColors.purplePrimary,
              unselectedLabelColor: AppColors.hintColor,
              labelStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTextStyles.subtitle,
              tabs: const [
                Tab(text: 'Foro'),
                Tab(text: 'Estaciones'),
                Tab(text: 'Grupos'),
              ],
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // El gradiente ya está aplicado en el contenedor principal
            child: TabBarView(
              children: [
                // --- FEED FORO ---
                FeedForo(),
                // --- ESTACIONES ---
                EstacionesList(),
                // --- GRUPOS ---
                GruposList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

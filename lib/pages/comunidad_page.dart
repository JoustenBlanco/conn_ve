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
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkCard,
          elevation: 0,
          title: Text('Comunidad', style: AppTextStyles.title),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.purpleAccent,
            labelColor: AppColors.purpleAccent,
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
          decoration: AppDecorations.backgroundGradient,
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
    );
  }
}

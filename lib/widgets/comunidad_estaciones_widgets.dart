import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';

class EstacionesList extends StatefulWidget {
  const EstacionesList({super.key});

  @override
  State<EstacionesList> createState() => _EstacionesListState();
}

class _EstacionesListState extends State<EstacionesList> {
  String filtro = 'Mejor calificación';
  final List<String> filtros = [
    'Mejor calificación',
    'Más cercanas',
    'Más reseñas',
  ];

  final List<Estacion> estaciones = const [
    Estacion(
      nombre: 'Estación UNA Heredia',
      direccion: 'Heredia, Costa Rica',
      puntuacion: 4.8,
      review: 'Excelente precisión y fácil acceso a los datos.',
    ),
    Estacion(
      nombre: 'Estación Davis San José',
      direccion: 'San José centro',
      puntuacion: 4.3,
      review: 'La información en tiempo real es muy útil.',
    ),
    Estacion(
      nombre: 'Estación Cartago Norte',
      direccion: 'Cartago, barrio Los Ángeles',
      puntuacion: 3.9,
      review: 'Buena, aunque a veces pierde conexión.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.filter_list, color: AppColors.purpleAccent),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: filtro,
                  dropdownColor: AppColors.darkCard,
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textColor),
                  iconEnabledColor: AppColors.purpleAccent,
                  borderRadius: BorderRadius.circular(18),
                  isExpanded: true,
                  items: filtros.map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => filtro = val);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: estaciones.length,
            itemBuilder: (context, index) {
              final est = estaciones[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: AppDecorations.card(opacity: 0.97),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.location_on, color: AppColors.purpleAccent, size: 32),
                        title: Text(est.nombre, style: AppTextStyles.cardContent.copyWith(fontSize: 18)),
                        subtitle: Text(est.direccion, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                        trailing: _StarRating(est.puntuacion),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.format_quote, color: AppColors.hintColor, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '"${est.review}"',
                                style: AppTextStyles.subtitle.copyWith(color: AppColors.textColor, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.purpleAccent,
                                textStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Ver detalles'),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 6),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.purpleAccent,
                                textStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.rate_review_outlined),
                              label: const Text('Dejar review'),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Estacion {
  final String nombre;
  final String direccion;
  final double puntuacion;
  final String review;
  const Estacion({
    required this.nombre,
    required this.direccion,
    required this.puntuacion,
    required this.review,
  });
}

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating(this.rating);

  @override
  Widget build(BuildContext context) {
    final int fullStars = rating.floor();
    final bool halfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (i == fullStars && halfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }
}

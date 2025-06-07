import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import '../services/estaciones_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstacionesList extends StatefulWidget {
  const EstacionesList({super.key});

  @override
  State<EstacionesList> createState() => _EstacionesListState();
}

class _EstacionesListState extends State<EstacionesList> {
  String filtro = 'Mejor calificación';
  final List<String> filtros = [
    'Mejor calificación',
    'Más reseñas',
  ];

  late Future<List<EstacionCarga>> _estacionesFuture;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _estacionesFuture = EstacionesService.obtenerEstaciones();
  }

  Future<void> _refresh() async {
    setState(() {
      _estacionesFuture = EstacionesService.obtenerEstaciones();
    });
  }

  void _showCalificarDialog(EstacionCarga estacion, ComentarioEstacion? comentarioActual, VoidCallback onDone) async {
    await showDialog(
      context: context,
      builder: (context) => CalificarEstacionDialog(
        estacion: estacion,
        comentarioActual: comentarioActual,
        onDone: onDone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EstacionCarga>>(
      future: _estacionesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final estaciones = snapshot.data ?? [];
        // Filtro de búsqueda
        List<EstacionCarga> estacionesFiltradas = estaciones.where((e) =>
          e.nombre.toLowerCase().contains(_busqueda.trim().toLowerCase())
        ).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkCard.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                ),
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
                        underline: const SizedBox(),
                        items: filtros.map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              filtro = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar estación por nombre',
                  hintStyle: AppTextStyles.subtitle.copyWith(color: AppColors.hintColor),
                  prefixIcon: const Icon(Icons.search, color: AppColors.purpleAccent),
                  filled: true,
                  fillColor: AppColors.darkCard.withOpacity(0.92),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
                onChanged: (val) => setState(() => _busqueda = val),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<List<ComentarioEstacion>>>(
                future: Future.wait(estacionesFiltradas.map((e) => EstacionesService.obtenerComentariosDeEstacion(e.id)).toList()),
                builder: (context, snapComentariosList) {
                  if (snapComentariosList.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapComentariosList.hasError) {
                    return Center(child: Text('Error: ${snapComentariosList.error}'));
                  }
                  final comentariosPorEstacion = snapComentariosList.data ?? List.generate(estacionesFiltradas.length, (_) => <ComentarioEstacion>[]);

                  // Ordenar estacionesFiltradas según filtro y comentariosPorEstacion
                  List<MapEntry<EstacionCarga, List<ComentarioEstacion>>> estacionesConComentarios = List.generate(
                    estacionesFiltradas.length,
                    (i) => MapEntry(estacionesFiltradas[i], comentariosPorEstacion[i]),
                  );

                  if (filtro == 'Mejor calificación') {
                    estacionesConComentarios.sort((a, b) {
                      final pa = a.value.isEmpty ? 0 : a.value.map((c) => c.calificacion).reduce((x, y) => x + y) / a.value.length;
                      final pb = b.value.isEmpty ? 0 : b.value.map((c) => c.calificacion).reduce((x, y) => x + y) / b.value.length;
                      return pb.compareTo(pa);
                    });
                  } else if (filtro == 'Más reseñas') {
                    estacionesConComentarios.sort((a, b) => b.value.length.compareTo(a.value.length));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: estacionesConComentarios.length,
                    itemBuilder: (context, index) {
                      final est = estacionesConComentarios[index].key;
                      final comentarios = estacionesConComentarios[index].value;
                      final double promedio = comentarios.isEmpty
                          ? 0
                          : comentarios.map((c) => c.calificacion).reduce((a, b) => a + b) / comentarios.length;
                      final int cantidad = comentarios.length;

                      return FutureBuilder<ComentarioEstacion?>(
                        future: EstacionesService.obtenerComentarioUsuarioActual(est.id),
                        builder: (context, snapMiComentario) {
                          final miComentario = snapMiComentario.data;
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
                                    subtitle: Text(
                                      '${cantidad > 0 ? promedio.toStringAsFixed(1) : 'Sin calificación'} (${cantidad} reseñas)',
                                      style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                                    ),
                                    trailing: _StarRating(promedio),
                                  ),
                                  if (comentarios.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.format_quote, color: AppColors.hintColor, size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '"${comentarios.first.comentario}" - ${comentarios.first.nombreUsuario ?? ''}',
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
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => VerComentariosDialog(
                                                comentarios: comentarios,
                                                estacion: est,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 6),
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.purpleAccent,
                                            textStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          icon: const Icon(Icons.rate_review_outlined),
                                          label: Text(miComentario == null ? 'Dejar review' : 'Editar review'),
                                          onPressed: () {
                                            _showCalificarDialog(est, miComentario, _refresh);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
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

class CalificarEstacionDialog extends StatefulWidget {
  final EstacionCarga estacion;
  final ComentarioEstacion? comentarioActual;
  final VoidCallback onDone;
  const CalificarEstacionDialog({
    required this.estacion,
    required this.comentarioActual,
    required this.onDone,
  });

  @override
  State<CalificarEstacionDialog> createState() => _CalificarEstacionDialogState();
}

class _CalificarEstacionDialogState extends State<CalificarEstacionDialog> {
  int _calificacion = 5;
  late TextEditingController _comentarioCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _calificacion = widget.comentarioActual?.calificacion ?? 5;
    _comentarioCtrl = TextEditingController(text: widget.comentarioActual?.comentario ?? '');
  }

  Future<void> _guardar() async {
    setState(() => _loading = true);
    try {
      await EstacionesService.crearOActualizarComentario(
        idEstacion: widget.estacion.id,
        calificacion: _calificacion,
        comentario: _comentarioCtrl.text.trim(),
      );
      widget.onDone();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkCard.withOpacity(0.98),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        'Calificar "${widget.estacion.nombre}"',
        style: AppTextStyles.title.copyWith(color: AppColors.purplePrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(5, (i) => IconButton(
              icon: Icon(
                i < _calificacion ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: _loading ? null : () => setState(() => _calificacion = i + 1),
            )),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _comentarioCtrl,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Comentario',
              labelStyle: AppTextStyles.subtitle.copyWith(color: AppColors.purpleAccent),
              filled: true,
              fillColor: AppColors.darkBg.withOpacity(0.85),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            enabled: !_loading,
            style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.hintColor,
            textStyle: AppTextStyles.subtitle,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purplePrimary,
            foregroundColor: AppColors.textColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: AppTextStyles.subtitle.copyWith(color: AppColors.textColor),
            elevation: 0,
          ),
          onPressed: _loading ? null : _guardar,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

class VerComentariosDialog extends StatelessWidget {
  final List<ComentarioEstacion> comentarios;
  final EstacionCarga? estacion;
  const VerComentariosDialog({required this.comentarios, this.estacion});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      backgroundColor: AppColors.darkCard.withOpacity(0.98),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 500,
        height: 450,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              estacion != null ? 'Reseñas de "${estacion!.nombre}"' : 'Reseñas',
              style: AppTextStyles.title.copyWith(color: AppColors.purplePrimary),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: comentarios.isEmpty
                  ? Text('No hay reseñas aún.', style: AppTextStyles.subtitle.copyWith(color: AppColors.hintColor))
                  : Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                        itemCount: comentarios.length,
                        separatorBuilder: (_, __) => Divider(height: 16, color: AppColors.purpleAccent.withOpacity(0.18)),
                        itemBuilder: (context, idx) {
                          final c = comentarios[idx];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.purpleAccent.withOpacity(0.7),
                              child: Text(
                                c.nombreUsuario != null && c.nombreUsuario!.isNotEmpty ? c.nombreUsuario![0] : '?',
                                style: TextStyle(color: AppColors.textColor),
                              ),
                            ),
                            title: Text(c.nombreUsuario ?? '', style: AppTextStyles.cardContent),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StarRating(c.calificacion.toDouble()),
                                const SizedBox(height: 2),
                                Text(
                                  c.comentario,
                                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textColor),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '${c.fecha.day}/${c.fecha.month}/${c.fecha.year}',
                              style: AppTextStyles.subtitle.copyWith(fontSize: 11, color: AppColors.hintColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          );
                        },
                      ),
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.hintColor,
                  textStyle: AppTextStyles.subtitle,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

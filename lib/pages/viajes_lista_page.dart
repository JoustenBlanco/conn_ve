import 'package:flutter/material.dart';
import '../services/rutas_service.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import 'viajes_rutas_page.dart';

class ViajesListaPage extends StatefulWidget {
  const ViajesListaPage({super.key});

  @override
  State<ViajesListaPage> createState() => _ViajesListaPageState();
}

class _ViajesListaPageState extends State<ViajesListaPage> {
  late Future<List<Ruta>> _rutasFuture;

  // Filtros de ordenamiento
  String _filtro = 'Fecha más cercana';
  final List<String> _filtros = [
    'Fecha más cercana',
    'Menos kilómetros',
  ];

  @override
  void initState() {
    super.initState();
    _rutasFuture = RutasService.obtenerRutasUsuarioActual();
  }

  void _abrirRuta(Ruta ruta) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ViajesRutasPage(ruta: ruta),
      ),
    );
    setState(() {
      _rutasFuture = RutasService.obtenerRutasUsuarioActual();
    });
  }

  void _nuevaRuta() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ViajesRutasPage(),
      ),
    );
    setState(() {
      _rutasFuture = RutasService.obtenerRutasUsuarioActual();
    });
  }

  void _eliminarRuta(Ruta ruta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard.withOpacity(0.98),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Eliminar ruta', style: AppTextStyles.title.copyWith(color: AppColors.purplePrimary)),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta ruta? Esta acción no se puede deshacer.',
          style: AppTextStyles.cardContent.copyWith(color: AppColors.hintColor),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.hintColor,
              textStyle: AppTextStyles.subtitle,
            ),
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              textStyle: AppTextStyles.subtitle.copyWith(color: Colors.redAccent),
            ),
            child: const Text('Eliminar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await RutasService.eliminarRuta(ruta.id);
      setState(() {
        _rutasFuture = RutasService.obtenerRutasUsuarioActual();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.darkCard.withOpacity(0.98),
          elevation: 0,
          title: Text('Mis Rutas', style: AppTextStyles.title),
          centerTitle: true,
          shadowColor: AppColors.purplePrimary.withOpacity(0.12),
          iconTheme: const IconThemeData(color: AppColors.purpleAccent),
          automaticallyImplyLeading: false, // <-- elimina el botón de ir atrás
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // El gradiente ya está aplicado en el contenedor principal
          child: Column(
            children: [
              // Filtros de ordenamiento
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
                          value: _filtro,
                          dropdownColor: AppColors.darkCard,
                          style: AppTextStyles.subtitle.copyWith(color: AppColors.textColor),
                          iconEnabledColor: AppColors.purpleAccent,
                          borderRadius: BorderRadius.circular(18),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _filtros.map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _filtro = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Ruta>>(
                  future: _rutasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error al cargar rutas'));
                    }
                    final rutas = snapshot.data ?? [];
                    if (rutas.isEmpty) {
                      return Center(
                        child: Text(
                          'No tienes rutas guardadas.\n¡Crea una nueva!',
                          style: AppTextStyles.subtitle,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // Ordenar rutas según filtro
                    List<Ruta> rutasOrdenadas = List.from(rutas);
                    if (_filtro == 'Fecha más cercana') {
                      rutasOrdenadas.sort((a, b) => a.fechaProgramada.compareTo(b.fechaProgramada));
                    } else if (_filtro == 'Menos kilómetros') {
                      rutasOrdenadas.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      itemCount: rutasOrdenadas.length,
                      itemBuilder: (context, idx) {
                        final ruta = rutasOrdenadas[idx];
                        return Container(
                          decoration: AppDecorations.card(opacity: 0.98),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Container(
                              decoration: AppDecorations.iconCircle,
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 28),
                            ),
                            title: Text(
                              '${ruta.origenNombre} → ${ruta.destinoNombre}',
                              style: AppTextStyles.cardContent,
                            ),
                            subtitle: Text(
                              'Fecha: ${ruta.fechaProgramada.day}/${ruta.fechaProgramada.month}/${ruta.fechaProgramada.year}\n'
                              'Distancia: ${ruta.distanciaKm.toStringAsFixed(1)} km',
                              style: AppTextStyles.cardContent.copyWith(fontSize: 13, color: AppColors.hintColor),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.purplePrimary),
                                  tooltip: 'Eliminar',
                                  onPressed: () => _eliminarRuta(ruta),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.purpleAccent),
                              ],
                            ),
                            onTap: () => _abrirRuta(ruta),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.purplePrimary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nueva ruta', style: TextStyle(color: Colors.white)),
          onPressed: _nuevaRuta,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

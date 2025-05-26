import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../shared/styles/app_text_styles.dart';
// Importar el modelo de estación
import '../services/estaciones_service.dart';

class StyledMap extends StatelessWidget {
  final bool loading;
  final String? error;
  final PositionData? position;
  final void Function(GoogleMapController)? onMapCreated;
  final List<EstacionCarga> estaciones;
  final Set<Polyline>? polylines;
  final Set<Marker>? customMarkers; // NUEVO

  const StyledMap({
    Key? key,
    required this.loading,
    required this.error,
    required this.position,
    required this.onMapCreated,
    this.estaciones = const [],
    this.polylines,
    this.customMarkers, // NUEVO
  }) : super(key: key);

  void _showEstacionDialog(BuildContext context, EstacionCarga estacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          estacion.nombre,
          style: AppTextStyles.title,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enchufe: ${estacion.tipoEnchufe ?? "N/A"}', style: AppTextStyles.cardContent),
              Text('Tarifa: ${estacion.tarifa ?? "N/A"}', style: AppTextStyles.cardContent),
              Text('Potencia: ${estacion.potenciaKw != null ? "${estacion.potenciaKw} kW" : "N/A"}', style: AppTextStyles.cardContent),
              Text('Disponible: ${estacion.disponible ? "Sí" : "No"}', style: AppTextStyles.cardContent),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              textStyle: AppTextStyles.subtitle,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 500,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          error!,
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                    )
                  : position == null
                      ? Center(
                          child: Text(
                            'Ubicación no disponible',
                            style: AppTextStyles.subtitle,
                          ),
                        )
                      : GoogleMap(
                          onMapCreated: onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              position!.latitude,
                              position!.longitude,
                            ),
                            zoom: 16,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          markers: customMarkers ??
                              {
                                // Marcador de usuario
                                Marker(
                                  markerId: const MarkerId('user_location'),
                                  position: LatLng(
                                    position!.latitude,
                                    position!.longitude,
                                  ),
                                  infoWindow: const InfoWindow(
                                    title: 'Tu ubicación',
                                  ),
                                ),
                                // Marcadores de estaciones con onTap para mostrar toda la info
                                ...estaciones.map((e) => Marker(
                                  markerId: MarkerId('estacion_${e.id}'),
                                  position: LatLng(e.latitud, e.longitud),
                                  infoWindow: InfoWindow(
                                    title: e.nombre,
                                    snippet: 'Toca para ver detalles',
                                  ),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                                  onTap: () {
                                    _showEstacionDialog(context, e);
                                  },
                                )),
                              },
                          polylines: polylines ?? {},
                        ),
        ),
      ),
    );
  }
}

class PositionData {
  final double latitude;
  final double longitude;
  const PositionData({required this.latitude, required this.longitude});
}

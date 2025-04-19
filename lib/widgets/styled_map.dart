import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../shared/styles/app_text_styles.dart';

class StyledMap extends StatelessWidget {
  final bool loading;
  final String? error;
  final PositionData? position;
  final void Function(GoogleMapController)? onMapCreated;

  const StyledMap({
    Key? key,
    required this.loading,
    required this.error,
    required this.position,
    required this.onMapCreated,
  }) : super(key: key);

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
                          markers: {
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
                          },
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

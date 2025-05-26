import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import '../widgets/styled_map.dart';
import '../services/estaciones_service.dart';

class ViajesRutasPage extends StatefulWidget {
  const ViajesRutasPage({super.key});

  @override
  State<ViajesRutasPage> createState() => _ViajesRutasPageState();
}

class _ViajesRutasPageState extends State<ViajesRutasPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _origenController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _autonomiaManualController =
      TextEditingController();
  double _autonomia = 200;
  bool _usarSlider = true;
  bool _mostrarResultado = false;
  String? _tipoCargador; // 'rapido' o 'estandar'
  Set<String> _marcasCompatibles = {};

  Position? _currentPosition;
  bool _loadingMapa = true;
  String? _errorMapa;
  GoogleMapController? _mapController;
  List<EstacionCarga> _estacionesSugeridas = []; // Puedes poblar esto según tu lógica

  Set<Polyline> _polylines = {};

  // Reemplaza con tu propia clave de API de Google Directions
  static const String _googleApiKey = 'AIzaSyB9wb0w7fj8PPxWUpa_ptP4IrQU9Hgcp-A';

  // Copia el estilo de mapa de mapa_page
  static const String _mapStyle = '''
  [
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        { "color": "#4B176A" }
      ]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [
        { "color": "#18181A" }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        { "color": "#7B1FA2" },
        { "lightness": -20 }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [
        { "color": "#2A1946" }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [
        { "color": "#B388FF" }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        { "visibility": "on" },
        { "color": "#23232B" },
        { "weight": 2 },
        { "gamma": 0.84 }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        { "color": "#ffffff" }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        { "weight": 0.6 },
        { "color": "#7B1FA2" }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [
        { "color": "#23232B" }
      ]
    }
  ]
  ''';

  // Ejemplo de opciones de autocomplete
  final List<String> _sugerenciasDirecciones = [
    'San José, Costa Rica',
    'Heredia, Costa Rica',
    'Cartago, Costa Rica',
    'Alajuela, Costa Rica',
    'Limón, Costa Rica',
  ];

  @override
  void dispose() {
    _origenController.dispose();
    _destinoController.dispose();
    _autonomiaManualController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
    // Si tienes lógica para sugerir estaciones, puedes cargar aquí
    //_fetchEstacionesSugeridas();
  }

  Future<void> _initLocation() async {
    setState(() {
      _loadingMapa = true;
      _errorMapa = null;
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _loadingMapa = false;
      });
    } catch (e) {
      setState(() {
        _errorMapa = 'Error obteniendo ubicación: ${e.toString()}';
        _loadingMapa = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.setMapStyle(_mapStyle);
  }

  // Utilidad para obtener coordenadas desde una dirección usando Geocoding API
  Future<LatLng?> _getLatLngFromAddress(String address) async {
    if (address.isEmpty) return null;
    if (address.toLowerCase() == 'ubicación actual' && _currentPosition != null) {
      return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    }
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_googleApiKey';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    print('Geocoding response for "$address": $data'); // DEBUG

    // Manejo de errores de autorización
    if (data['status'] == 'REQUEST_DENIED') {
      final errorMsg = data['error_message'] ?? 'API Key no autorizada para Geocoding.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de Google Maps: $errorMsg')),
      );
      print('ERROR: $errorMsg');
      return null;
    }

    if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
      final location = data['results'][0]['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo encontrar la dirección: "$address"')),
      );
    }
    return null;
  }

  // Utilidad para obtener la ruta entre dos puntos usando Directions API
  Future<List<LatLng>> _getRouteCoordinates(LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_googleApiKey';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    if (data['status'] == 'OK') {
      final points = data['routes'][0]['overview_polyline']['points'];
      return _decodePolyline(points);
    }
    return [];
  }

  // Decodifica la polyline de Google Directions
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  // Variables para guardar la posición del destino
  LatLng? _destinoLatLng;

  Future<void> _planificarRuta() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _mostrarResultado = true;
      _polylines = {};
      _destinoLatLng = null;
    });

    String origen = _origenController.text.trim();
    String destino = _destinoController.text.trim();

    print('Valor actual _origenController: "$origen"');
    print('Valor actual _destinoController: "$destino"');

    if (origen.isEmpty || destino.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa origen y destino')),
      );
      return;
    }

    LatLng? origenLatLng = await _getLatLngFromAddress(origen);
    LatLng? destinoLatLng = await _getLatLngFromAddress(destino);

    print('OrigenLatLng: $origenLatLng');
    print('DestinoLatLng: $destinoLatLng');

    if (origenLatLng == null || destinoLatLng == null) {
      print('No se pudo obtener coordenadas de origen o destino');
      return;
    }

    final routeCoords = await _getRouteCoordinates(origenLatLng, destinoLatLng);

    print('Cantidad de puntos en la ruta: ${routeCoords.length}');
    if (routeCoords.isEmpty) {
      print('No se recibieron puntos para la polyline');
    }

    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('ruta'),
          color: AppColors.purpleAccent,
          width: 6,
          points: routeCoords,
        ),
      };
      _destinoLatLng = destinoLatLng; // Guarda la posición del destino
      print('Polylines seteadas: ${_polylines.length}');
    });
  }

  Set<Marker> _buildMarkers(PositionData? position) {
    final markers = <Marker>{};

    // Marcador de usuario
    

    // Marcadores de estaciones sugeridas
    for (final e in _estacionesSugeridas) {
      markers.add(
        Marker(
          markerId: MarkerId('estacion_${e.id}'),
          position: LatLng(e.latitud, e.longitud),
          infoWindow: InfoWindow(
            title: e.nombre,
            snippet: 'Toca para ver detalles',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          onTap: () {
            // Puedes mostrar el diálogo si lo deseas
          },
        ),
      );
    }

    // Marcador de destino (si existe)
    if (_destinoLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destino'),
          position: _destinoLatLng!,
          infoWindow: const InfoWindow(title: 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(text, style: AppTextStyles.title.copyWith(fontSize: 22)),
    );
  }

  Widget _buildOrigenDestino() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Origen y Destino'),
        Row(
          children: [
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return _sugerenciasDirecciones.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                fieldViewBuilder: (
                  context,
                  controller,
                  focusNode,
                  onEditingComplete,
                ) {
                  // Sincroniza el controlador de Autocomplete con el principal
                  controller.text = _origenController.text;
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                  controller.addListener(() {
                    if (_origenController.text != controller.text) {
                      _origenController.text = controller.text;
                    }
                  });
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: AppColors.purpleAccent,
                      ),
                      labelText: 'Origen',
                      hintText: 'Ingrese origen',
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.my_location,
                          color: AppColors.purplePrimary,
                        ),
                        tooltip: 'Usar ubicación actual',
                        onPressed: () {
                          controller.text = 'Ubicación actual';
                          _origenController.text = 'Ubicación actual';
                        },
                      ),
                    ),
                  );
                },
                onSelected: (String selection) {
                  _origenController.text = selection;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return _sugerenciasDirecciones.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          fieldViewBuilder: (
            context,
            controller,
            focusNode,
            onEditingComplete,
          ) {
            // Sincroniza el controlador de Autocomplete con el principal
            controller.text = _destinoController.text;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
            controller.addListener(() {
              if (_destinoController.text != controller.text) {
                _destinoController.text = controller.text;
              }
            });
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: AppColors.textColor),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.flag, color: AppColors.purpleAccent),
                labelText: 'Destino',
                hintText: 'Ingrese destino',
              ),
            );
          },
          onSelected: (String selection) {
            _destinoController.text = selection;
          },
        ),
      ],
    );
  }

  Widget _buildAutonomia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Autonomía del Vehículo'),
        Row(
          children: [
            Expanded(
              child:
                  _usarSlider
                      ? Column(
                        children: [
                          Slider.adaptive(
                            value: _autonomia,
                            min: 50,
                            max: 600,
                            divisions: 55,
                            label: '${_autonomia.round()} km',
                            onChanged: (value) {
                              setState(() {
                                _autonomia = value;
                              });
                            },
                          ),
                          Text(
                            '${_autonomia.round()} km',
                            style: AppTextStyles.cardContent,
                          ),
                        ],
                      )
                      : TextFormField(
                        controller: _autonomiaManualController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textColor),
                        decoration: const InputDecoration(
                          labelText: 'Autonomía (km)',
                          hintText: 'Ej: 320',
                        ),
                        onChanged: (val) {
                          double? parsed = double.tryParse(val);
                          if (parsed != null) {
                            setState(() {
                              _autonomia = parsed;
                            });
                          }
                        },
                      ),
            ),
            IconButton(
              icon: Icon(
                _usarSlider ? Icons.edit : Icons.tune,
                color: AppColors.purpleAccent,
              ),
              onPressed: () {
                setState(() {
                  _usarSlider = !_usarSlider;
                  if (!_usarSlider) {
                    _autonomiaManualController.text =
                        _autonomia.round().toString();
                  }
                });
              },
              tooltip: _usarSlider ? 'Ingresar a mano' : 'Usar slider',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferenciasCarga() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Preferencias de carga'),
        Wrap(
          spacing: 10,
          children: [
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.flash_on, color: AppColors.purpleAccent),
                  Text(' Rápido'),
                ],
              ),
              selected: _tipoCargador == 'rapido',
              onSelected: (selected) {
                setState(() {
                  _tipoCargador = selected ? 'rapido' : null;
                });
              },
              selectedColor: AppColors.purplePrimary,
            ),
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.electrical_services,
                    color: AppColors.purpleAccent,
                  ),
                  Text(' Estándar'),
                ],
              ),
              selected: _tipoCargador == 'estandar',
              onSelected: (selected) {
                setState(() {
                  _tipoCargador = selected ? 'estandar' : null;
                });
              },
              selectedColor: AppColors.purplePrimary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Marcas compatibles:', style: AppTextStyles.subtitle),
        Wrap(
          spacing: 10,
          children: [
            FilterChip(
              label: const Text('Tesla'),
              selected: _marcasCompatibles.contains('Tesla'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _marcasCompatibles.add('Tesla');
                  } else {
                    _marcasCompatibles.remove('Tesla');
                  }
                });
              },
              selectedColor: AppColors.purplePrimary,
            ),
            FilterChip(
              label: const Text('ChargePoint'),
              selected: _marcasCompatibles.contains('ChargePoint'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _marcasCompatibles.add('ChargePoint');
                  } else {
                    _marcasCompatibles.remove('ChargePoint');
                  }
                });
              },
              selectedColor: AppColors.purplePrimary,
            ),
            FilterChip(
              label: const Text('Otro...'),
              selected: _marcasCompatibles.contains('Otro'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _marcasCompatibles.add('Otro');
                  } else {
                    _marcasCompatibles.remove('Otro');
                  }
                });
              },
              selectedColor: AppColors.purplePrimary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultado() {
    if (!_mostrarResultado) return const SizedBox.shrink();
    print('Polylines enviadas a StyledMap: ${_polylines.length}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Resultado: Vista previa de la ruta'),
        Container(
          height: 220,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: StyledMap(
            loading: _loadingMapa,
            error: _errorMapa,
            position: _currentPosition == null
                ? null
                : PositionData(
                    latitude: _currentPosition!.latitude,
                    longitude: _currentPosition!.longitude,
                  ),
            onMapCreated: _onMapCreated,
            estaciones: _estacionesSugeridas,
            polylines: _polylines,
            // Pasa los marcadores personalizados
            customMarkers: _buildMarkers(_currentPosition == null
                ? null
                : PositionData(
                    latitude: _currentPosition!.latitude,
                    longitude: _currentPosition!.longitude,
                  )),
          ),
        ),
        const SizedBox(height: 8),
        Text('Estaciones sugeridas:', style: AppTextStyles.subtitle),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2, // Cambia por el número real de estaciones sugeridas
          itemBuilder: (context, idx) {
            return Card(
              color: AppColors.darkCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(
                  Icons.ev_station,
                  color: AppColors.purpleAccent,
                ),
                title: Text(
                  'Estación ${idx + 1}',
                  style: AppTextStyles.cardContent,
                ),
                subtitle: const Text('Distancia al desvío: 3.2 km'),
                trailing: IconButton(
                  icon: const Icon(Icons.share, color: AppColors.purpleAccent),
                  onPressed: () {},
                  tooltip: 'Compartir',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purplePrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.save),
              label: const Text('Guardar ruta'),
              onPressed: () {},
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.share),
              label: const Text('Compartir'),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        title: Text('Planificar Ruta', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.backgroundGradient,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: AppDecorations.card(opacity: 0.96),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: _buildOrigenDestino(),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: AppDecorations.card(opacity: 0.96),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: _buildAutonomia(),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: AppDecorations.card(opacity: 0.96),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: _buildPreferenciasCarga(),
                  ),
                  if (_mostrarResultado)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: AppDecorations.card(opacity: 0.98),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: _buildResultado(),
                    ),
                  const SizedBox(height: 80), // Espacio para el botón flotante
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purplePrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              textStyle: AppTextStyles.title.copyWith(fontSize: 20),
              elevation: 8,
              shadowColor: AppColors.purpleAccent.withOpacity(0.3),
            ),
            icon: const Icon(Icons.alt_route, size: 30),
            label: const Text('Planificar Ruta'),
            onPressed: _planificarRuta,
          ),
        ),
      ),
    );
  }
}

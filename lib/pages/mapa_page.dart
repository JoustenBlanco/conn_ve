import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import '../shared/styles/app_constants.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/styled_map.dart';
import '../services/estaciones_service.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _loading = true;
  String? _error;
  List<EstacionCarga> _estaciones = [];
  List<EstacionCarga> _filteredEstaciones = [];
  final TextEditingController _searchController = TextEditingController();

  String? _selectedTipoEnchufe;
  bool? _soloDisponibles;
  RangeValues? _potenciaRange;

  List<String> get _tiposEnchufeDisponibles =>
      _estaciones.map((e) => e.tipoEnchufe ?? "N/A").toSet().toList();

  int get _minPotencia => _estaciones.isEmpty
      ? 0
      : _estaciones
          .where((e) => e.potenciaKw != null)
          .map((e) => e.potenciaKw!)
          .fold<int>(9999, (min, p) => p < min ? p : min);

  int get _maxPotencia => _estaciones.isEmpty
      ? 0
      : _estaciones
          .where((e) => e.potenciaKw != null)
          .map((e) => e.potenciaKw!)
          .fold<int>(0, (max, p) => p > max ? p : max);

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

  @override
  void initState() {
    super.initState();
    _initLocation();
    _fetchEstaciones();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEstaciones() async {
    try {
      final estaciones = await EstacionesService.obtenerEstaciones();
      setState(() {
        _estaciones = estaciones;
        _filteredEstaciones = estaciones;
        if (estaciones.any((e) => e.potenciaKw != null)) {
          _potenciaRange = RangeValues(
            _minPotencia.toDouble(),
            _maxPotencia.toDouble(),
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando estaciones: ${e.toString()}';
      });
    }
  }

  void _onSearchChanged() {
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEstaciones = _estaciones.where((e) {
        final matchesSearch = e.nombre.toLowerCase().contains(query) ||
            (e.tipoEnchufe?.toLowerCase().contains(query) ?? false) ||
            (e.tarifa?.toString().contains(query) ?? false) ||
            (e.potenciaKw?.toString().contains(query) ?? false);

        final matchesTipo = _selectedTipoEnchufe == null ||
            _selectedTipoEnchufe == "Todos" ||
            (e.tipoEnchufe ?? "N/A") == _selectedTipoEnchufe;

        final matchesDisponibilidad = _soloDisponibles == null ||
            _soloDisponibles == false ||
            e.disponible == true;

        final matchesPotencia = _potenciaRange == null ||
            (e.potenciaKw != null &&
                e.potenciaKw! >= _potenciaRange!.start &&
                e.potenciaKw! <= _potenciaRange!.end);

        return matchesSearch && matchesTipo && matchesDisponibilidad && matchesPotencia;
      }).toList();
    });
  }

  void _abrirModalFiltros() async {
    final tipos = ["Todos", ..._tiposEnchufeDisponibles.where((t) => t != "N/A")];
    final minPot = _minPotencia.toDouble();
    final maxPot = _maxPotencia.toDouble();
    RangeValues potenciaTemp = _potenciaRange ??
        RangeValues(minPot, maxPot);

    String? tipoTemp = _selectedTipoEnchufe ?? "Todos";
    bool soloDispTemp = _soloDisponibles ?? false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Filtros avanzados', style: AppTextStyles.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de enchufe
                Text('Tipo de enchufe', style: AppTextStyles.cardContent),
                DropdownButton<String>(
                  value: tipoTemp,
                  isExpanded: true,
                  items: tipos.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo, style: AppTextStyles.cardContent),
                    );
                  }).toList(),
                  onChanged: (value) {
                    tipoTemp = value;
                    // Forzar rebuild del dialog
                    (context as Element).markNeedsBuild();
                  },
                ),
                const SizedBox(height: 16),
                // Disponibilidad
                Row(
                  children: [
                    Checkbox(
                      value: soloDispTemp,
                      onChanged: (val) {
                        soloDispTemp = val ?? false;
                        (context as Element).markNeedsBuild();
                      },
                    ),
                    Text('Solo disponibles', style: AppTextStyles.cardContent),
                  ],
                ),
                const SizedBox(height: 16),
                // Potencia
                if (_potenciaRange != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Potencia (kW)', style: AppTextStyles.cardContent),
                      RangeSlider(
                        values: potenciaTemp,
                        min: minPot,
                        max: maxPot,
                        divisions: (maxPot - minPot).toInt() > 0 ? (maxPot - minPot).toInt() : 1,
                        labels: RangeLabels(
                          potenciaTemp.start.round().toString(),
                          potenciaTemp.end.round().toString(),
                        ),
                        onChanged: (values) {
                          potenciaTemp = values;
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTipoEnchufe = tipoTemp == "Todos" ? null : tipoTemp;
                  _soloDisponibles = soloDispTemp;
                  _potenciaRange = potenciaTemp;
                });
                _aplicarFiltros();
                Navigator.of(context).pop();
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Solicitar permisos
      var status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() {
          _error = 'Permiso de ubicación denegado.';
          _loading = false;
        });
        return;
      }
      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            'Error obteniendo ubicación: '
            '\n${e.toString()}';
        _loading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.setMapStyle(_mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        title: Text('Mapa', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.backgroundGradient,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.cardPaddingHorizontal,
              vertical: AppConstants.cardPaddingVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                MapSearchBar(
                  controller: _searchController,
                  onChanged: (value) => _onSearchChanged(),
                  onFilterPressed: _abrirModalFiltros,
                ),
                const SizedBox(height: 24),
                StyledMap(
                  loading: _loading,
                  error: _error,
                  position: _currentPosition == null
                      ? null
                      : PositionData(
                          latitude: _currentPosition!.latitude,
                          longitude: _currentPosition!.longitude,
                        ),
                  onMapCreated: _onMapCreated,
                  estaciones: _filteredEstaciones,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

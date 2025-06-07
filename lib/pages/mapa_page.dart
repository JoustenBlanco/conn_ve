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
        { "color": "#2D1856" }
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
        { "color": "#8F5AFF" },
        { "lightness": -10 }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [
        { "color": "#221C3A" }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [
        { "color": "#D1B3FF" }
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
        { "color": "#F8F8FF" }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        { "weight": 0.6 },
        { "color": "#8F5AFF" }
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
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        { "color": "#B388FF" }
      ]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry",
      "stylers": [
        { "color": "#7B1FA2" }
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
          backgroundColor: AppColors.darkCard.withOpacity(0.98),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Filtros avanzados', style: AppTextStyles.title.copyWith(color: AppColors.purplePrimary)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de enchufe
                Text('Tipo de enchufe', style: AppTextStyles.cardContent.copyWith(color: AppColors.purpleAccent)),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkBg.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<String>(
                    value: tipoTemp,
                    isExpanded: true,
                    dropdownColor: AppColors.darkCard,
                    iconEnabledColor: AppColors.purplePrimary,
                    style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(16),
                    items: tipos.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo, style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      tipoTemp = value;
                      (context as Element).markNeedsBuild();
                    },
                  ),
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
                      activeColor: AppColors.purplePrimary,
                      checkColor: AppColors.textColor,
                      side: const BorderSide(color: AppColors.purpleAccent, width: 1.2),
                    ),
                    Text('Solo disponibles', style: AppTextStyles.cardContent.copyWith(color: AppColors.purpleAccent)),
                  ],
                ),
                const SizedBox(height: 16),
                // Potencia
                if (_potenciaRange != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Potencia (kW)', style: AppTextStyles.cardContent.copyWith(color: AppColors.purpleAccent)),
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
                        activeColor: AppColors.purplePrimary,
                        inactiveColor: AppColors.purpleAccent.withOpacity(0.3),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.hintColor,
                textStyle: AppTextStyles.subtitle,
              ),
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
    return Container(
      decoration: AppDecorations.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.darkCard.withOpacity(0.98),
          elevation: 0,
          title: Text('Mapa', style: AppTextStyles.title),
          centerTitle: true,
          shadowColor: AppColors.purplePrimary.withOpacity(0.12),
          iconTheme: const IconThemeData(color: AppColors.purpleAccent),
          automaticallyImplyLeading: false, // <-- elimina el botón de ir atrás
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // El gradiente ya está aplicado en el contenedor principal
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
                    // Puedes agregar color de fondo si quieres más efecto Spotify:
                    // backgroundColor: AppColors.darkCard.withOpacity(0.95),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: AppDecorations.card(opacity: 0.98),
                    child: StyledMap(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

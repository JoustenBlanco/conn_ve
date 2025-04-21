import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';

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

  void _planificarRuta() {
    FocusScope.of(context).unfocus();
    setState(() {
      _mostrarResultado = true;
    });
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
                  _origenController.text = controller.text;
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
            _destinoController.text = controller.text;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Resultado: Vista previa de la ruta'),
        Container(
          height: 180,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text('Mapa embebido aquí', style: AppTextStyles.subtitle),
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

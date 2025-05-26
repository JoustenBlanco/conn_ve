import 'package:supabase_flutter/supabase_flutter.dart';

class EstacionCarga {
  final int id;
  final String nombre;
  final double latitud;
  final double longitud;
  final num? tarifa;
  final String? tipoEnchufe;
  final int? potenciaKw;
  final bool disponible;

  EstacionCarga({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    this.tarifa,
    this.tipoEnchufe,
    this.potenciaKw,
    required this.disponible,
  });

  factory EstacionCarga.fromMap(Map<String, dynamic> map) {
    return EstacionCarga(
      id: map['id'] as int,
      nombre: map['nombre'] ?? '',
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      tarifa: map['tarifa'],
      tipoEnchufe: map['tipo_enchufe'],
      potenciaKw: map['potencia_kw'],
      disponible: map['disponible'] ?? true,
    );
  }
}

class EstacionesService {
  static Future<List<EstacionCarga>> obtenerEstaciones() async {
    try {
      final data = await Supabase.instance.client
          .from('estaciones_carga')
          .select()
          .then((value) => value as List<dynamic>);
      return data.map((e) => EstacionCarga.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error al obtener estaciones: $e');
    }
  }
}

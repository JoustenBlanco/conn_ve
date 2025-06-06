import 'package:supabase_flutter/supabase_flutter.dart';

class Ruta {
  final int id;
  final String idUsuario;
  final String origenNombre;
  final String destinoNombre;
  final double distanciaKm;
  final List<dynamic> estaciones;
  final int autonomiaKm;
  final String? preferenciaCarga;
  final List<String> marcasCompatibles;
  final DateTime fechaProgramada;
  final double origenLatitud;
  final double origenLongitud;
  final double destinoLatitud;
  final double destinoLongitud;

  Ruta({
    required this.id,
    required this.idUsuario,
    required this.origenNombre,
    required this.destinoNombre,
    required this.distanciaKm,
    required this.estaciones,
    required this.autonomiaKm,
    required this.preferenciaCarga,
    required this.marcasCompatibles,
    required this.fechaProgramada,
    required this.origenLatitud,
    required this.origenLongitud,
    required this.destinoLatitud,
    required this.destinoLongitud,
  });

  factory Ruta.fromMap(Map<String, dynamic> map) {
    return Ruta(
      id: map['id'] as int,
      idUsuario: map['id_usuario'] as String,
      origenNombre: map['origen_nombre'] ?? '',
      destinoNombre: map['destino_nombre'] ?? '',
      distanciaKm: (map['distancia_km'] as num?)?.toDouble() ?? 0.0,
      estaciones: map['estaciones'] as List<dynamic>? ?? [],
      autonomiaKm: map['autonomia_km'] ?? 0,
      preferenciaCarga: map['preferencia_carga'],
      marcasCompatibles: (map['marcas_compatibles'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      fechaProgramada: DateTime.parse(map['fecha_programada']),
      origenLatitud: (map['origen_latitud'] as num?)?.toDouble() ?? 0.0,
      origenLongitud: (map['origen_longitud'] as num?)?.toDouble() ?? 0.0,
      destinoLatitud: (map['destino_latitud'] as num?)?.toDouble() ?? 0.0,
      destinoLongitud: (map['destino_longitud'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RutasService {
  static final _supabase = Supabase.instance.client;

  static Future<void> guardarRuta({
    required String origenNombre,
    required String destinoNombre,
    required double distanciaKm,
    required List<dynamic> estaciones,
    required int autonomiaKm,
    required String? preferenciaCarga,
    required List<String> marcasCompatibles,
    required DateTime fechaProgramada,
    required double origenLatitud,
    required double origenLongitud,
    required double destinoLatitud,
    required double destinoLongitud,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _supabase.from('rutas').insert({
      'id_usuario': user.id,
      'origen_nombre': origenNombre,
      'destino_nombre': destinoNombre,
      'distancia_km': distanciaKm,
      'estaciones': estaciones,
      'autonomia_km': autonomiaKm,
      'preferencia_carga': preferenciaCarga,
      'marcas_compatibles': marcasCompatibles,
      'fecha_programada': fechaProgramada.toIso8601String(),
      'origen_latitud': origenLatitud,
      'origen_longitud': origenLongitud,
      'destino_latitud': destinoLatitud,
      'destino_longitud': destinoLongitud,
    });
  }

  static Future<List<Ruta>> obtenerRutasUsuarioActual() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    final data = await _supabase
        .from('rutas')
        .select()
        .eq('id_usuario', user.id)
        .order('fecha_programada', ascending: false);
    return (data as List)
        .map((e) => Ruta.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> eliminarRuta(int idRuta) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _supabase
        .from('rutas')
        .delete()
        .eq('id', idRuta)
        .eq('id_usuario', user.id);
  }
}

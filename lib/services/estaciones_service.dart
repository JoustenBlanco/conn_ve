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

class ComentarioEstacion {
  final int id;
  final String idUsuario;
  final int idEstacion;
  final String comentario;
  final int calificacion;
  final DateTime fecha;
  final String? nombreUsuario;

  ComentarioEstacion({
    required this.id,
    required this.idUsuario,
    required this.idEstacion,
    required this.comentario,
    required this.calificacion,
    required this.fecha,
    this.nombreUsuario,
  });

  factory ComentarioEstacion.fromMap(Map<String, dynamic> map) {
    return ComentarioEstacion(
      id: map['id'] as int,
      idUsuario: map['id_usuario'] as String,
      idEstacion: map['id_estacion'] as int,
      comentario: map['comentario'] ?? '',
      calificacion: map['calificacion'] ?? 0,
      fecha: DateTime.parse(map['fecha']),
      nombreUsuario: map['usuarios']?['nombre'],
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

  static Future<List<ComentarioEstacion>> obtenerComentariosDeEstacion(int idEstacion) async {
    final data = await Supabase.instance.client
        .from('comentarios_estaciones')
        .select('*, usuarios(nombre)')
        .eq('id_estacion', idEstacion)
        .order('fecha', ascending: false);
    return (data as List)
        .map((e) => ComentarioEstacion.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ComentarioEstacion?> obtenerComentarioUsuarioActual(int idEstacion) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    final data = await Supabase.instance.client
        .from('comentarios_estaciones')
        .select('*, usuarios(nombre)')
        .eq('id_estacion', idEstacion)
        .eq('id_usuario', user.id)
        .maybeSingle();
    if (data == null) return null;
    return ComentarioEstacion.fromMap(data as Map<String, dynamic>);
  }

  static Future<void> crearOActualizarComentario({
    required int idEstacion,
    required int calificacion,
    required String comentario,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final existe = await Supabase.instance.client
        .from('comentarios_estaciones')
        .select('id')
        .eq('id_estacion', idEstacion)
        .eq('id_usuario', user.id)
        .maybeSingle();
    if (existe != null) {
      await Supabase.instance.client
          .from('comentarios_estaciones')
          .update({
            'calificacion': calificacion,
            'comentario': comentario,
            'fecha': DateTime.now().toIso8601String(),
          })
          .eq('id', existe['id']);
    } else {
      await Supabase.instance.client
          .from('comentarios_estaciones')
          .insert({
            'id_estacion': idEstacion,
            'id_usuario': user.id,
            'calificacion': calificacion,
            'comentario': comentario,
            'fecha': DateTime.now().toIso8601String(),
          });
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class Grupo {
  final int id;
  final String nombre;
  final String descripcion;
  final String? ubicacion;
  final DateTime fechaCreacion;

  Grupo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.ubicacion,
    required this.fechaCreacion,
  });

  factory Grupo.fromMap(Map<String, dynamic> map) {
    return Grupo(
      id: map['id'] as int,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      ubicacion: map['ubicacion'],
      fechaCreacion: DateTime.parse(map['fecha_creacion']),
    );
  }
}

class GrupoMembresia {
  final int id;
  final String idUsuario;
  final int idGrupo;
  final String rol;

  GrupoMembresia({
    required this.id,
    required this.idUsuario,
    required this.idGrupo,
    required this.rol,
  });

  factory GrupoMembresia.fromMap(Map<String, dynamic> map) {
    return GrupoMembresia(
      id: map['id'] as int,
      idUsuario: map['id_usuario'] as String,
      idGrupo: map['id_grupo'] as int,
      rol: map['rol'] ?? 'miembro',
    );
  }
}

class GrupoMensaje {
  final int id;
  final int idGrupo;
  final String idUsuario;
  final String contenido;
  final DateTime fecha;
  final String? nombreUsuario;

  GrupoMensaje({
    required this.id,
    required this.idGrupo,
    required this.idUsuario,
    required this.contenido,
    required this.fecha,
    this.nombreUsuario,
  });

  factory GrupoMensaje.fromMap(Map<String, dynamic> map) {
    return GrupoMensaje(
      id: map['id'] as int,
      idGrupo: map['id_grupo'] as int,
      idUsuario: map['id_usuario'] as String,
      contenido: map['contenido'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      nombreUsuario: map['usuarios']?['nombre'],
    );
  }
}

class GruposService {
  static Future<List<Grupo>> obtenerGrupos() async {
    final data = await _supabase
        .from('grupos_locales')
        .select()
        .order('fecha_creacion', ascending: false);
    return (data as List).map((e) => Grupo.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Grupo>> obtenerGruposUsuarioActual() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    final data = await _supabase
        .from('usuarios_grupos')
        .select('grupos_locales(*)')
        .eq('id_usuario', user.id);
    return (data as List)
        .map((e) => Grupo.fromMap(e['grupos_locales'] as Map<String, dynamic>))
        .toList();
  }

  static Future<GrupoMembresia?> obtenerMembresiaUsuarioActual(int idGrupo) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    final data = await _supabase
        .from('usuarios_grupos')
        .select()
        .eq('id_usuario', user.id)
        .eq('id_grupo', idGrupo)
        .maybeSingle();
    if (data == null) return null;
    return GrupoMembresia.fromMap(data as Map<String, dynamic>);
  }

  static Future<void> crearGrupo({
    required String nombre,
    required String descripcion,
    String? ubicacion,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final data = await _supabase
        .from('grupos_locales')
        .insert({
          'nombre': nombre,
          'descripcion': descripcion,
          'ubicacion': ubicacion,
        })
        .select()
        .single();
    final idGrupo = data['id'] as int;
    // El creador es admin
    await _supabase.from('usuarios_grupos').insert({
      'id_usuario': user.id,
      'id_grupo': idGrupo,
      'rol': 'admin',
    });
  }

  static Future<void> unirseAGrupo(int idGrupo) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final existe = await _supabase
        .from('usuarios_grupos')
        .select('id')
        .eq('id_usuario', user.id)
        .eq('id_grupo', idGrupo)
        .maybeSingle();
    if (existe != null) return;
    await _supabase.from('usuarios_grupos').insert({
      'id_usuario': user.id,
      'id_grupo': idGrupo,
      'rol': 'miembro',
    });
  }

  static Future<void> salirDeGrupo(int idGrupo) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _supabase
        .from('usuarios_grupos')
        .delete()
        .eq('id_usuario', user.id)
        .eq('id_grupo', idGrupo);
  }

  static Future<void> eliminarGrupo(int idGrupo) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final membresia = await obtenerMembresiaUsuarioActual(idGrupo);
    if (membresia == null || membresia.rol != 'admin') throw Exception('Solo el admin puede eliminar el grupo');
    await _supabase.from('grupos_locales').delete().eq('id', idGrupo);
    await _supabase.from('usuarios_grupos').delete().eq('id_grupo', idGrupo);
    await _supabase.from('mensajes_grupo').delete().eq('id_grupo', idGrupo);
  }

  static Future<List<GrupoMensaje>> obtenerMensajesGrupo(int idGrupo) async {
    final data = await _supabase
        .from('mensajes_grupo')
        .select('*, usuarios(nombre)')
        .eq('id_grupo', idGrupo)
        .order('fecha');
    return (data as List)
        .map((e) => GrupoMensaje.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> enviarMensaje({
    required int idGrupo,
    required String contenido,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final membresia = await obtenerMembresiaUsuarioActual(idGrupo);
    if (membresia == null) throw Exception('Debes unirte al grupo para enviar mensajes');
    await _supabase.from('mensajes_grupo').insert({
      'id_grupo': idGrupo,
      'id_usuario': user.id,
      'contenido': contenido,
    });
  }
}

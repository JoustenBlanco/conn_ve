import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class ForoUsuario {
  final String id;
  final String nombre;
  final String? avatarUrl; // Si tienes avatar en la tabla usuarios, si no, null

  ForoUsuario({required this.id, required this.nombre, this.avatarUrl});

  factory ForoUsuario.fromMap(Map<String, dynamic> map) {
    return ForoUsuario(
      id: map['id'] as String,
      nombre: map['nombre'] ?? '',
      avatarUrl: null, // Cambia si tienes campo avatar en usuarios
    );
  }
}

class ForoComentario {
  final int id;
  final int idPost;
  final ForoUsuario usuario;
  final String contenido;
  final DateTime fecha;

  ForoComentario({
    required this.id,
    required this.idPost,
    required this.usuario,
    required this.contenido,
    required this.fecha,
  });

  factory ForoComentario.fromMap(Map<String, dynamic> map) {
    return ForoComentario(
      id: map['id'] as int,
      idPost: map['id_post'] as int,
      usuario: ForoUsuario.fromMap(map['usuarios'] as Map<String, dynamic>),
      contenido: map['contenido'] ?? '',
      fecha: DateTime.parse(map['fecha']),
    );
  }
}

class ForoPostWithUserAndComments {
  final int id;
  final ForoUsuario usuario;
  final String titulo;
  final String contenido;
  final DateTime fecha;
  final List<ForoComentario> comentarios;

  ForoPostWithUserAndComments({
    required this.id,
    required this.usuario,
    required this.titulo,
    required this.contenido,
    required this.fecha,
    required this.comentarios,
  });
}

class ForoService {
  // Trae posts con usuario y comentarios (y usuario de cada comentario)
  static Future<List<ForoPostWithUserAndComments>> obtenerPostsConUsuariosYComentarios() async {
    final postsData = await _supabase
        .from('foro_posts')
        .select('*, usuarios(*), foro_comentarios(*, usuarios(*))')
        .order('fecha', ascending: false);

    return (postsData as List)
        .map((p) {
          final comentarios = (p['foro_comentarios'] as List? ?? [])
              .map((c) => ForoComentario.fromMap(c as Map<String, dynamic>))
              .toList();
          return ForoPostWithUserAndComments(
            id: p['id'] as int,
            usuario: ForoUsuario.fromMap(p['usuarios'] as Map<String, dynamic>),
            titulo: p['titulo'] ?? '',
            contenido: p['contenido'] ?? '',
            fecha: DateTime.parse(p['fecha']),
            comentarios: comentarios,
          );
        })
        .toList();
  }

  static Future<void> crearPost({required String titulo, required String contenido}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _supabase.from('foro_posts').insert({
      'id_usuario': user.id,
      'titulo': titulo,
      'contenido': contenido,
    });
  }

  static Future<void> crearComentario({required int idPost, required String contenido}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _supabase.from('foro_comentarios').insert({
      'id_post': idPost,
      'id_usuario': user.id,
      'contenido': contenido,
    });
  }

  static Future<List<ForoComentario>> obtenerComentariosDePost(int idPost) async {
    final data = await _supabase
        .from('foro_comentarios')
        .select('*, usuarios(*)')
        .eq('id_post', idPost)
        .order('fecha');
    return (data as List)
        .map((c) => ForoComentario.fromMap(c as Map<String, dynamic>))
        .toList();
  }

  static Future<void> borrarPost(int idPost) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    // Solo permite borrar si el post es del usuario
    final post = await _supabase.from('foro_posts').select('id_usuario').eq('id', idPost).single();
    if (post['id_usuario'] != user.id) throw Exception('No autorizado');
    await _supabase.from('foro_posts').delete().eq('id', idPost);
  }

  static Future<void> borrarComentario(int idComentario) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    final comentario = await _supabase.from('foro_comentarios').select('id_usuario').eq('id', idComentario).single();
    if (comentario['id_usuario'] != user.id) throw Exception('No autorizado');
    await _supabase.from('foro_comentarios').delete().eq('id', idComentario);
  }
}

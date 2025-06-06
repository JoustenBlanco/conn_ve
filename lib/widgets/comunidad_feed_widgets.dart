import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import '../services/foro_service.dart';

class FeedForo extends StatefulWidget {
  const FeedForo({super.key});

  @override
  State<FeedForo> createState() => _FeedForoState();
}

class _FeedForoState extends State<FeedForo> {
  late Future<List<ForoPostWithUserAndComments>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = ForoService.obtenerPostsConUsuariosYComentarios();
  }

  Future<void> _refresh() async {
    setState(() {
      _postsFuture = ForoService.obtenerPostsConUsuariosYComentarios();
    });
  }

  void _showCrearPostDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CrearPostDialog(),
    );
    if (result == true) {
      _refresh();
    }
  }

  void _showComentariosDialog(ForoPostWithUserAndComments post) {
    showDialog(
      context: context,
      builder: (context) => ComentariosDialog(post: post),
    );
  }

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ForoPostWithUserAndComments>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No hay publicaciones aún.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: AppDecorations.card(opacity: 0.97),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: post.usuario.avatarUrl != null
                                ? NetworkImage(post.usuario.avatarUrl!)
                                : null,
                            child: post.usuario.avatarUrl == null
                                ? Text(post.usuario.nombre.isNotEmpty
                                    ? post.usuario.nombre[0]
                                    : '?')
                                : null,
                            radius: 24,
                          ),
                          title: Text(post.usuario.nombre, style: AppTextStyles.cardContent),
                          subtitle: Text(
                            _formatearFecha(post.fecha),
                            style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                          ),
                          trailing: post.usuario.id == _currentUserId
                              ? PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'borrar') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Confirmar'),
                                          content: const Text('¿Borrar esta publicación?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await ForoService.borrarPost(post.id);
                                        _refresh();
                                      }
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'borrar',
                                      child: Text('Borrar'),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        if (post.titulo.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                            child: Text(post.titulo, style: AppTextStyles.title.copyWith(fontSize: 18)),
                          ),
                        if (post.contenido.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            child: Text(post.contenido, style: AppTextStyles.subtitle.copyWith(color: AppColors.textColor)),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.comment_outlined, color: AppColors.purpleAccent),
                                onPressed: () => _showComentariosDialog(post),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCrearPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    // Formato simple: dd MMM yyyy, puedes mejorar con intl si lo deseas
    final meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}

// Diálogo para crear un nuevo post
class CrearPostDialog extends StatefulWidget {
  @override
  State<CrearPostDialog> createState() => _CrearPostDialogState();
}

class _CrearPostDialogState extends State<CrearPostDialog> {
  final _formKey = GlobalKey<FormState>();
  String _titulo = '';
  String _contenido = '';
  bool _loading = false;

  Future<void> _crearPost() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await ForoService.crearPost(titulo: _titulo, contenido: _contenido);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear post: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva publicación'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Título'),
              onSaved: (v) => _titulo = v?.trim() ?? '',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un título' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Contenido'),
              minLines: 2,
              maxLines: 5,
              onSaved: (v) => _contenido = v?.trim() ?? '',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese contenido' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _loading ? null : _crearPost,
          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Publicar'),
        ),
      ],
    );
  }
}

// Diálogo para ver y agregar comentarios
class ComentariosDialog extends StatefulWidget {
  final ForoPostWithUserAndComments post;
  const ComentariosDialog({required this.post});

  @override
  State<ComentariosDialog> createState() => _ComentariosDialogState();
}

class _ComentariosDialogState extends State<ComentariosDialog> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _agregarComentario() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ForoService.crearComentario(
        idPost: widget.post.id,
        contenido: texto,
      );
      _controller.clear();
      // Recargar comentarios
      final actualizado = await ForoService.obtenerComentariosDePost(widget.post.id);
      setState(() {
        widget.post.comentarios
          ..clear()
          ..addAll(actualizado);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al comentar: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> _borrarComentario(int idComentario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Borrar este comentario?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar')),
        ],
      ),
    );
    if (confirm == true) {
      await ForoService.borrarComentario(idComentario);
      final actualizado = await ForoService.obtenerComentariosDePost(widget.post.id);
      setState(() {
        widget.post.comentarios
          ..clear()
          ..addAll(actualizado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Comentarios'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.post.comentarios.isEmpty)
              const Text('No hay comentarios aún.'),
            if (widget.post.comentarios.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: widget.post.comentarios.length,
                  itemBuilder: (context, idx) {
                    final c = widget.post.comentarios[idx];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(c.usuario.nombre.isNotEmpty ? c.usuario.nombre[0] : '?'),
                      ),
                      title: Text(c.usuario.nombre),
                      subtitle: Text(c.contenido),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${c.fecha.day}/${c.fecha.month}/${c.fecha.year}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          if (c.usuario.id == _currentUserId)
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              tooltip: 'Borrar',
                              onPressed: () => _borrarComentario(c.id),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Agregar comentario',
                border: OutlineInputBorder(),
              ),
              enabled: !_loading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
        ElevatedButton(
          onPressed: _loading ? null : _agregarComentario,
          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Comentar'),
        ),
      ],
    );
  }
}

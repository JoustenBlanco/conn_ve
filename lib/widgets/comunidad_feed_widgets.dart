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
      backgroundColor: Colors.transparent,
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
                                  color: AppColors.darkCard.withOpacity(0.98),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  icon: const Icon(Icons.more_vert, color: AppColors.purpleAccent),
                                  onSelected: (value) async {
                                    if (value == 'borrar') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: AppColors.darkCard.withOpacity(0.98),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                          title: Text('Confirmar', style: AppTextStyles.title.copyWith(color: AppColors.purplePrimary)),
                                          content: Text('¿Borrar esta publicación?', style: AppTextStyles.cardContent.copyWith(color: AppColors.hintColor)),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: AppColors.hintColor,
                                                textStyle: AppTextStyles.subtitle,
                                              ),
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.redAccent,
                                                textStyle: AppTextStyles.subtitle.copyWith(color: Colors.redAccent),
                                              ),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Borrar'),
                                            ),
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
                                    PopupMenuItem(
                                      value: 'borrar',
                                      child: Text(
                                        'Borrar',
                                        style: AppTextStyles.subtitle.copyWith(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                            padding: const EdgeInsets.only(left: 18, right: 18, top: 6, bottom: 16),
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
        backgroundColor: AppColors.purplePrimary,
        foregroundColor: AppColors.textColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.add, size: 30),
        onPressed: _showCrearPostDialog,
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
      backgroundColor: AppColors.darkCard.withOpacity(0.98),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text('Nueva publicación', style: AppTextStyles.title.copyWith(color: AppColors.purplePrimary)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: AppTextStyles.subtitle.copyWith(color: AppColors.purpleAccent),
                filled: true,
                fillColor: AppColors.darkBg.withOpacity(0.85),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
              onSaved: (v) => _titulo = v?.trim() ?? '',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Contenido',
                labelStyle: AppTextStyles.subtitle.copyWith(color: AppColors.purpleAccent),
                filled: true,
                fillColor: AppColors.darkBg.withOpacity(0.85),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
              minLines: 2,
              maxLines: 5,
              onSaved: (v) => _contenido = v?.trim() ?? '',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese contenido' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.hintColor,
            textStyle: AppTextStyles.subtitle,
          ),
          onPressed: () => Navigator.of(context).pop(),
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
          onPressed: _loading ? null : _crearPost,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Publicar'),
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
      backgroundColor: AppColors.darkCard.withOpacity(0.98),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text('Comentarios', style: AppTextStyles.title.copyWith(color: AppColors.purplePrimary)),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.post.comentarios.isEmpty)
              Text('No hay comentarios aún.', style: AppTextStyles.subtitle.copyWith(color: AppColors.hintColor)),
            if (widget.post.comentarios.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: widget.post.comentarios.length,
                  itemBuilder: (context, idx) {
                    final c = widget.post.comentarios[idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.purpleAccent.withOpacity(0.7),
                                child: Text(
                                  c.usuario.nombre.isNotEmpty ? c.usuario.nombre[0] : '?',
                                  style: TextStyle(color: AppColors.textColor),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  c.usuario.nombre,
                                  style: AppTextStyles.cardContent,
                                ),
                              ),
                              Text(
                                '${c.fecha.day}/${c.fecha.month}/${c.fecha.year}',
                                style: AppTextStyles.subtitle.copyWith(fontSize: 11, color: AppColors.hintColor),
                              ),
                              if (c.usuario.id == _currentUserId)
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: AppColors.purplePrimary),
                                  tooltip: 'Borrar',
                                  onPressed: () => _borrarComentario(c.id),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2),
                            child: Text(
                              c.contenido,
                              style: AppTextStyles.subtitle.copyWith(color: AppColors.textColor),
                            ),
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
              decoration: InputDecoration(
                labelText: 'Agregar comentario',
                labelStyle: AppTextStyles.subtitle.copyWith(color: AppColors.purpleAccent),
                filled: true,
                fillColor: AppColors.darkBg.withOpacity(0.85),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              enabled: !_loading,
              style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.hintColor,
            textStyle: AppTextStyles.subtitle,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purplePrimary,
            foregroundColor: AppColors.textColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: AppTextStyles.subtitle.copyWith(color: AppColors.textColor),
            elevation: 0,
          ),
          onPressed: _loading ? null : _agregarComentario,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Comentar'),
        ),
      ],
    );
  }
}

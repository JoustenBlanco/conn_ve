import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import '../services/grupos_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GruposList extends StatefulWidget {
  const GruposList({super.key});

  @override
  State<GruposList> createState() => _GruposListState();
}

class _GruposListState extends State<GruposList> {
  late Future<List<Grupo>> _gruposFuture;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _gruposFuture = GruposService.obtenerGrupos();
  }

  Future<void> _refresh() async {
    setState(() {
      _gruposFuture = GruposService.obtenerGrupos();
    });
  }

  void _showCrearGrupoDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => CrearGrupoDialog(),
    );
    if (result == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar grupo por nombre',
                  hintStyle: AppTextStyles.subtitle.copyWith(color: AppColors.hintColor),
                  prefixIcon: const Icon(Icons.search, color: AppColors.purpleAccent),
                  filled: true,
                  fillColor: AppColors.darkCard.withOpacity(0.92),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
                onChanged: (val) => setState(() => _busqueda = val),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Grupo>>(
                future: _gruposFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final grupos = snapshot.data ?? [];
                  final gruposFiltrados = grupos.where((g) =>
                    g.nombre.toLowerCase().contains(_busqueda.trim().toLowerCase())
                  ).toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      itemCount: gruposFiltrados.length,
                      itemBuilder: (context, index) {
                        final grupo = gruposFiltrados[index];
                        return FutureBuilder<GrupoMembresia?>(
                          future: GruposService.obtenerMembresiaUsuarioActual(grupo.id),
                          builder: (context, snapMembresia) {
                            final membresia = snapMembresia.data;
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
                                        backgroundColor: AppColors.purplePrimary,
                                        child: Icon(Icons.group, color: AppColors.textColor),
                                      ),
                                      title: Text(grupo.nombre, style: AppTextStyles.cardContent.copyWith(fontSize: 18)),
                                      subtitle: Text(grupo.descripcion, style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: AppColors.textColor)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (membresia == null)
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: AppColors.purpleAccent,
                                                textStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              onPressed: () async {
                                                await GruposService.unirseAGrupo(grupo.id);
                                                _refresh();
                                              },
                                              child: const Text('Unirse'),
                                            ),
                                          if (membresia != null)
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: AppColors.purpleAccent,
                                                textStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              onPressed: () async {
                                                await GruposService.salirDeGrupo(grupo.id);
                                                _refresh();
                                              },
                                              child: const Text('Salir'),
                                            ),
                                          if (membresia?.rol == 'admin')
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: AppColors.purplePrimary),
                                              tooltip: 'Eliminar grupo',
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    backgroundColor: AppColors.darkCard.withOpacity(0.98),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                                    title: Text('Eliminar grupo', style: AppTextStyles.title.copyWith(color: AppColors.purplePrimary)),
                                                    content: Text('¿Seguro que deseas eliminar este grupo? Esta acción no se puede deshacer.', style: AppTextStyles.cardContent.copyWith(color: AppColors.hintColor)),
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
                                                        child: const Text('Eliminar'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await GruposService.eliminarGrupo(grupo.id);
                                                  _refresh();
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                      child: Text(
                                        grupo.ubicacion != null && grupo.ubicacion!.isNotEmpty
                                            ? 'Ubicación: ${grupo.ubicacion}'
                                            : '',
                                        style: AppTextStyles.subtitle.copyWith(color: AppColors.hintColor),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.purpleAccent,
                                              textStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            icon: const Icon(Icons.chat_bubble_outline),
                                            label: const Text('Chat'),
                                            onPressed: membresia == null
                                                ? null
                                                : () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => GrupoChatScreen(
                                                          grupo: grupo,
                                                          membresia: membresia,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 12,
          right: 18,
          child: FloatingActionButton.extended(
            backgroundColor: AppColors.purplePrimary,
            foregroundColor: AppColors.textColor,
            icon: const Icon(Icons.add),
            label: const Text('Crear grupo'),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onPressed: _showCrearGrupoDialog,
          ),
        ),
      ],
    );
  }
}

class CrearGrupoDialog extends StatefulWidget {
  @override
  State<CrearGrupoDialog> createState() => _CrearGrupoDialogState();
}

class _CrearGrupoDialogState extends State<CrearGrupoDialog> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _descripcion = '';
  String _ubicacion = '';
  bool _loading = false;

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await GruposService.crearGrupo(
        nombre: _nombre,
        descripcion: _descripcion,
        ubicacion: _ubicacion.isEmpty ? null : _ubicacion,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear grupo: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear grupo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre'),
              onSaved: (v) => _nombre = v?.trim() ?? '',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un nombre' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Descripción'),
              onSaved: (v) => _descripcion = v?.trim() ?? '',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese una descripción' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Ubicación (opcional)'),
              onSaved: (v) => _ubicacion = v?.trim() ?? '',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _loading ? null : _crear,
          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Crear'),
        ),
      ],
    );
  }
}

class GrupoChatScreen extends StatefulWidget {
  final Grupo grupo;
  final GrupoMembresia membresia;
  const GrupoChatScreen({super.key, required this.grupo, required this.membresia});

  @override
  State<GrupoChatScreen> createState() => _GrupoChatScreenState();
}

class _GrupoChatScreenState extends State<GrupoChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _loading = false;
  late Future<List<GrupoMensaje>> _mensajesFuture;

  @override
  void initState() {
    super.initState();
    _mensajesFuture = GruposService.obtenerMensajesGrupo(widget.grupo.id);
  }

  Future<void> _refresh() async {
    setState(() {
      _mensajesFuture = GruposService.obtenerMensajesGrupo(widget.grupo.id);
    });
  }

  Future<void> _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    setState(() => _loading = true);
    try {
      await GruposService.enviarMensaje(idGrupo: widget.grupo.id, contenido: texto);
      _controller.clear();
      await _refresh();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar mensaje: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkCard.withOpacity(0.98),
        elevation: 0,
        title: Text('Chat: ${widget.grupo.nombre}', style: AppTextStyles.title),
        centerTitle: true,
        shadowColor: AppColors.purplePrimary.withOpacity(0.12),
        iconTheme: const IconThemeData(color: AppColors.purpleAccent),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.backgroundGradient,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<GrupoMensaje>>(
                future: _mensajesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final mensajes = snapshot.data ?? [];
                  if (mensajes.isEmpty) {
                    return const Center(child: Text('No hay mensajes aún.'));
                  }
                  // Mostrar mensajes de más nuevos abajo (orden descendente)
                  final mensajesOrdenados = List<GrupoMensaje>.from(mensajes)..sort((a, b) => a.fecha.compareTo(b.fecha));
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    itemCount: mensajesOrdenados.length,
                    itemBuilder: (context, idx) {
                      final m = mensajesOrdenados[idx];
                      final isMe = m.idUsuario == userId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: ChatBubble(
                            text: m.contenido,
                            isMe: isMe,
                            nombre: m.nombreUsuario ?? '',
                            fecha: m.fecha,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkCard.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: AppTextStyles.subtitle.copyWith(color: AppColors.hintColor),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        enabled: !_loading && widget.membresia != null,
                        onSubmitted: (_) => _enviarMensaje(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: AppColors.purpleAccent,
                      foregroundColor: AppColors.textColor,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: _loading || widget.membresia == null ? null : _enviarMensaje,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String nombre;
  final DateTime fecha;
  const ChatBubble({super.key, required this.text, required this.isMe, required this.nombre, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      margin: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 40 : 0,
        right: isMe ? 0 : 40,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.purpleAccent.withOpacity(0.85) : AppColors.darkCard,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                nombre,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            text,
            style: AppTextStyles.subtitle.copyWith(
              color: isMe ? AppColors.darkBg : AppColors.textColor,
              fontSize: 16,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.subtitle.copyWith(
                color: isMe ? AppColors.darkCard : AppColors.hintColor,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

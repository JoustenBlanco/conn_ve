import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';

class GruposList extends StatelessWidget {
  const GruposList({super.key});

  @override
  Widget build(BuildContext context) {
    final grupos = [
      Grupo(
        nombre: 'Meteorología CR',
        miembros: 120,
        descripcion: 'Grupo para compartir datos y alertas meteorológicas en Costa Rica.',
      ),
      Grupo(
        nombre: 'Estaciones Davis',
        miembros: 80,
        descripcion: 'Usuarios de estaciones Davis, tips y soporte.',
      ),
      Grupo(
        nombre: 'Aficionados al clima',
        miembros: 200,
        descripcion: 'Espacio para quienes disfrutan observar el clima y sus fenómenos.',
      ),
    ];
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemCount: grupos.length,
            itemBuilder: (context, index) {
              final grupo = grupos[index];
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
                        subtitle: Text('${grupo.miembros} miembros', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                        trailing: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.purpleAccent,
                            textStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {},
                          child: const Text('Unirse'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        child: Text(
                          grupo.descripcion,
                          style: AppTextStyles.subtitle.copyWith(color: AppColors.textColor),
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
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GrupoChatScreen(nombre: grupo.nombre),
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
          ),
        ),
        Positioned(
          bottom: 12,
          right: 18,
          child: FloatingActionButton.extended(
            backgroundColor: AppColors.purplePrimary,
            foregroundColor: AppColors.textColor,
            icon: const Icon(Icons.add),
            label: const Text('Crear grupo'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.darkCard,
                  title: const Text('Crear grupo'),
                  content: const Text('Funcionalidad próximamente.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Grupo {
  final String nombre;
  final int miembros;
  final String descripcion;
  Grupo({required this.nombre, required this.miembros, required this.descripcion});
}

class GrupoChatScreen extends StatelessWidget {
  final String nombre;
  const GrupoChatScreen({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        title: Text('Chat: $nombre', style: AppTextStyles.title),
      ),
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ChatBubble(
                    text: '¡Bienvenidos al grupo!',
                    isMe: false,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ChatBubble(
                    text: '¡Hola a todos!',
                    isMe: true,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: AppColors.darkCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: AppTextStyles.subtitle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.purpleAccent,
                  onPressed: () {},
                  child: const Icon(Icons.send, color: AppColors.textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  const ChatBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.purpleAccent.withOpacity(0.85) : AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: AppTextStyles.subtitle.copyWith(
          color: isMe ? AppColors.darkBg : AppColors.textColor,
        ),
      ),
    );
  }
}

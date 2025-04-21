import 'package:flutter/material.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';

class FeedForo extends StatelessWidget {
  final List<Post> posts = const [
    Post(
      user: 'Ana Ruiz',
      avatarUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      date: '21 abr 2025',
      title: '¡Hola comunidad!',
      content: '¿Alguien sabe cómo calibrar una estación Davis Vantage Vue?',
      image: null,
    ),
    Post(
      user: 'Luis Blanco',
      avatarUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      date: '20 abr 2025',
      title: 'Fotos de mi estación',
      content: 'Así quedó mi instalación. ¿Qué opinan?',
      image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    ),
    Post(
      user: 'Carla Méndez',
      avatarUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
      date: '19 abr 2025',
      title: 'Problema con sensores',
      content: 'Mi sensor de humedad marca valores extraños. ¿Ideas?',
      image: null,
    ),
  ];

  const FeedForo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                    backgroundImage: NetworkImage(post.avatarUrl),
                    radius: 24,
                  ),
                  title: Text(post.user, style: AppTextStyles.cardContent),
                  subtitle: Text(post.date, style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
                ),
                if (post.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                    child: Text(post.title, style: AppTextStyles.title.copyWith(fontSize: 18)),
                  ),
                if (post.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: Text(post.content, style: AppTextStyles.subtitle.copyWith(color: AppColors.textColor)),
                  ),
                if (post.image != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(post.image!, fit: BoxFit.cover),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined, color: AppColors.purpleAccent),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined, color: AppColors.purpleAccent),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat, color: AppColors.purpleAccent),
                        onPressed: () {},
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
  }
}

class Post {
  final String user;
  final String avatarUrl;
  final String date;
  final String title;
  final String content;
  final String? image;
  const Post({
    required this.user,
    required this.avatarUrl,
    required this.date,
    required this.title,
    required this.content,
    this.image,
  });
}

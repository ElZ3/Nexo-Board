import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexoboard/features/auth/data/forum_service.dart';
import 'package:nexoboard/features/auth/data/user_service.dart';
import 'package:nexoboard/features/auth/data/models/forum_model.dart';

/// Vista de perfil público de otro usuario: muestra sus estadísticas
/// (foros activos, likes, dislikes) y permite acceder a sus foros.
class PublicProfilePage extends StatelessWidget {
  final String uid;
  final String? username;

  const PublicProfilePage({
    super.key,
    required this.uid,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final forumService = ForumService();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          username != null ? '@$username' : 'Perfil',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userService.streamUser(uid),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnap.hasData || !userSnap.data!.exists) {
            return const Center(
              child: Text('Usuario no encontrado.',
                  style: TextStyle(color: Colors.white54)),
            );
          }

          final userData = userSnap.data!.data() as Map<String, dynamic>;

          return StreamBuilder<List<ForumModel>>(
            stream: forumService.streamUserForums(uid),
            builder: (context, forumSnap) {
              final forums = forumSnap.data ?? [];

              int totalLikes = 0;
              int totalDislikes = 0;
              for (final f in forums) {
                totalLikes += f.likes;
                totalDislikes += f.dislikes;
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(userData),
                  const SizedBox(height: 24),
                  _buildStatsRow(
                    activeForums: forums.length,
                    likes: totalLikes,
                    dislikes: totalDislikes,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Foros Públicos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (forumSnap.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (forums.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Este usuario aún no tiene foros públicos.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ...forums.map((f) => _buildForumTile(context, f)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    final String photo = userData['profileImageUrl'] ?? '';
    final String name = userData['name'] ?? '';
    final String lastName = userData['lastName'] ?? '';
    final String description = userData['description'] ?? '';

    return Row(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: const Color(0xFF1E1E1E),
          backgroundImage: photo != '' ? NetworkImage(photo) : null,
          child: photo == ''
              ? const Icon(Icons.person, size: 42, color: Colors.white54)
              : null,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${userData['username'] ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$name $lastName'.trim(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildStatsRow({
    required int activeForums,
    required int likes,
    required int dislikes,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: LucideIcons.layoutGrid,
            label: 'Foros Activos',
            value: activeForums,
            color: Colors.deepPurpleAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: LucideIcons.thumbsUp,
            label: 'Likes',
            value: likes,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: LucideIcons.thumbsDown,
            label: 'Dislikes',
            value: dislikes,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildForumTile(BuildContext context, ForumModel forum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPublicForum(context, forum),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: forum.coverImageUrl == null
                        ? LinearGradient(
                            colors: [Colors.purple[600]!, Colors.blue[600]!])
                        : null,
                    image: forum.coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(forum.coverImageUrl!),
                            fit: BoxFit.cover)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        forum.hashtag,
                        style: TextStyle(
                          color: Colors.deepPurple[300],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        forum.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight,
                    color: Colors.white24, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPublicForum(BuildContext context, ForumModel forum) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (forum.coverImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    forum.coverImageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 14),
              Text(
                forum.hashtag,
                style: TextStyle(
                  color: Colors.deepPurple[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                forum.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                forum.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _inlineStat(LucideIcons.thumbsUp, forum.likes),
                  const SizedBox(width: 20),
                  _inlineStat(LucideIcons.thumbsDown, forum.dislikes),
                  const SizedBox(width: 20),
                  _inlineStat(LucideIcons.messageCircle, forum.commentCount),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _inlineStat(IconData icon, int value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 5),
        Text('$value', style: const TextStyle(color: Colors.white54)),
      ],
    );
  }
}

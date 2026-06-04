import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexoboard/core/utils/media_service.dart';
import 'package:nexoboard/features/auth/data/forum_service.dart';
import 'package:nexoboard/features/auth/data/models/comment_model.dart';
import 'package:nexoboard/features/auth/data/models/forum_model.dart';

class MyForumPage extends StatefulWidget {
  const MyForumPage({super.key});

  @override
  State<MyForumPage> createState() => _MyForumPageState();
}

class _MyForumPageState extends State<MyForumPage> {
  final ForumService _forumService = ForumService();
  final MediaService _mediaService = MediaService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  // ─────────────────── BUILD ───────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Mis Foros',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'CyGrotesk',
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ForumModel>>(
        stream: _forumService.streamUserForums(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar foros: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final forums = snapshot.data ?? [];

          if (forums.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDashboard(forums),
              const SizedBox(height: 24),
              const Text(
                'Tus Comunidades',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...forums.map((forum) => _buildForumTile(forum)),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────── ESTADO VACÍO ───────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messageSquare, color: Colors.grey[700], size: 64),
          const SizedBox(height: 16),
          Text(
            'Aún no has creado ningún foro',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera comunidad desde el menú principal',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ─────────────────── DASHBOARD DE ESTADÍSTICAS ───────────────────
  Widget _buildDashboard(List<ForumModel> forums) {
    int totalLikes = 0;
    int totalDislikes = 0;
    int totalComments = 0;
    for (final f in forums) {
      totalLikes += f.likes;
      totalDislikes += f.dislikes;
      totalComments += f.commentCount;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple[700]!, Colors.blue[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Interacciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${forums.length} foro${forums.length == 1 ? '' : 's'} activo${forums.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: LucideIcons.thumbsUp,
                label: 'Likes',
                value: totalLikes,
                color: Colors.greenAccent,
              ),
              _buildStatItem(
                icon: LucideIcons.thumbsDown,
                label: 'Dislikes',
                value: totalDislikes,
                color: Colors.redAccent,
              ),
              _buildStatItem(
                icon: LucideIcons.messageCircle,
                label: 'Comentarios',
                value: totalComments,
                color: Colors.amberAccent,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // ─────────────────── TILE DE FORO ───────────────────
  Widget _buildForumTile(ForumModel forum) {
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
          onTap: () => _showCommentsSheet(forum),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Miniatura
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: forum.coverImageUrl == null
                        ? LinearGradient(
                            colors: [
                              Colors.purple[600]!,
                              Colors.blue[600]!,
                            ],
                          )
                        : null,
                    image: forum.coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(forum.coverImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: forum.coverImageUrl == null
                      ? Center(
                          child: Text(
                            forum.hashtag.isNotEmpty
                                ? forum.hashtag[0].toUpperCase()
                                : '#',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                // Info
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _miniStat(LucideIcons.thumbsUp, '${forum.likes}'),
                          const SizedBox(width: 12),
                          _miniStat(
                              LucideIcons.thumbsDown, '${forum.dislikes}'),
                          const SizedBox(width: 12),
                          _miniStat(LucideIcons.messageCircle,
                              '${forum.commentCount}'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Botón editar
                IconButton(
                  icon: const Icon(LucideIcons.pencil,
                      color: Colors.white54, size: 20),
                  onPressed: () => _showEditSheet(forum),
                  tooltip: 'Editar foro',
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _miniStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 3),
        Text(value,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  // ─────────────────── BOTTOMSHEET: EDITAR FORO ───────────────────
  void _showEditSheet(ForumModel forum) {
    final titleController = TextEditingController(text: forum.title);
    final descController = TextEditingController(text: forum.description);
    File? selectedImage;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Editar Foro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hashtag (solo lectura)
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(text: forum.hashtag),
                      style: const TextStyle(color: Colors.white38),
                      decoration: InputDecoration(
                        labelText: 'Identificador (no editable)',
                        labelStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(LucideIcons.hash,
                            color: Colors.white24, size: 20),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Título
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        prefixIcon: const Icon(LucideIcons.type,
                            color: Colors.white38, size: 20),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Descripción
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: const Icon(LucideIcons.fileText,
                            color: Colors.white38, size: 20),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Imagen de portada
                    GestureDetector(
                      onTap: () async {
                        try {
                          final file =
                              await _mediaService.pickProfileImage();
                          if (file != null) {
                            setModalState(() => selectedImage = file);
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedImage != null
                                ? Colors.deepPurple
                                : Colors.grey[800]!,
                          ),
                        ),
                        child: Center(
                          child: selectedImage != null
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.checkCircle,
                                        color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('Nueva imagen seleccionada',
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.image,
                                        color: Colors.grey[600], size: 28),
                                    const SizedBox(height: 6),
                                    Text(
                                      forum.coverImageUrl != null
                                          ? 'Toca para cambiar la imagen'
                                          : 'Toca para añadir imagen',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Guardar
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              try {
                                await _forumService.updateForum(
                                  forumId: forum.id,
                                  title: titleController.text.trim(),
                                  description: descController.text.trim(),
                                  coverImage: selectedImage,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Foro actualizado con éxito'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error al guardar: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────── BOTTOMSHEET: COMENTARIOS (AUTORÍA) ───────────────────
  void _showCommentsSheet(ForumModel forum) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              forum.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Comentarios · ${forum.hashtag}',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white54),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),
                // Lista de comentarios en tiempo real
                Expanded(
                  child: StreamBuilder<List<CommentModel>>(
                    stream: _forumService.streamComments(forum.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final comments = snapshot.data ?? [];

                      if (comments.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.messageSquare,
                                  color: Colors.grey[700], size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Sin comentarios aún',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _buildCommentTile(forum, comment);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCommentTile(ForumModel forum, CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple[600],
              child: Text(
                comment.authorName.isNotEmpty
                    ? comment.authorName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            // Botón de eliminación (autoría del creador)
            IconButton(
              icon: const Icon(LucideIcons.trash2,
                  color: Colors.redAccent, size: 18),
              tooltip: 'Eliminar comentario',
              onPressed: () => _confirmDeleteComment(forum.id, comment),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteComment(String forumId, CommentModel comment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Eliminar Comentario',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Deseas eliminar el comentario de "${comment.authorName}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _forumService.deleteComment(
                  forumId: forumId,
                  commentId: comment.id,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comentario eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

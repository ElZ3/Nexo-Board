import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexoboard/features/auth/data/models/forum_model.dart';
import 'package:nexoboard/features/auth/presentation/widgets/forum_card_widget.dart';

/// Vista principal del Feed que renderiza todas las tarjetas de foros
class FeedPage extends StatefulWidget {
  final List<ForumModel> forums;
  final VoidCallback onCreateForum;

  const FeedPage({
    super.key,
    required this.forums,
    required this.onCreateForum,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  bool _showFab = true;
  final List<ForumModel> _forums = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController.addListener(_onScroll);
    _forums.addAll(widget.forums);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Ocultar FAB al hacer scroll hacia abajo
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFab) {
        setState(() {
          _showFab = false;
        });
        _fabAnimationController.forward();
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFab) {
        setState(() {
          _showFab = true;
        });
        _fabAnimationController.reverse();
      }
    }
  }

  void _handleForumLike(int index) {
    setState(() {
      _forums[index] = _forums[index].copyWith(
        likes: _forums[index].likes + 1,
      );
    });
    _showSnackbar('¡Te gustó este foro!');
  }

  void _handleForumDislike(int index) {
    setState(() {
      _forums[index] = _forums[index].copyWith(
        dislikes: _forums[index].dislikes + 1,
      );
    });
    _showSnackbar('Marcado como no útil');
  }

  void _handleForumComment(int index) {
    setState(() {
      _forums[index] = _forums[index].copyWith(
        commentCount: _forums[index].commentCount + 1,
      );
    });
    _showCommentBottomSheet(_forums[index]);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showCommentBottomSheet(ForumModel forum) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => _CommentBottomSheet(forum: forum),
    );
  }

  void _handleCreateForum() {
    widget.onCreateForum();
  }

  void _refreshFeed() async {
    // Simular carga de nuevos foros
    await Future.delayed(const Duration(seconds: 2));

    _showSnackbar('Feed actualizado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[950],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[900],
        title: const Text(
          'NexaBoard Feed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'CyGrotesk',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshFeed,
            icon: const Icon(LucideIcons.refreshCw),
            color: Colors.white,
          ).animate().fadeIn(duration: 300.ms),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.grey[800],
        color: Colors.deepPurple,
        onRefresh: () async {
          _refreshFeed();
          await Future.delayed(const Duration(seconds: 2));
        },
        child: _forums.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _forums.length,
                itemBuilder: (context, index) {
                  final forum = _forums[index];
                  return ForumCardWidget(
                    forum: forum,
                    onLike: () => _handleForumLike(index),
                    onDislike: () => _handleForumDislike(index),
                    onComment: () => _handleForumComment(index),
                    onTap: () {
                      _showForumDetail(forum);
                    },
                  ).animate().fadeIn(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                      );
                },
              ),
      ),
      floatingActionButton: Visibility(
        visible: _showFab,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _fabAnimationController,
              curve: Curves.easeInOut,
            ),
          ),
          child: FloatingActionButton.extended(
            onPressed: _handleCreateForum,
            backgroundColor: Colors.deepPurple[600],
            elevation: 8,
            icon: const Icon(LucideIcons.plus),
            label: const Text(
              'Crear Foro',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.inbox,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay foros disponibles',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea el primer foro de tu comunidad',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleCreateForum,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Crear Foro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[600],
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForumDetail(ForumModel forum) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => _ForumDetailBottomSheet(forum: forum),
    );
  }
}

/// Bottom Sheet para mostrar detalles completos del foro
class _ForumDetailBottomSheet extends StatelessWidget {
  final ForumModel forum;

  const _ForumDetailBottomSheet({required this.forum});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.9,
      minChildSize: 0.3,
      initialChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Título
                    Text(
                      forum.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'CyGrotesk',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Hashtag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[200]?.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        forum.hashtag,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Temática
                    _buildInfoRow('Temática', forum.topic),
                    const SizedBox(height: 12),
                    // Descripción completa
                    Text(
                      'Descripción',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      forum.description,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Estadísticas
                    _buildStatsRow(forum),
                    const SizedBox(height: 16),
                    // Publicaciones ancladas
                    if (forum.pinnedPosts.isNotEmpty) ...[
                      Text(
                        'Publicaciones Ancladas',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...forum.pinnedPosts.map((post) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  post.attachmentType == 'video'
                                      ? LucideIcons.video
                                      : LucideIcons.music,
                                  color: Colors.deepPurple,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    post.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ForumModel forum) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('Likes', forum.likes.toString()),
          _buildStatColumn('Dislikes', forum.dislikes.toString()),
          _buildStatColumn('Comentarios', forum.commentCount.toString()),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Bottom Sheet para comentar en un foro
class _CommentBottomSheet extends StatefulWidget {
  final ForumModel forum;

  const _CommentBottomSheet({required this.forum});

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  late TextEditingController _commentController;
  final List<String> _comments = [
    'Excelente foro, muy informativo',
    'Gracias por compartir esta información',
    'Me gustaría conocer más detalles sobre esto',
  ];

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.add(_commentController.text);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Comentarios (${widget.forum.commentCount})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.deepPurple[600],
                          child: Text(
                            'U${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usuario ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _comments[index],
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
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
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[800]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[600],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: _sendComment,
                    icon: const Icon(LucideIcons.send),
                    color: Colors.white,
                    iconSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

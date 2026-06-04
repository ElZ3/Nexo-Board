import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexoboard/features/auth/data/models/forum_model.dart';

/// Widget que renderiza una tarjeta de foro en el Feed
class ForumCardWidget extends StatefulWidget {
  final ForumModel forum;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onComment;
  final VoidCallback onTap;

  const ForumCardWidget({
    super.key,
    required this.forum,
    required this.onLike,
    required this.onDislike,
    required this.onComment,
    required this.onTap,
  });

  @override
  State<ForumCardWidget> createState() => _ForumCardWidgetState();
}

class _ForumCardWidgetState extends State<ForumCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLiked = false;
  bool _isDisliked = false;
  late int _currentLikes;
  late int _currentDislikes;
  late int _currentComments;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _currentLikes = widget.forum.likes;
    _currentDislikes = widget.forum.dislikes;
    _currentComments = widget.forum.commentCount;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      if (_isLiked) {
        _currentLikes--;
        _isLiked = false;
      } else {
        _currentLikes++;
        _isLiked = true;
        if (_isDisliked) {
          _currentDislikes--;
          _isDisliked = false;
        }
      }
    });
    widget.onLike();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _handleDislike() {
    setState(() {
      if (_isDisliked) {
        _currentDislikes--;
        _isDisliked = false;
      } else {
        _currentDislikes++;
        _isDisliked = true;
        if (_isLiked) {
          _currentLikes--;
          _isLiked = false;
        }
      }
    });
    widget.onDislike();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _handleComment() {
    setState(() {
      _currentComments++;
    });
    widget.onComment();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de portada con gradiente superior
              Stack(
                children: [
                  if (widget.forum.coverImageUrl != null)
                    Image.network(
                      widget.forum.coverImageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple[600]!,
                            Colors.blue[600]!,
                          ],
                        ),
                      ),
                    ),
                  // Gradiente oscuro superior
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Badge de temática
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.forum.topic,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Contenido de la tarjeta
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      widget.forum.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'CyGrotesk',
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 8),
                    // Descripción
                    Text(
                      widget.forum.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 12),
                    // Hashtag del foro
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[200]?.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.forum.hashtag,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sección de encuesta si existe
                    if (widget.forum.poll != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.forum.poll!.question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...widget.forum.poll!.options.map((option) {
                              final percentage = widget.forum.totalPollVotes > 0
                                  ? (option.votes /
                                          widget.forum.totalPollVotes) *
                                      100
                                  : 0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option.text,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey[700],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.deepPurple[400]!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Archivos adjuntos (iconos)
                    if (widget.forum.attachments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                widget.forum.attachments.map((attachment) {
                              IconData iconData;
                              Color iconColor;

                              if (attachment.type == 'image') {
                                iconData = LucideIcons.image;
                                iconColor = Colors.blue;
                              } else if (attachment.type == 'video') {
                                iconData = LucideIcons.video;
                                iconColor = Colors.red;
                              } else {
                                iconData = LucideIcons.music;
                                iconColor = Colors.amber;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    iconData,
                                    size: 16,
                                    color: iconColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    // Botones de interacción
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[800]!,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildInteractionButton(
                            icon: LucideIcons.thumbsUp,
                            label: _currentLikes.toString(),
                            isActive: _isLiked,
                            onTap: _handleLike,
                            color: Colors.red,
                          ),
                          _buildInteractionButton(
                            icon: LucideIcons.thumbsDown,
                            label: _currentDislikes.toString(),
                            isActive: _isDisliked,
                            onTap: _handleDislike,
                            color: Colors.blue,
                          ),
                          _buildInteractionButton(
                            icon: LucideIcons.messageCircle,
                            label: _currentComments.toString(),
                            isActive: false,
                            onTap: _handleComment,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey[800]!,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? color : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? color : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

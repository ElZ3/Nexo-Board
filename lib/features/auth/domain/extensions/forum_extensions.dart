import 'package:nexoboard/features/auth/data/models/forum_model.dart';

/// Extensiones útiles para trabajar con ForumModel
extension ForumModelExtension on ForumModel {
  /// Verifica si el foro está activo
  bool get isLive => isActive;

  /// Obtiene el total de interacciones
  int get totalEngagement => likes + dislikes + commentCount;

  /// Verifica si el foro tiene encuesta
  bool get hasPoll => poll != null;

  /// Verifica si el foro tiene archivos adjuntos
  bool get hasAttachments => attachments.isNotEmpty;

  /// Verifica si el foro tiene menciones a otros foros
  bool get hasMentions => mentionedForums.isNotEmpty;

  /// Verifica si el foro tiene publicaciones ancladas
  bool get hasPinnedPosts => pinnedPosts.isNotEmpty;

  /// Obtiene el porcentaje de likes respecto al total de interacciones
  double get likePercentage {
    final total = likes + dislikes;
    if (total == 0) return 0;
    return (likes.toDouble() / total) * 100;
  }

  /// Obtiene el porcentaje de dislikes respecto al total de interacciones
  double get dislikePercentage {
    final total = likes + dislikes;
    if (total == 0) return 0;
    return (dislikes.toDouble() / total) * 100;
  }

  /// Calcula si hay más likes que dislikes
  bool get isPositive => likes > dislikes;

  /// Obtiene la antigüedad formateada
  String get formattedAge {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace ${weeks}s';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Hace ${months}m';
    }
  }

  /// Verifica si el foro fue actualizado recientemente
  bool get isRecent => DateTime.now().difference(createdAt).inDays < 1;

  /// Obtiene el estado del foro como string
  String get statusLabel {
    if (!isActive) return 'Inactivo';
    if (isRecent) return '🟢 Nuevo';
    if (totalEngagement > 100) return '🔥 Viral';
    return '🟢 Activo';
  }

  /// Obtiene el tema formateado con emoji
  String get topicWithEmoji {
    final emojiMap = {
      'Tecnología': '💻',
      'Negocios': '💼',
      'Entretenimiento': '🎬',
      'Educación': '📚',
      'Salud': '⚕️',
      'Deportes': '⚽',
      'Arte': '🎨',
      'Música': '🎵',
      'Viajes': '✈️',
      'Gastronomía': '🍽️',
    };
    final emoji = emojiMap[topic] ?? '📌';
    return '$emoji $topic';
  }
}

/// Extensiones útiles para Poll
extension PollExtension on Poll {
  /// Obtiene el total de votos
  int get totalVotes => options.fold<int>(0, (sum, opt) => sum + opt.votes);

  /// Verifica si la encuesta tiene votos
  bool get hasVotes => totalVotes > 0;

  /// Obtiene la opción ganadora
  PollOption? get winningOption {
    if (options.isEmpty) return null;
    return options
        .reduce((current, next) => current.votes > next.votes ? current : next);
  }

  /// Obtiene el porcentaje de votos para una opción
  double getVotePercentage(PollOption option) {
    if (totalVotes == 0) return 0;
    return (option.votes.toDouble() / totalVotes) * 100;
  }

  /// Obtiene la antigüedad de la encuesta
  String get formattedAge {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

/// Extensiones útiles para ForumAttachment
extension ForumAttachmentExtension on ForumAttachment {
  /// Obtiene el ícono del archivo
  String get typeLabel {
    switch (type) {
      case 'image':
        return 'Imagen';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      default:
        return 'Archivo';
    }
  }

  /// Obtiene la antigüedad formateada
  String get formattedAge {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${uploadedAt.day}/${uploadedAt.month}';
    }
  }

  /// Formatea el tamaño del archivo
  String get formattedSize {
    if (fileSize == null) return '';

    const units = ['B', 'KB', 'MB', 'GB'];
    var bytes = fileSize!.toDouble();
    var unitIndex = 0;

    while (bytes >= 1024 && unitIndex < units.length - 1) {
      bytes /= 1024;
      unitIndex++;
    }

    return '${bytes.toStringAsFixed(2)} ${units[unitIndex]}';
  }
}

/// Extensiones útiles para ModerationSettings
extension ModerationSettingsExtension on ModerationSettings {
  /// Verifica si todo está permitido
  bool get isFullyOpen =>
      allowPhotos && allowVideos && allowAudio && allowComments;

  /// Verifica si todo está bloqueado
  bool get isFullyClosed =>
      !allowPhotos && !allowVideos && !allowAudio && !allowComments;

  /// Obtiene el número de tipos de contenido permitidos
  int get allowedContentTypes {
    int count = 0;
    if (allowPhotos) count++;
    if (allowVideos) count++;
    if (allowAudio) count++;
    return count;
  }

  /// Obtiene una descripción amigable de la configuración
  String get description {
    if (isFullyOpen) {
      return 'Contenido libre - Fotos, videos y audios permitidos';
    }
    if (isFullyClosed) {
      return 'Sin contenido multimedia permitido';
    }

    final allowed = <String>[];
    if (allowPhotos) allowed.add('Fotos');
    if (allowVideos) allowed.add('Videos');
    if (allowAudio) allowed.add('Audios');

    return 'Permitido: ${allowed.join(', ')}';
  }
}

/// Extensiones para trabajar con List<ForumModel>
extension ForumListExtension on List<ForumModel> {
  /// Obtiene los foros más populares
  List<ForumModel> get mostPopular {
    final sorted = [...this];
    sorted.sort((a, b) =>
        (b.likes + b.commentCount).compareTo(a.likes + a.commentCount));
    return sorted;
  }

  /// Obtiene los foros más recientes
  List<ForumModel> get newest {
    final sorted = [...this];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Obtiene los foros con más comentarios
  List<ForumModel> get mostCommented {
    final sorted = [...this];
    sorted.sort((a, b) => b.commentCount.compareTo(a.commentCount));
    return sorted;
  }

  /// Obtiene los foros que están activos
  List<ForumModel> get active => where((f) => f.isActive).toList();

  /// Obtiene los foros inactivos
  List<ForumModel> get inactive => where((f) => !f.isActive).toList();

  /// Obtiene los foros con encuesta
  List<ForumModel> get withPolls => where((f) => f.hasPoll).toList();

  /// Obtiene los foros con archivos adjuntos
  List<ForumModel> get withAttachments =>
      where((f) => f.hasAttachments).toList();

  /// Busca foros por término
  List<ForumModel> search(String query) {
    if (query.isEmpty) return this;
    final lowerQuery = query.toLowerCase();
    return where((forum) {
      return forum.title.toLowerCase().contains(lowerQuery) ||
          forum.description.toLowerCase().contains(lowerQuery) ||
          forum.hashtag.toLowerCase().contains(lowerQuery) ||
          forum.topic.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filtra por tema
  List<ForumModel> filterByTopic(String topic) {
    return where((forum) => forum.topic == topic).toList();
  }

  /// Filtra por hashtag
  List<ForumModel> filterByHashtag(String hashtag) {
    return where((forum) => forum.hashtag == hashtag).toList();
  }

  /// Obtiene foros creados en un rango de fechas
  List<ForumModel> filterByDateRange(DateTime start, DateTime end) {
    return where((forum) {
      return forum.createdAt.isAfter(start) && forum.createdAt.isBefore(end);
    }).toList();
  }
}

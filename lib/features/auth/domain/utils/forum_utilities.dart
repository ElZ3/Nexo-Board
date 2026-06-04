import 'package:nexoboard/features/auth/data/models/forum_model.dart';

/// Utilidades y funciones auxiliares para trabajar con el módulo social
class ForumUtilities {
  /// Valida si un foro tiene toda la información mínima obligatoria
  static bool isForumValid(ForumModel forum) {
    return forum.hashtag.isNotEmpty &&
        forum.topic.isNotEmpty &&
        forum.title.isNotEmpty &&
        forum.description.isNotEmpty;
  }

  /// Valida si un hashtag tiene el formato correcto
  static bool isValidHashtag(String hashtag) {
    if (!hashtag.startsWith('#')) return false;
    if (hashtag.length < 2) return false;
    // Permitir letras, números y guiones bajos
    final regex = RegExp(r'^#[a-zA-Z0-9_]+$');
    return regex.hasMatch(hashtag);
  }

  /// Calcula el porcentaje de completitud de un foro
  static double calculateForumCompleteness(ForumModel forum) {
    double score = 0;
    final maxScore = 10.0;

    // Campo obligatorios (5 puntos)
    if (forum.hashtag.isNotEmpty) score += 1;
    if (forum.topic.isNotEmpty) score += 1;
    if (forum.title.isNotEmpty) score += 1;
    if (forum.description.isNotEmpty) score += 1;
    if (forum.coverImageUrl != null && forum.coverImageUrl!.isNotEmpty) {
      score += 1;
    }

    // Módulos adicionales (5 puntos)
    if (forum.poll != null) score += 1.5;
    if (forum.attachments.isNotEmpty) score += 1.5;
    if (forum.mentionedForums.isNotEmpty) score += 1;
    if (forum.pinnedPosts.isNotEmpty) score += 1;

    return (score / maxScore).clamp(0, 1);
  }

  /// Obtiene el número total de votaciones en una encuesta
  static int getTotalPollVotes(Poll poll) {
    return poll.options.fold<int>(0, (sum, option) => sum + option.votes);
  }

  /// Obtiene la opción ganadora de la encuesta
  static PollOption? getWinningPollOption(Poll poll) {
    if (poll.options.isEmpty) return null;
    return poll.options
        .reduce((current, next) => current.votes > next.votes ? current : next);
  }

  /// Formatea un número para mostrar (1000 → 1K, 1000000 → 1M)
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Obtiene la fecha formateada en formato legible
  static String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Valida la encuesta
  static bool isPollValid(Poll poll) {
    if (poll.question.isEmpty) return false;
    final nonEmptyOptions =
        poll.options.where((option) => option.text.isNotEmpty);
    return nonEmptyOptions.length >= 2 && nonEmptyOptions.length <= 4;
  }

  /// Obtiene el porcentaje de votación para una opción
  static double getPollOptionPercentage(PollOption option, Poll poll) {
    final total = getTotalPollVotes(poll);
    if (total == 0) return 0;
    return (option.votes / total) * 100;
  }

  /// Busca foros por término
  static List<ForumModel> searchForums(
    List<ForumModel> forums,
    String query,
  ) {
    if (query.isEmpty) return forums;

    final lowerQuery = query.toLowerCase();
    return forums.where((forum) {
      return forum.title.toLowerCase().contains(lowerQuery) ||
          forum.description.toLowerCase().contains(lowerQuery) ||
          forum.hashtag.toLowerCase().contains(lowerQuery) ||
          forum.topic.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filtra foros por temática
  static List<ForumModel> filterByTopic(
    List<ForumModel> forums,
    String topic,
  ) {
    return forums.where((forum) => forum.topic == topic).toList();
  }

  /// Ordena foros por criterios diversos
  static List<ForumModel> sortForums(
    List<ForumModel> forums, {
    required SortBy sortBy,
  }) {
    final sortedList = [...forums];

    switch (sortBy) {
      case SortBy.newest:
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortBy.oldest:
        sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SortBy.mostPopular:
        sortedList.sort((a, b) =>
            (b.likes + b.commentCount).compareTo(a.likes + a.commentCount));
      case SortBy.trending:
        sortedList.sort((a, b) {
          final aEngagement = a.likes - a.dislikes + a.commentCount;
          final bEngagement = b.likes - b.dislikes + b.commentCount;
          return bEngagement.compareTo(aEngagement);
        });
      case SortBy.mostCommented:
        sortedList.sort((a, b) => b.commentCount.compareTo(a.commentCount));
    }

    return sortedList;
  }

  /// Obtiene estadísticas agregadas de un foro
  static ForumStatistics getForumStatistics(ForumModel forum) {
    return ForumStatistics(
      totalInteractions: forum.likes + forum.dislikes + forum.commentCount,
      engagementRate: ((forum.likes + forum.commentCount).toDouble() /
              (forum.likes + forum.dislikes + forum.commentCount))
          .clamp(0, 1),
      sentimentScore: (forum.likes.toDouble() /
          (forum.likes + forum.dislikes).toDouble().clamp(1, double.infinity)),
      completenessScore: calculateForumCompleteness(forum),
    );
  }

  /// Valida si un usuario puede votar en la encuesta
  static bool canUserVote(Poll poll, String userId) {
    // Verificar si el usuario ya votó
    for (var option in poll.options) {
      if (option.voterIds.contains(userId)) {
        return false;
      }
    }
    return true;
  }

  /// Registra un voto de usuario en la encuesta
  static Poll registerVote(Poll poll, String userId, String optionId) {
    final updatedOptions = poll.options.map((option) {
      if (option.id == optionId) {
        return option.copyWith(
          votes: option.votes + 1,
          voterIds: [...option.voterIds, userId],
        );
      }
      return option;
    }).toList();

    return poll.copyWith(options: updatedOptions);
  }
}

/// Enumeración para criterios de ordenamiento
enum SortBy {
  newest,
  oldest,
  mostPopular,
  trending,
  mostCommented,
}

/// Clase que contiene estadísticas de un foro
class ForumStatistics {
  final int totalInteractions;
  final double engagementRate;
  final double sentimentScore;
  final double completenessScore;

  ForumStatistics({
    required this.totalInteractions,
    required this.engagementRate,
    required this.sentimentScore,
    required this.completenessScore,
  });

  /// Calcula una puntuación general de salud del foro (0-100)
  int getHealthScore() {
    final score = ((engagementRate * 30) +
            (sentimentScore * 40) +
            (completenessScore * 30))
        .round();
    return score.clamp(0, 100);
  }

  String getHealthStatus() {
    final health = getHealthScore();
    if (health >= 80) return '🟢 Excelente';
    if (health >= 60) return '🟡 Bueno';
    if (health >= 40) return '🟠 Regular';
    return '🔴 Necesita atención';
  }
}

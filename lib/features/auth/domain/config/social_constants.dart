/// Constantes y configuración para el módulo social de NexaBoard
class SocialConstants {
  // Validación de Hashtags
  static const int minHashtagLength = 2;
  static const int maxHashtagLength = 30;
  static const String hashtagRegex = r'^#[a-zA-Z0-9_]+$';

  // Validación de Texto
  static const int minTitleLength = 5;
  static const int maxTitleLength = 150;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 1000;

  // Encuestas
  static const int minPollOptions = 2;
  static const int maxPollOptions = 4;
  static const int minPollQuestionLength = 5;
  static const int maxPollQuestionLength = 200;

  // Archivos Adjuntos
  static const int maxAttachments = 10;
  static const int maxImageSizeMB = 50;
  static const int maxVideoSizeMB = 500;
  static const int maxAudioSizeMB = 200;

  // Publicaciones Ancladas
  static const int maxPinnedPosts = 3;
  static const int minPinnedPostTitleLength = 3;
  static const int maxPinnedPostTitleLength = 200;

  // Menciones
  static const int maxMentions = 10;

  // Comentarios
  static const int minCommentLength = 1;
  static const int maxCommentLength = 500;
  static const int maxCommentPerForum = 10000;

  // Tiempos
  static const Duration pollDuration = Duration(days: 7);
  static const Duration forumCacheDuration = Duration(minutes: 5);

  // Límites de Moderación
  static const int maxModerationActions = 100;
  static const Duration moderationActionTimeout = Duration(hours: 1);

  // Temas disponibles
  static const List<String> availableTopics = [
    'Tecnología',
    'Negocios',
    'Entretenimiento',
    'Educación',
    'Salud',
    'Deportes',
    'Arte',
    'Música',
    'Viajes',
    'Gastronomía',
    'Ciencia',
    'Política',
    'Lifestyle',
    'Moda',
  ];

  // Extensiones de archivo permitidas
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];
  static const List<String> videoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm'
  ];
  static const List<String> audioExtensions = [
    'mp3',
    'wav',
    'm4a',
    'flac',
    'aac'
  ];

  // Mensajes de error
  static const String invalidHashtag =
      'El hashtag debe comenzar con # y contener solo letras, números y guiones bajos';
  static const String invalidTitle =
      'El título debe tener entre 5 y 150 caracteres';
  static const String invalidDescription =
      'La descripción debe tener entre 10 y 1000 caracteres';
  static const String invalidTopic = 'Por favor selecciona una temática válida';
  static const String invalidPoll =
      'La encuesta debe tener entre 2 y 4 opciones válidas';
  static const String invalidAttachment =
      'El archivo supera el tamaño máximo permitido';
  static const String invalidPinnedPost =
      'El foro puede tener como máximo 3 publicaciones ancladas';
  static const String invalidMention =
      'El foro puede mencionar como máximo 10 foros';

  // Mensajes de éxito
  static const String forumCreatedSuccess = 'Foro creado exitosamente';
  static const String forumUpdatedSuccess = 'Foro actualizado correctamente';
  static const String forumDeletedSuccess = 'Foro eliminado correctamente';
  static const String pollVoteRecorded = 'Tu voto ha sido registrado';
  static const String commentAdded = 'Comentario agregado exitosamente';
  static const String likeRecorded = 'Me gusta registrado';
  static const String dislikeRecorded = 'No me gusta registrado';

  // Animaciones
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Estilos de texto
  static const double forumTitleFontSize = 18.0;
  static const double forumDescriptionFontSize = 14.0;
  static const double forumTopicFontSize = 12.0;
  static const double forumHashtagFontSize = 12.0;

  // Tamaños de componentes
  static const double forumCardBorderRadius = 16.0;
  static const double standardBorderRadius = 8.0;
  static const double buttonBorderRadius = 12.0;

  // Espacios
  static const double standardPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
}

/// Configuración de temas y colores
class SocialThemeConfig {
  // Colores principales
  static const int primaryColor = 0xFF9C27B0; // Morado
  static const int secondaryColor = 0xFF2196F3; // Azul
  static const int accentColor = 0xFFFF5722; // Rojo naranja

  // Colores de fondo (tema oscuro)
  static const int backgroundColor = 0xFF121212;
  static const int surfaceColor = 0xFF1E1E1E;
  static const int cardColor = 0xFF2C2C2C;

  // Colores de estado
  static const int successColor = 0xFF4CAF50; // Verde
  static const int warningColor = 0xFFFFC107; // Ámbar
  static const int errorColor = 0xFFF44336; // Rojo
  static const int infoColor = 0xFF2196F3; // Azul

  // Colores de interacción
  static const int likeColor = 0xFFE91E63; // Rosa (para likes)
  static const int dislikeColor = 0xFF2196F3; // Azul (para dislikes)
  static const int commentColor = 0xFF4CAF50; // Verde (para comentarios)
}

/// Enum para tipos de archivos
enum AttachmentType {
  image('image', 'Imagen'),
  video('video', 'Video'),
  audio('audio', 'Audio');

  final String value;
  final String label;

  const AttachmentType(this.value, this.label);

  String get extension {
    switch (this) {
      case AttachmentType.image:
        return 'jpg, png, gif';
      case AttachmentType.video:
        return 'mp4, mov, avi';
      case AttachmentType.audio:
        return 'mp3, wav, m4a';
    }
  }
}

/// Enum para estados de un foro
enum ForumStatus {
  draft('borrador', 'Borrador'),
  published('publicado', 'Publicado'),
  archived('archivado', 'Archivado'),
  suspended('suspendido', 'Suspendido');

  final String value;
  final String label;

  const ForumStatus(this.value, this.label);
}

/// Enum para permisos de moderación
enum ModerationPermission {
  allowPhotos('allowPhotos', 'Permitir fotos'),
  allowVideos('allowVideos', 'Permitir videos'),
  allowAudio('allowAudio', 'Permitir audio'),
  allowComments('allowComments', 'Permitir comentarios'),
  allowMentions('allowMentions', 'Permitir menciones'),
  allowPolls('allowPolls', 'Permitir encuestas');

  final String value;
  final String label;

  const ModerationPermission(this.value, this.label);
}

/// Configuración de paginación y carga
class PaginationConfig {
  static const int itemsPerPage = 20;
  static const int initialLoadItems = 10;
  static const Duration loadMoreDelay = Duration(milliseconds: 500);
  static const int maxCachedPages = 5;
}

/// Configuración de búsqueda y filtros
class SearchConfig {
  static const int minSearchLength = 2;
  static const int maxSearchResults = 100;
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const List<String> searchableFields = [
    'title',
    'description',
    'hashtag',
    'topic'
  ];
}

/// Constantes para Analytics (opcional)
class AnalyticsConstants {
  static const String forumCreatedEvent = 'forum_created';
  static const String forumViewedEvent = 'forum_viewed';
  static const String likeClickedEvent = 'like_clicked';
  static const String dislikeClickedEvent = 'dislike_clicked';
  static const String commentAddedEvent = 'comment_added';
  static const String pollVotedEvent = 'poll_voted';
  static const String forumDeletedEvent = 'forum_deleted';
  static const String forumUpdatedEvent = 'forum_updated';
}

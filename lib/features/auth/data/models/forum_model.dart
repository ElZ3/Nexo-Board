import 'package:equatable/equatable.dart';

/// Modelo que representa una opción de encuesta en un foro
class PollOption extends Equatable {
  final String id;
  final String text;
  final int votes;
  final List<String> voterIds; // IDs de usuarios que votaron

  const PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.voterIds = const [],
  });

  PollOption copyWith({
    String? id,
    String? text,
    int? votes,
    List<String>? voterIds,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
      voterIds: voterIds ?? this.voterIds,
    );
  }

  @override
  List<Object?> get props => [id, text, votes, voterIds];
}

/// Modelo que representa una encuesta dentro de un foro
class Poll extends Equatable {
  final String id;
  final String question;
  final List<PollOption> options;
  final bool allowMultipleVotes;
  final DateTime createdAt;

  const Poll({
    required this.id,
    required this.question,
    required this.options,
    this.allowMultipleVotes = false,
    required this.createdAt,
  });

  Poll copyWith({
    String? id,
    String? question,
    List<PollOption>? options,
    bool? allowMultipleVotes,
    DateTime? createdAt,
  }) {
    return Poll(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      allowMultipleVotes: allowMultipleVotes ?? this.allowMultipleVotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, question, options, allowMultipleVotes, createdAt];
}

/// Modelo que representa un archivo adjunto en un foro
class ForumAttachment extends Equatable {
  final String id;
  final String type; // 'image', 'video', 'audio'
  final String url;
  final String? fileName;
  final int? fileSize;
  final DateTime uploadedAt;

  const ForumAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.fileName,
    this.fileSize,
    required this.uploadedAt,
  });

  ForumAttachment copyWith({
    String? id,
    String? type,
    String? url,
    String? fileName,
    int? fileSize,
    DateTime? uploadedAt,
  }) {
    return ForumAttachment(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object?> get props => [id, type, url, fileName, fileSize, uploadedAt];
}

/// Modelo que representa una publicación anclada en un foro
class PinnedPost extends Equatable {
  final String postId;
  final String title;
  final String? attachmentUrl;
  final String attachmentType; // 'video', 'audio'

  const PinnedPost({
    required this.postId,
    required this.title,
    this.attachmentUrl,
    required this.attachmentType,
  });

  PinnedPost copyWith({
    String? postId,
    String? title,
    String? attachmentUrl,
    String? attachmentType,
  }) {
    return PinnedPost(
      postId: postId ?? this.postId,
      title: title ?? this.title,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
    );
  }

  @override
  List<Object?> get props => [postId, title, attachmentUrl, attachmentType];
}

/// Modelo de configuración de moderación del foro
class ModerationSettings extends Equatable {
  final bool allowPhotos;
  final bool allowVideos;
  final bool allowAudio;
  final bool allowComments;

  const ModerationSettings({
    this.allowPhotos = true,
    this.allowVideos = true,
    this.allowAudio = true,
    this.allowComments = true,
  });

  ModerationSettings copyWith({
    bool? allowPhotos,
    bool? allowVideos,
    bool? allowAudio,
    bool? allowComments,
  }) {
    return ModerationSettings(
      allowPhotos: allowPhotos ?? this.allowPhotos,
      allowVideos: allowVideos ?? this.allowVideos,
      allowAudio: allowAudio ?? this.allowAudio,
      allowComments: allowComments ?? this.allowComments,
    );
  }

  @override
  List<Object?> get props =>
      [allowPhotos, allowVideos, allowAudio, allowComments];
}

/// Modelo principal que representa un Foro
class ForumModel extends Equatable {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final String hashtag; // Ej: #MiForo
  final String topic; // Temática del foro
  final String? coverImageUrl;
  final int likes;
  final int dislikes;
  final int commentCount;
  final Poll? poll;
  final List<ForumAttachment> attachments;
  final List<String> mentionedForums; // Hashtags de otros foros mencionados
  final ModerationSettings moderationSettings;
  final List<PinnedPost> pinnedPosts; // Máximo 3
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const ForumModel({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.hashtag,
    required this.topic,
    this.coverImageUrl,
    this.likes = 0,
    this.dislikes = 0,
    this.commentCount = 0,
    this.poll,
    this.attachments = const [],
    this.mentionedForums = const [],
    this.moderationSettings = const ModerationSettings(),
    this.pinnedPosts = const [],
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Retorna el total de votos en la encuesta
  int get totalPollVotes {
    if (poll == null) return 0;
    return poll!.options.fold<int>(0, (sum, option) => sum + option.votes);
  }

  /// Retorna el total de interacciones
  int get totalInteractions => likes + dislikes + commentCount;

  /// Copia el modelo con valores modificados
  ForumModel copyWith({
    String? id,
    String? creatorId,
    String? title,
    String? description,
    String? hashtag,
    String? topic,
    String? coverImageUrl,
    int? likes,
    int? dislikes,
    int? commentCount,
    Poll? poll,
    List<ForumAttachment>? attachments,
    List<String>? mentionedForums,
    ModerationSettings? moderationSettings,
    List<PinnedPost>? pinnedPosts,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ForumModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      hashtag: hashtag ?? this.hashtag,
      topic: topic ?? this.topic,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      commentCount: commentCount ?? this.commentCount,
      poll: poll ?? this.poll,
      attachments: attachments ?? this.attachments,
      mentionedForums: mentionedForums ?? this.mentionedForums,
      moderationSettings: moderationSettings ?? this.moderationSettings,
      pinnedPosts: pinnedPosts ?? this.pinnedPosts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorId,
        title,
        description,
        hashtag,
        topic,
        coverImageUrl,
        likes,
        dislikes,
        commentCount,
        poll,
        attachments,
        mentionedForums,
        moderationSettings,
        pinnedPosts,
        createdAt,
        updatedAt,
        isActive,
      ];
}

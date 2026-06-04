import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anónimo',
      text: map['text'] ?? '',
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

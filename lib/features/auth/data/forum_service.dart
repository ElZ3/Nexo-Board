import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nexoboard/features/auth/data/models/comment_model.dart';
import 'package:nexoboard/features/auth/data/models/forum_model.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _forumsRef => _firestore.collection('forums');

  /// Stream de foros creados por [uid], ordenados por fecha de creación desc.
  Stream<List<ForumModel>> streamUserForums(String uid) {
    return _forumsRef
        .where('creatorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ForumModel.fromFirestore(doc))
            .toList());
  }

  /// Stream de todos los foros activos. El filtrado/ordenado fino (por hashtag,
  /// nombre, likes o dislikes) se resuelve en la capa de presentación para
  /// permitir autocompletado por subcadena e insensible a mayúsculas.
  Stream<List<ForumModel>> streamAllForums() {
    return _forumsRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ForumModel.fromFirestore(doc))
            .toList());
  }

  /// Actualiza los campos editables de un foro (título, descripción, imagen).
  /// El hashtag NO se modifica nunca.
  Future<void> updateForum({
    required String forumId,
    required String title,
    required String description,
    File? coverImage,
  }) async {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (coverImage != null) {
      final ref = _storage
          .ref()
          .child('forums')
          .child(forumId)
          .child('cover.jpg');
      await ref.putFile(coverImage);
      data['coverImageUrl'] = await ref.getDownloadURL();
    }

    await _forumsRef.doc(forumId).update(data);
  }

  /// Stream de comentarios de un foro, ordenados por fecha asc.
  Stream<List<CommentModel>> streamComments(String forumId) {
    return _forumsRef
        .doc(forumId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  /// Elimina un comentario de un foro (autoría del creador).
  Future<void> deleteComment({
    required String forumId,
    required String commentId,
  }) async {
    await _forumsRef
        .doc(forumId)
        .collection('comments')
        .doc(commentId)
        .delete();

    // Decrementar el contador de comentarios del foro.
    await _forumsRef.doc(forumId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }
}

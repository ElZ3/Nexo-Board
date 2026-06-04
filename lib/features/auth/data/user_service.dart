import 'package:cloud_firestore/cloud_firestore.dart';

/// Resumen público de un usuario, basado en el esquema real escrito en
/// la colección `users` (ver AuthService.registerUser).
class UserSummary {
  final String uid;
  final String username;
  final String name;
  final String lastName;
  final String profileImageUrl;
  final String description;
  final int accumulatedLikes;
  final int activeForumsCount;

  const UserSummary({
    required this.uid,
    required this.username,
    required this.name,
    required this.lastName,
    required this.profileImageUrl,
    required this.description,
    required this.accumulatedLikes,
    required this.activeForumsCount,
  });

  String get fullName => '$name $lastName'.trim();

  factory UserSummary.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return UserSummary(
      uid: doc.id,
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      lastName: map['lastName'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      description: map['description'] ?? '',
      accumulatedLikes: map['accumulatedLikes'] ?? 0,
      activeForumsCount: map['activeForumsCount'] ?? 0,
    );
  }
}

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection('users');

  /// Stream de todos los usuarios activos. El filtrado por nombre/username se
  /// hace en la capa de presentación para permitir autocompletado por
  /// subcadena e insensible a mayúsculas.
  Stream<List<UserSummary>> streamAllUsers() {
    return _usersRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserSummary.fromDoc(doc)).toList());
  }

  /// Stream del documento de un usuario concreto (perfil público).
  Stream<DocumentSnapshot> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots();
  }
}

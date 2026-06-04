import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nombreCompleto;
  final String username;
  final String email;
  final String fotoPerfilUrl;
  final String bio;
  final bool flagsDeBaneo;
  final int totalLikesRecibidos;
  final DateTime fechaCreacion;

  const UserModel({
    required this.uid,
    required this.nombreCompleto,
    required this.username,
    required this.email,
    required this.fotoPerfilUrl,
    required this.bio,
    required this.flagsDeBaneo,
    required this.totalLikesRecibidos,
    required this.fechaCreacion,
  });

  // Convierte el objeto a un mapa para enviarlo a Cloud Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombreCompleto': nombreCompleto,
      'username': username,
      'email': email,
      'fotoPerfilUrl': fotoPerfilUrl,
      'bio': bio,
      'flagsDeBaneo': flagsDeBaneo,
      'totalLikesRecibidos': totalLikesRecibidos,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Crea una instancia del modelo a partir de un documento de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      nombreCompleto: map['nombreCompleto'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      fotoPerfilUrl: map['fotoPerfilUrl'] ?? '',
      bio: map['bio'] ?? '',
      flagsDeBaneo: map['flagsDeBaneo'] ?? false,
      totalLikesRecibidos: map['totalLikesRecibidos'] ?? 0,
      fechaCreacion:
          (map['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // NUEVO: Login flexible por Correo o Nombre de Usuario
  Future<UserCredential> loginUser({
    required String identifier, // Puede ser email o username
    required String password,
  }) async {
    try {
      String email = identifier.trim();

      // Si no contiene un '@', asumimos que es un nombre de usuario
      if (!email.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception('El nombre de usuario no está registrado.');
        }

        // Extraemos el correo asociado a ese nombre de usuario
        email = querySnapshot.docs.first.get('email');
      }

      // Autenticación real en Firebase
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(
          'Error de autenticación: ${e.toString().replaceAll(RegExp(r'\[.*\]'), '')}');
    }
  }

  // MODIFICADO: Registro inicializando campos de auditoría para el perfil
  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required DateTime birthDate,
    required String gender,
    required String username,
    String? description,
    File? profileImage,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = credential.user!.uid;
      String? profileImageUrl;

      if (profileImage != null) {
        Reference ref =
            _storage.ref().child('users').child(uid).child('profile.jpg');
        UploadTask uploadTask = ref.putFile(profileImage);
        TaskSnapshot snapshot = await uploadTask;
        profileImageUrl = await snapshot.ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'lastName': lastName,
        'username': username,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        'description': description ?? '',
        'profileImageUrl': profileImageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        // Campos de control solicitados para el perfil y reglas de negocio
        'activeForumsCount': 0,
        'accumulatedLikes': 0,
        'usernameChangesHistory':
            [], // Almacenará Timestamps de cuándo cambió de usuario
      });
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // NUEVO: Lógica de actualización de perfil con regla de negocio estricta (2 veces por mes)
  Future<void> updateUserProfile({
    required String uid,
    required String currentUsername,
    required String newUsername,
    required String newDescription,
    File? newProfileImage,
  }) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userRef.get();

      if (!userDoc.exists) throw Exception("Usuario no encontrado.");

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      List<dynamic> history = data['usernameChangesHistory'] ?? [];

      // Validar regla de negocio si desea cambiar el nombre de usuario
      if (currentUsername != newUsername) {
        // Verificar si el nuevo username ya está tomado por otra persona
        final usernameCheck = await _firestore
            .collection('users')
            .where('username', isEqualTo: newUsername)
            .limit(1)
            .get();

        if (usernameCheck.docs.isNotEmpty &&
            usernameCheck.docs.first.id != uid) {
          throw Exception('El nombre de usuario ya está en uso.');
        }

        DateTime now = DateTime.now();
        // Filtrar cambios realizados en el mes calendario actual
        List<DateTime> changesThisMonth = history
            .map((timestamp) => (timestamp as Timestamp).toDate())
            .where((date) => date.year == now.year && date.month == now.month)
            .toList();

        if (changesThisMonth.length >= 2) {
          throw Exception(
              'Solo puedes cambiar tu nombre de usuario 2 veces por mes.');
        }

        // Si pasa la validación, agregamos el registro al historial
        history.add(Timestamp.fromDate(now));
      }

      String? updatedImageUrl = data['profileImageUrl'];
      if (newProfileImage != null) {
        Reference ref =
            _storage.ref().child('users').child(uid).child('profile.jpg');
        await ref.putFile(newProfileImage);
        updatedImageUrl = await ref.getDownloadURL();
      }

      await userRef.update({
        'username': newUsername,
        'description': newDescription,
        'profileImageUrl': updatedImageUrl,
        'usernameChangesHistory': history,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

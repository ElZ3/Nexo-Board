import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexoboard/core/utils/media_service.dart';
import 'package:nexoboard/features/auth/data/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _authService = AuthService();
  final _mediaService = MediaService();

  void _showEditDialog(Map<String, dynamic> userData) {
    final usernameController =
        TextEditingController(text: userData['username']);
    final descriptionController =
        TextEditingController(text: userData['description']);
    File? selectedImage;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Editar Perfil',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    const Text(
                      '*Nota: El nombre de usuario solo se puede cambiar 2 veces al mes.',
                      style: TextStyle(color: Colors.amber, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final file = await _mediaService.pickProfileImage();
                          if (file != null) {
                            setModalState(() => selectedImage = file);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white10,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (userData['profileImageUrl'] != ''
                                ? NetworkImage(userData['profileImageUrl'])
                                : null) as ImageProvider?,
                        child: selectedImage == null &&
                                userData['profileImageUrl'] == ''
                            ? const Icon(Icons.camera_alt,
                                color: Colors.white54)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          const InputDecoration(labelText: 'Nombre de usuario'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              try {
                                await _authService.updateUserProfile(
                                  uid: _auth.currentUser!.uid,
                                  currentUsername: userData['username'],
                                  newUsername: usernameController.text.trim(),
                                  newDescription:
                                      descriptionController.text.trim(),
                                  newProfileImage: selectedImage,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Perfil actualizado con éxito.')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(e
                                            .toString()
                                            .replaceAll('Exception: ', '')),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              } finally {
                                setModalState(() => isSaving = false);
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Guardar Cambios',
                              style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Center(
          child: Text('Usuario no autenticado.',
              style: TextStyle(color: Colors.white)));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
              child: Text('Error al cargar datos del perfil.',
                  style: TextStyle(color: Colors.white)));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFF1E1E1E),
                    backgroundImage: userData['profileImageUrl'] != ''
                        ? NetworkImage(userData['profileImageUrl'])
                        : null,
                    child: userData['profileImageUrl'] == ''
                        ? const Icon(Icons.person,
                            size: 45, color: Colors.white54)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@${userData['username']}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('${userData['name']} ${userData['lastName']}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note,
                        color: Color(0xFFE040FB), size: 28),
                    onPressed: () => _showEditDialog(userData),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userData['description'] != ''
                    ? userData['description']
                    : 'Sin descripción todavía.',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 32),
              // Grid de contadores en tiempo real
              Row(
                children: [
                  Expanded(
                    child: _buildCounterCard(
                      title: 'Foros Activos',
                      count: userData['activeForumsCount'] ?? 0,
                      icon: Icons.dashboard_customize_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCounterCard(
                      title: 'Likes Sumados',
                      count: userData['accumulatedLikes'] ?? 0,
                      icon: Icons.favorite_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounterCard(
      {required String title, required int count, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE040FB), size: 24),
          const SizedBox(height: 12),
          Text('$count',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }
}

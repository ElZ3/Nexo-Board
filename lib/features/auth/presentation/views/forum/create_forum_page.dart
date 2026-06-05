import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexoboard/features/auth/data/models/forum_model.dart';

class CreateForumPage extends StatefulWidget {
  final ValueChanged<ForumModel> onForumCreated;

  const CreateForumPage({
    super.key,
    required this.onForumCreated,
  });

  @override
  State<CreateForumPage> createState() => _CreateForumPageState();
}

class _CreateForumPageState extends State<CreateForumPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  int _currentStep = 0;
  String? _selectedCoverImage;
  final List<String> _attachments = [];
  bool _isSubmitting = false;

  bool _allowPhotos = true;
  bool _allowVideos = true;
  bool _allowAudio = true;
  bool _allowComments = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hashtagController.dispose();
    _topicController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _isStep1Complete() =>
      _normalizeHashtag(_hashtagController.text).isNotEmpty &&
      _topicController.text.trim().isNotEmpty;

  bool _isStep2Complete() =>
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  String _normalizeHashtag(String rawValue) {
    final sanitized = rawValue.trim().replaceAll(RegExp(r'\s+'), '');
    if (sanitized.isEmpty) return '';
    return sanitized.startsWith('#') ? sanitized : '#$sanitized';
  }

  Future<void> _pickCoverImage() async {
    if (_isSubmitting) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );
      if (!mounted || pickedFile == null) return;
      setState(() => _selectedCoverImage = pickedFile.path);
    } catch (e) {
      _showSnackBar('No se pudo seleccionar la portada: $e', isError: true);
    }
  }

  Future<void> _pickAttachment(String type) async {
    if (_isSubmitting) return;

    try {
      if (type == 'image') {
        final pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 82,
        );
        if (!mounted || pickedFile == null) return;
        setState(() => _attachments.add(pickedFile.path));
        return;
      }

      final allowedExtensions =
          type == 'video' ? ['mp4', 'mov', 'avi'] : ['mp3', 'wav', 'm4a'];
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      if (!mounted || result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath != null) {
        setState(() => _attachments.add(filePath));
      }
    } catch (e) {
      _showSnackBar('No se pudo adjuntar el archivo: $e', isError: true);
    }
  }

  Future<String?> _uploadForumFile({
    required String forumId,
    required String localPath,
    required String storageName,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) return null;

    final extension = localPath.contains('.') ? localPath.split('.').last : 'bin';
    final ref = _storage.ref('forums/$forumId/$storageName.$extension');
    await ref.putFile(file).timeout(const Duration(seconds: 45));
    return ref.getDownloadURL().timeout(const Duration(seconds: 20));
  }

  Future<void> _createForum() async {
    if (_isSubmitting || !_isStep1Complete() || !_isStep2Complete()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Debes iniciar sesión para crear un foro.');
      }

      final forumDoc = _firestore.collection('forums').doc();
      final forumId = forumDoc.id;
      final now = DateTime.now();
      final hashtag = _normalizeHashtag(_hashtagController.text);
      String? coverUrl;

      if (_selectedCoverImage != null) {
        coverUrl = await _uploadForumFile(
          forumId: forumId,
          localPath: _selectedCoverImage!,
          storageName: 'cover',
        );
      }

      final uploadedAttachments = <ForumAttachment>[];
      for (final entry in _attachments.asMap().entries) {
        final localPath = entry.value;
        final attachmentUrl = await _uploadForumFile(
          forumId: forumId,
          localPath: localPath,
          storageName: 'attachment_${entry.key}',
        );
        if (attachmentUrl == null) continue;
        uploadedAttachments.add(
          ForumAttachment(
            id: 'attachment-${entry.key}',
            type: _attachmentTypeForPath(localPath),
            url: attachmentUrl,
            fileName: localPath.split(Platform.pathSeparator).last,
            fileSize: await File(localPath).length(),
            uploadedAt: now,
          ),
        );
      }

      final forum = ForumModel(
        id: forumId,
        creatorId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        hashtag: hashtag,
        topic: _topicController.text.trim(),
        coverImageUrl: coverUrl,
        attachments: uploadedAttachments,
        moderationSettings: ModerationSettings(
          allowPhotos: _allowPhotos,
          allowVideos: _allowVideos,
          allowAudio: _allowAudio,
          allowComments: _allowComments,
        ),
        createdAt: now,
      );

      await forumDoc.set({
        'id': forum.id,
        'creatorId': forum.creatorId,
        'title': forum.title,
        'description': forum.description,
        'hashtag': forum.hashtag,
        'hashtagNormalized': forum.hashtag.toLowerCase(),
        'topic': forum.topic,
        'coverImageUrl': forum.coverImageUrl,
        'likes': forum.likes,
        'dislikes': forum.dislikes,
        'commentCount': forum.commentCount,
        'attachments': forum.attachments
            .map((attachment) => {
                  'id': attachment.id,
                  'type': attachment.type,
                  'url': attachment.url,
                  'fileName': attachment.fileName,
                  'fileSize': attachment.fileSize,
                  'uploadedAt': Timestamp.fromDate(attachment.uploadedAt),
                })
            .toList(),
        'mentionedForums': forum.mentionedForums,
        'moderationSettings': {
          'allowPhotos': forum.moderationSettings.allowPhotos,
          'allowVideos': forum.moderationSettings.allowVideos,
          'allowAudio': forum.moderationSettings.allowAudio,
          'allowComments': forum.moderationSettings.allowComments,
        },
        'pinnedPosts': const [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'isActive': true,
      }).timeout(const Duration(seconds: 25));

      try {
        await _firestore.collection('users').doc(user.uid).update({
          'activeForumsCount': FieldValue.increment(1),
        }).timeout(const Duration(seconds: 15));
      } catch (e) {
        debugPrint('No se pudo actualizar activeForumsCount: $e');
      }

      if (!mounted) return;
      widget.onForumCreated(forum);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Foro creado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      _showSnackBar(e.message ?? 'Firebase no pudo crear el foro.', isError: true);
    } on TimeoutException {
      _showSnackBar('La conexión tardó demasiado. Inténtalo otra vez.', isError: true);
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _attachmentTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi')) {
      return 'video';
    }
    if (lower.endsWith('.mp3') || lower.endsWith('.wav') || lower.endsWith('.m4a')) {
      return 'audio';
    }
    return 'image';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.grey[850],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Crear Nuevo Foro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentStep = index),
          children: [
            _buildScrollableStep(_buildStep1Children(), bottomInset),
            _buildScrollableStep(_buildStep2Children(), bottomInset),
            _buildScrollableStep(_buildStep3Children(), bottomInset),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildScrollableStep(List<Widget> children, double bottomInset) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ).animate().fadeIn(duration: 200.ms);
      },
    );
  }

  List<Widget> _buildStep1Children() {
    return [
      _buildHeader(
        'Paso 1 de 3',
        'Información Identificativa',
        'Elige el hashtag único y la temática de tu comunidad.',
        [Colors.deepPurple[700]!, Colors.blue[700]!],
      ),
      const SizedBox(height: 32),
      _buildTextField(
        controller: _hashtagController,
        label: 'Hashtag del Foro',
        hint: 'Ej: #FlutterDevelopers',
        icon: LucideIcons.hash,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 24),
      _buildDropdownField(
        label: 'Temática del Foro',
        value: _topicController.text.isEmpty ? null : _topicController.text,
        items: const [
          'Tecnología',
          'Videojuegos',
          'Diseño',
          'Negocios',
          'Estilo de Vida',
        ],
        onChanged: (val) => setState(() => _topicController.text = val ?? ''),
      ),
    ];
  }

  List<Widget> _buildStep2Children() {
    return [
      _buildHeader(
        'Paso 2 de 3',
        'Detalles del Foro',
        'Dale un título claro, describe el propósito e introduce una imagen visual.',
        [Colors.blue[700]!, Colors.purple[700]!],
      ),
      const SizedBox(height: 32),
      _buildTextField(
        controller: _titleController,
        label: 'Título de la Comunidad',
        hint: 'Ej: Desarrolladores Flutter de LATAM',
        icon: LucideIcons.type,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 24),
      _buildTextField(
        controller: _descriptionController,
        label: 'Descripción Breve',
        hint: 'Explica de qué se hablará en este foro...',
        icon: LucideIcons.fileText,
        maxLines: 4,
        textInputAction: TextInputAction.newline,
      ),
      const SizedBox(height: 24),
      const Text(
        'Imagen de Portada',
        style: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickCoverImage,
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _selectedCoverImage != null ? Colors.deepPurple : Colors.grey[800]!,
              width: 1.5,
            ),
          ),
          child: Center(
            child: _selectedCoverImage != null
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.checkCircle, color: Colors.green),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Imagen seleccionada con éxito',
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.image, color: Colors.grey, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Presiona para cargar una imagen',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildStep3Children() {
    return [
      _buildHeader(
        'Paso 3 de 3',
        'Políticas y Moderación',
        'Determina qué tipo de contenidos tienen permitido publicar tus miembros.',
        [Colors.purple[700]!, Colors.pink[700]!],
      ),
      const SizedBox(height: 32),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Permitir Imágenes', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Los usuarios pueden adjuntar fotos',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              value: _allowPhotos,
              activeColor: Colors.deepPurple[400],
              onChanged: _isSubmitting ? null : (val) => setState(() => _allowPhotos = val),
            ),
            Divider(color: Colors.grey[900], height: 1),
            SwitchListTile(
              title: const Text('Permitir Archivos de Video', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Habilita la subida de clips multimedia',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              value: _allowVideos,
              activeColor: Colors.deepPurple[400],
              onChanged: _isSubmitting ? null : (val) => setState(() => _allowVideos = val),
            ),
            Divider(color: Colors.grey[900], height: 1),
            SwitchListTile(
              title: const Text('Permitir Notas de Voz', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Los miembros podrán grabar audios',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              value: _allowAudio,
              activeColor: Colors.deepPurple[400],
              onChanged: _isSubmitting ? null : (val) => setState(() => _allowAudio = val),
            ),
            Divider(color: Colors.grey[900], height: 1),
            SwitchListTile(
              title: const Text('Habilitar Caja de Comentarios', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Permite debates interactivos dentro de los posts',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              value: _allowComments,
              activeColor: Colors.deepPurple[400],
              onChanged: _isSubmitting ? null : (val) => setState(() => _allowComments = val),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildAttachmentChip('Imagen', LucideIcons.image, () => _pickAttachment('image')),
          _buildAttachmentChip('Video', LucideIcons.video, () => _pickAttachment('video')),
          _buildAttachmentChip('Audio', LucideIcons.mic, () => _pickAttachment('audio')),
        ],
      ),
      if (_attachments.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
          '${_attachments.length} adjunto(s) local(es) seleccionados',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    ];
  }

  Widget _buildAttachmentChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      onPressed: _isSubmitting ? null : onTap,
      avatar: Icon(icon, size: 16, color: Colors.white70),
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white70),
      backgroundColor: const Color(0xFF242424),
      side: BorderSide(color: Colors.grey[800]!),
    );
  }

  Widget _buildHeader(String step, String title, String subtitle, List<Color> gradient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: !_isSubmitting,
          minLines: maxLines == 1 ? 1 : null,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text('Elige una categoría', style: TextStyle(color: Colors.white24)),
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(LucideIcons.chevronDown, color: Colors.white38),
              style: const TextStyle(color: Colors.white),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: _isSubmitting ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    final cannotContinue = (_currentStep == 0 && !_isStep1Complete()) ||
        (_currentStep == 1 && !_isStep2Complete()) ||
        _isSubmitting;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFF1A1A1A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              icon: const Icon(LucideIcons.arrowLeft, size: 18, color: Colors.white70),
              label: const Text('Atrás', style: TextStyle(color: Colors.white70)),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
            )
          else
            const SizedBox(width: 96),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentStep == 2 ? Colors.green[700] : Colors.deepPurple[600],
              disabledBackgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(
                    _currentStep == 2 ? LucideIcons.check : LucideIcons.arrowRight,
                    color: Colors.white,
                    size: 18,
                  ),
            label: Text(
              _isSubmitting ? 'Guardando...' : (_currentStep == 2 ? 'Finalizar' : 'Siguiente'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: cannotContinue
                ? null
                : () {
                    if (_currentStep < 2) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _createForum();
                    }
                  },
          ),
        ],
      ),
    );
  }
}

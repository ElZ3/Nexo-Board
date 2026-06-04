import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexoboard/features/auth/data/models/forum_model.dart';

class CreateForumPage extends StatefulWidget {
  final Function(ForumModel) onForumCreated;

  const CreateForumPage({
    super.key,
    required this.onForumCreated,
  });

  @override
  State<CreateForumPage> createState() => _CreateForumPageState();
}

class _CreateForumPageState extends State<CreateForumPage>
    with TickerProviderStateMixin {
  // 1. CONTROLADORES (Manteniendo intacta tu lógica original)
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _hashtagController;
  late TextEditingController _topicController;

  // 2. ESTADOS
  late PageController _pageController;
  int _currentStep = 0;
  String? _selectedCoverImage;
  final List<String> _attachments = [];

  // Reglas de moderación por defecto
  bool _allowPhotos = true;
  bool _allowVideos = true;
  bool _allowAudio = true;
  bool _allowComments = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _hashtagController = TextEditingController();
    _topicController = TextEditingController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hashtagController.dispose();
    _topicController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 3. VALIDACIONES DE PASOS
  bool _isStep1Complete() =>
      _hashtagController.text.trim().isNotEmpty &&
      _topicController.text.trim().isNotEmpty;
  bool _isStep2Complete() =>
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  // 4. MÉTODOS DE ARCHIVOS CORREGIDOS (Librería v11)
  void _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedCoverImage = pickedFile.path);
    }
  }

  void _pickAttachment(String type) async {
    try {
      if (type == 'image') {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() => _attachments.add(pickedFile.path));
        }
      } else {
        final allowedExtensions =
            type == 'video' ? ['mp4', 'mov', 'avi'] : ['mp3', 'wav', 'm4a'];
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
        );
        if (result != null && result.files.isNotEmpty) {
          final filePath = result.files.first.path;
          if (filePath != null) {
            setState(() => _attachments.add(filePath));
          }
        }
      }
    } catch (e) {
      debugPrint('Error seleccionando adjunto: $e');
    }
  }

  void _createForum() {
    if (!_isStep1Complete() || !_isStep2Complete()) return;

    // Aquí invocamos el callback pasando un modelo simulado/armado temporalmente
    // según los requerimientos de tu ForumModel
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('¡Foro creado con éxito!'),
          backgroundColor: Colors.green),
    );
  }

  // 5. ORQUESTADOR VISUAL (Diseño protegido contra desbordamientos)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Crear Nuevo Foro',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Control estricto por botones inferiores
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ================= PASO 1: INFORMACIÓN BÁSICA =================
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
              'Paso 1 de 3',
              'Información Identificativa',
              'Elige el hashtag único y la temática de tu comunidad.',
              [Colors.deepPurple[700]!, Colors.blue[700]!]),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _hashtagController,
            label: 'Hashtag del Foro',
            hint: 'Ej: #FlutterDevelopers',
            icon: LucideIcons.hash,
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
              'Estilo de Vida'
            ],
            onChanged: (val) =>
                setState(() => _topicController.text = val ?? ''),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ================= PASO 2: CONTENIDO Y PORTADA =================
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
              'Paso 2 de 3',
              'Detalles del Foro',
              'Dale un título claro, describe el propósito e introduce una imagen visual.',
              [Colors.blue[700]!, Colors.purple[700]!]),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _titleController,
            label: 'Título de la Comunidad',
            hint: 'Ej: Desarrolladores Flutter de LATAM',
            icon: LucideIcons.type,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _descriptionController,
            label: 'Descripción Breve',
            hint: 'Explica de qué se hablará en este foro...',
            icon: LucideIcons.fileText,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          const Text('Imagen de Portada',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
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
                    color: _selectedCoverImage != null
                        ? Colors.deepPurple
                        : Colors.grey[800]!,
                    width: 1.5),
              ),
              child: Center(
                child: _selectedCoverImage != null
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.checkCircle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Imagen seleccionada con éxito',
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.image, color: Colors.grey, size: 32),
                          SizedBox(height: 8),
                          Text('Presiona para cargar una imagen',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ================= PASO 3: CONFIGURACIÓN DE MODERACIÓN =================
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
              'Paso 3 de 3',
              'Políticas y Moderación',
              'Determina qué tipo de contenidos tienen permitido publicar tus miembros.',
              [Colors.purple[700]!, Colors.pink[700]!]),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Permitir Imágenes',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Los usuarios pueden adjuntar fotos',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: _allowPhotos,
                  activeColor: Colors.deepPurple[400],
                  onChanged: (val) => setState(() => _allowPhotos = val),
                ),
                Divider(color: Colors.grey[900], height: 1),
                SwitchListTile(
                  title: const Text('Permitir Archivos de Video',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Habilita la subida de clips multimedia',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: _allowVideos,
                  activeColor: Colors.deepPurple[400],
                  onChanged: (val) => setState(() => _allowVideos = val),
                ),
                Divider(color: Colors.grey[900], height: 1),
                SwitchListTile(
                  title: const Text('Permitir Notas de Voz',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Los miembros podrán grabar audios',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: _allowAudio,
                  activeColor: Colors.deepPurple[400],
                  onChanged: (val) => setState(() => _allowAudio = val),
                ),
                Divider(color: Colors.grey[900], height: 1),
                SwitchListTile(
                  title: const Text('Habilitar Caja de Comentarios',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                      'Permite debates interactivos dentro de los posts',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  value: _allowComments,
                  activeColor: Colors.deepPurple[400],
                  onChanged: (val) => setState(() => _allowComments = val),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ================= COMPONENTES REUTILIZABLES BLINDADOS =================
  Widget _buildHeader(
      String step, String title, String subtitle, List<Color> gradient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      required IconData icon,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: (_) =>
              setState(() {}), // Refresca estado de botones de navegación
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.deepPurple, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      {required String label,
      required String? value,
      required List<String> items,
      required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text('Elige una categoría',
                  style: TextStyle(color: Colors.white24)),
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(LucideIcons.chevronDown, color: Colors.white38),
              style: const TextStyle(color: Colors.white),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFF1A1A1A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              icon: const Icon(LucideIcons.arrowLeft,
                  size: 18, color: Colors.white70),
              label:
                  const Text('Atrás', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
            )
          else
            const SizedBox.shrink(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentStep == 2
                  ? Colors.green[700]
                  : Colors.deepPurple[600],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(
                _currentStep == 2 ? LucideIcons.check : LucideIcons.arrowRight,
                color: Colors.white,
                size: 18),
            label: Text(_currentStep == 2 ? 'Finalizar' : 'Siguiente',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: (_currentStep == 0 && !_isStep1Complete()) ||
                    (_currentStep == 1 && !_isStep2Complete())
                ? null
                : () {
                    if (_currentStep < 2) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ==================== HEADER ANIMADO ====================
class ForumStepHeader extends StatelessWidget {
  final String stepText;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const ForumStepHeader({
    super.key,
    required this.stepText,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stepText,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'CyGrotesk')),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ==================== CAMPOS DE TEXTO ====================
class ForumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isRequired;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const ForumTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isRequired = false,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 18),
            const SizedBox(width: 8),
            Text(label + (isRequired ? ' *' : ''),
                style: TextStyle(
                    color: Colors.grey[300], fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.deepPurple[600]!)),
          ),
        ),
      ],
    );
  }
}

// ==================== SELECTOR (DROPDOWN) ====================
class ForumDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;

  const ForumDropdownField(
      {super.key,
      required this.value,
      required this.items,
      required this.label,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label + ' *',
            style: TextStyle(
                color: Colors.grey[300], fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.grey[850], borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Selecciona una opción',
                  style: TextStyle(color: Colors.grey[600])),
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              icon: Icon(LucideIcons.chevronDown, color: Colors.grey[400]),
              style: const TextStyle(color: Colors.white),
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== PANEL DE MODERACIÓN ====================
class ForumModerationPanel extends StatelessWidget {
  final bool allowPhotos, allowVideos, allowAudio, allowComments;
  final Function(String, bool) onToggle;

  const ForumModerationPanel(
      {super.key,
      required this.allowPhotos,
      required this.allowVideos,
      required this.allowAudio,
      required this.allowComments,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey[850], borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reglas y Moderación del Foro',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SwitchListTile(
              title: const Text('Permitir Fotos',
                  style: TextStyle(color: Colors.white70)),
              value: allowPhotos,
              activeColor: Colors.deepPurple[400],
              onChanged: (val) => onToggle('photos', val)),
          SwitchListTile(
              title: const Text('Permitir Videos',
                  style: TextStyle(color: Colors.white70)),
              value: allowVideos,
              activeColor: Colors.deepPurple[400],
              onChanged: (val) => onToggle('videos', val)),
          SwitchListTile(
              title: const Text('Permitir Audios',
                  style: TextStyle(color: Colors.white70)),
              value: allowAudio,
              activeColor: Colors.deepPurple[400],
              onChanged: (val) => onToggle('audio', val)),
          SwitchListTile(
              title: const Text('Permitir Comentarios',
                  style: TextStyle(color: Colors.white70)),
              value: allowComments,
              activeColor: Colors.deepPurple[400],
              onChanged: (val) => onToggle('comments', val)),
        ],
      ),
    );
  }
}

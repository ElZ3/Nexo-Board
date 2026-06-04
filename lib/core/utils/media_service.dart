import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxVideoSize = 30 * 1024 * 1024; // 30 MB
  static const int maxAudioSize = 10 * 1024 * 1024; // 10 MB

  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> pickProfileImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final size = await file.length();
      if (size > maxImageSize) {
        throw Exception('La imagen excede el límite de 5MB.');
      }
      return file;
    }
    return null;
  }

  Future<File?> pickVideo() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.first.path;
      if (filePath != null) {
        final file = File(filePath);
        final size = await file.length();
        if (size > maxVideoSize) {
          throw Exception('El video excede el límite estricto de 30MB.');
        }
        return file;
      }
    }
    return null;
  }

  Future<File?> pickAudio() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.first.path;
      if (filePath != null) {
        final file = File(filePath);
        final size = await file.length();
        if (size > maxAudioSize) {
          throw Exception('El audio excede el límite estricto de 10MB.');
        }
        return file;
      }
    }
    return null;
  }
}

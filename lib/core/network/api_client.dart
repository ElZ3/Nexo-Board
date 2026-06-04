import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiClient {
  // --- BASE URLs ---
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _giphyBaseUrl = 'https://api.giphy.com/v1/gifs';

  // --- API Keys ---
  static const String _giphyApiKey = 'RB1H3wfbZiBjmPHDwA3yqjoY7tuhjmOU';

  static const Duration _timeoutDuration = Duration(seconds: 30);

  ApiClient._();

  // 1. APIs DE JSONPLACEHOLDER (Simulación de Backend Propio)
  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final url = Uri.parse('$_baseUrl/todos');
      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = jsonDecode(response.body);
        return decodedJson.cast<Map<String, dynamic>>();
      } else {
        debugPrint(
            'Error fetchTasks: Status Code ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error (fetchTasks): $e');
      return [];
    } on FormatException catch (e) {
      debugPrint('JSON Decode Error (fetchTasks): $e');
      return [];
    } on Exception catch (e) {
      debugPrint('Unexpected Error (fetchTasks): $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final url = Uri.parse('$_baseUrl/users');
      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = jsonDecode(response.body);
        return decodedJson.cast<Map<String, dynamic>>();
      } else {
        debugPrint(
            'Error fetchUsers: Status Code ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error (fetchUsers): $e');
      return [];
    } on FormatException catch (e) {
      debugPrint('JSON Decode Error (fetchUsers): $e');
      return [];
    } on Exception catch (e) {
      debugPrint('Unexpected Error (fetchUsers): $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final url = Uri.parse('$_baseUrl/posts');
      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = jsonDecode(response.body);
        return decodedJson.cast<Map<String, dynamic>>();
      } else {
        debugPrint(
            'Error fetchPosts: Status Code ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error (fetchPosts): $e');
      return [];
    } on FormatException catch (e) {
      debugPrint('JSON Decode Error (fetchPosts): $e');
      return [];
    } on Exception catch (e) {
      debugPrint('Unexpected Error (fetchPosts): $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> fetchTaskById(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/todos/$id');
      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = jsonDecode(response.body);
        return decodedJson;
      } else {
        debugPrint(
            'Error fetchTaskById: Status Code ${response.statusCode} - ${response.reasonPhrase}');
        return {};
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error (fetchTaskById): $e');
      return {};
    } on FormatException catch (e) {
      debugPrint('JSON Decode Error (fetchTaskById): $e');
      return {};
    } on Exception catch (e) {
      debugPrint('Unexpected Error (fetchTaskById): $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> fetchUserById(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$id');
      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = jsonDecode(response.body);
        return decodedJson;
      } else {
        debugPrint(
            'Error fetchUserById: Status Code ${response.statusCode} - ${response.reasonPhrase}');
        return {};
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error (fetchUserById): $e');
      return {};
    } on FormatException catch (e) {
      debugPrint('JSON Decode Error (fetchUserById): $e');
      return {};
    } on Exception catch (e) {
      debugPrint('Unexpected Error (fetchUserById): $e');
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    try {
      final url = Uri.parse('$_baseUrl/posts/$postId/comments');
      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = jsonDecode(response.body);
        return decodedJson.cast<Map<String, dynamic>>();
      } else {
        debugPrint(
            'Error fetchComments: Status Code ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error (fetchComments): $e');
      return [];
    } on FormatException catch (e) {
      debugPrint('JSON Decode Error (fetchComments): $e');
      return [];
    } on Exception catch (e) {
      debugPrint('Unexpected Error (fetchComments): $e');
      return [];
    }
  }

  // 2. APIs EXTERNAS (Giphy para Foros y Posts)

  /// Busca GIFs en la API de Giphy en base a una palabra clave.
  /// Retorna una lista de URLs de imágenes optimizadas para móvil.
  static Future<List<String>> fetchGifs(String query, {int limit = 15}) async {
    if (query.trim().isEmpty) return [];

    try {
      // Usamos el endpoint de búsqueda con clasificación 'g' (apto para todo público)
      final url = Uri.parse(
          '$_giphyBaseUrl/search?api_key=$_giphyApiKey&q=$query&limit=$limit&rating=g');
      final response = await http.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = jsonDecode(response.body);
        final List<dynamic> data = decodedJson['data'];

        // Mapeamos el JSON para extraer solo la URL directa del GIF en tamaño reducido (mejor rendimiento)
        return data
            .map((gif) => gif['images']['fixed_height_small']['url'] as String)
            .toList();
      } else {
        debugPrint(
            'Error fetchGifs: Status Code ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } on http.ClientException catch (e) {
      debugPrint('Network Error (fetchGifs): $e');
      return [];
    } on FormatException catch (e) {
      debugPrint('JSON Decode Error (fetchGifs): $e');
      return [];
    } on Exception catch (e) {
      debugPrint('Unexpected Error (fetchGifs): $e');
      return [];
    }
  }
}

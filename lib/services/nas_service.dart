import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../env/env.dart';

class NasService {
  // Sostituire con l'IP locale del PC se testato su un dispositivo fisico.
  // 10.0.2.2 è per l'emulatore Android.
  // Es: static const String _baseUrl = 'http://192.168.1.31:8000/api';
  static const String _baseUrl =
      'https://noncorroborating-lawson-overdiverse.ngrok-free.dev/api';

  static final Map<String, String> _headers = {
    'ngrok-skip-browser-warning': 'true',
    'X-API-Key': Env.nasApiKey,
  };

  static Future<List<dynamic>> getCompiti() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/compiti'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print('Errore fetch compiti dal NAS: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getVerifiche() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/verifiche'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print('Errore fetch verifiche dal NAS: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getTrascrizioni() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/trascrizioni'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print('Errore fetch trascrizioni dal NAS: $e');
    }
    return [];
  }

  static Future<bool> uploadAudio(File audioFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-audio'),
      );
      request.headers.addAll({'ngrok-skip-browser-warning': 'true', 'X-API-Key': Env.nasApiKey});
      request.files.add(
        await http.MultipartFile.fromPath('file', audioFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Errore Upload Audio: $e');
      return false;
    }
  }
}

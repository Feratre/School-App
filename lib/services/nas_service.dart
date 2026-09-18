import 'dart:convert';
import 'package:http/http.dart' as http;

class NasService {
  // Sostituire con l'IP locale del PC se testato su un dispositivo fisico.
  // 10.0.2.2 è per l'emulatore Android.
  // Es: static const String _baseUrl = 'http://192.168.1.31:8000/api';
  static const String _baseUrl = 'https://noncorroborating-lawson-overdiverse.ngrok-free.dev/api';

  static Future<List<dynamic>> getCompiti() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/compiti'));
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
      final res = await http.get(Uri.parse('$_baseUrl/verifiche'));
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
      final res = await http.get(Uri.parse('$_baseUrl/trascrizioni'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print('Errore fetch trascrizioni dal NAS: $e');
    }
    return [];
  }
}

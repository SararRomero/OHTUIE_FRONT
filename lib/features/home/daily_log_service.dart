import 'dart:convert';
import '../../core/network/api_client.dart';
import '../auth/auth_service.dart';

class DailyLogService {
  static Future<Map<String, dynamic>> getDailyLog(DateTime date) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.get('/daily-logs/$dateStr', token: token);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'data': null,
        };
      }
      return {
        'success': false,
        'message': 'Error al obtener registro: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> saveDailyLog(Map<String, dynamic> data) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.post('/daily-logs/', data, token: token);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      }
      return {
        'success': false,
        'message': 'Error al guardar registro: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}

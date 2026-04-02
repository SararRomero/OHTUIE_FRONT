import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../auth/auth_service.dart';
import '../../../core/utils/error_handler.dart';


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
        'message': ErrorHandler.translate(e),
      };
    }
  }

  static Future<Map<String, dynamic>> saveDailyLog(Map<String, dynamic> data) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.post('/daily-logs', data, token: token);
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
        'message': ErrorHandler.translate(e),
      };
    }
  }

  static Future<Map<String, dynamic>> getMoodLibrary() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.get('/daily-logs/moods/library', token: token);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      }
      return {
        'success': false,
        'message': 'Error al obtener librería de ánimos: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': ErrorHandler.translate(e),
      };
    }
  }

  static Future<Map<String, dynamic>> getMoodStats(DateTime start, DateTime end) async {
    final startStr = "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    final endStr = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.get('/daily-logs/stats/moods?start_date=$startStr&end_date=$endStr', token: token);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      }
      return {
        'success': false,
        'message': 'Error al obtener estadísticas de ánimos: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}

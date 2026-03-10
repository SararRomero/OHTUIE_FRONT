import 'dart:convert';
import '../../core/network/api_client.dart';
import '../auth/auth_service.dart';

class CycleHistoryService {
  static Future<Map<String, dynamic>> getCycleHistory() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.get("/cycles/", token: token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": "Error al obtener el historial"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  static Future<Map<String, dynamic>> getPredictionStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.get("/cycles/prediction", token: token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": "Error al obtener estadísticas"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
}

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
        return {"success": false, "message": "Error al obtener el historial (${response.statusCode})"};
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
        return {"success": false, "message": "Error al obtener estadísticas (${response.statusCode})"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteCycle(String id) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.deleteDirect("/cycles/$id", token: token);
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": "Error al eliminar el ciclo (${response.statusCode})"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteCyclesBatch(List<String> ids) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.post("/cycles/delete-batch", {"ids": ids}, token: token);
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        String msg = "Error al eliminar los ciclos";
        try {
          final data = jsonDecode(response.body);
          msg = data['detail']?.toString() ?? data['message']?.toString() ?? msg;
          // If it's a list (FastAPI validation error), join it
          if (data['detail'] is List) {
            msg = (data['detail'] as List).map((e) => e['msg']).join(", ");
          }
        } catch (_) {}
        return {"success": false, "message": "$msg (${response.statusCode})"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteAllCycles() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.deleteDirect("/cycles/clear-history", token: token);
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": "Error al limpiar el historial (${response.statusCode})"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
}

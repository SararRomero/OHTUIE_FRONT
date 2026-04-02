import 'dart:convert';
import '../../core/network/api_client.dart';
import '../auth/auth_service.dart';

class HomeService {
  static Map<String, dynamic>? _lastPrediction;

  static void clearCache() {
    _lastPrediction = null;
  }

  static Future<Map<String, dynamic>> getCycles() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.get("/cycles", token: token);
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": "Error al obtener ciclos"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  static Future<Map<String, dynamic>> getPredictions() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.get("/cycles/prediction", token: token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _lastPrediction = data;
        return {"success": true, "data": data};
      } else {
        // Return cached data if available even on error
        if (_lastPrediction != null) {
          return {"success": true, "data": _lastPrediction};
        }
        return {"success": false, "message": "Error al obtener predicciones"};
      }
    } catch (e) {
      if (_lastPrediction != null) {
        return {"success": true, "data": _lastPrediction};
      }
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  static Future<Map<String, dynamic>> saveCycle(DateTime startDate, {DateTime? endDate}) async {
    try {
      final token = await AuthService.getToken();
      final Map<String, dynamic> data = {
        "start_date": startDate.toIso8601String().split('T')[0],
        "notes": "Actualización manual"
      };
      if (endDate != null) {
        data["end_date"] = endDate.toIso8601String().split('T')[0];
      }
      
      final response = await ApiClient.post("/cycles", data, token: token);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        print("Error saving cycle. Status: ${response.statusCode}, Body: ${response.body}");
        return {"success": false, "message": "Error al guardar el ciclo: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateCycle(String id, DateTime startDate, {DateTime? endDate}) async {
    try {
      final token = await AuthService.getToken();
      final Map<String, dynamic> data = {
        "start_date": startDate.toIso8601String().split('T')[0],
        "notes": "Actualización manual"
      };
      if (endDate != null) {
        data["end_date"] = endDate.toIso8601String().split('T')[0];
      }
      
      final response = await ApiClient.putDirect("/cycles/$id", data, token: token);
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        print("Error updating cycle. Status: ${response.statusCode}, Body: ${response.body}");
        return {"success": false, "message": "Error al actualizar el ciclo: ${response.statusCode}"};
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
        return {"success": true, "message": "Ciclo eliminado correctamente"};
      } else {
        return {"success": false, "message": "Error al eliminar el ciclo: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
}

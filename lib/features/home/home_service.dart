import 'dart:convert';
import '../../core/network/api_client.dart';
import '../auth/auth_service.dart';

class HomeService {
  static Future<Map<String, dynamic>> getPredictions() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiClient.get("/cycles/prediction", token: token);
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": "Error al obtener predicciones"};
      }
    } catch (e) {
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
      
      final response = await ApiClient.post("/cycles/", data, token: token);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "message": "Error al guardar el ciclo"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
}

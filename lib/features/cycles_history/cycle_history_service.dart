import 'dart:convert';
import '../auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/error_handler.dart';


class CycleHistoryService {
  static Future<Map<String, dynamic>> getCycles({int skip = 0, int limit = 100}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {"success": false, "message": "No token found"};

      final response = await ApiClient.get("/cycles/?skip=$skip&limit=$limit", token: token);
      
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Failed to fetch cycles"};
      }
    } catch (e) {
      return {"success": false, "message": ErrorHandler.translate(e)};
    }
  }

  static Future<Map<String, dynamic>> getPrediction() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {"success": false, "message": "No token found"};

      final response = await ApiClient.get("/cycles/prediction", token: token);
      
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Failed to fetch prediction"};
      }
    } catch (e) {
      return {"success": false, "message": ErrorHandler.translate(e)};
    }
  }

  static Future<Map<String, dynamic>> deleteCycle(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {"success": false, "message": "No token found"};

      final response = await ApiClient.deleteDirect("/cycles/$id", token: token);
      
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Failed to delete cycle"};
      }
    } catch (e) {
      return {"success": false, "message": ErrorHandler.translate(e)};
    }
  }

  static Future<Map<String, dynamic>> deleteAllCycles() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {"success": false, "message": "No token found"};

      final response = await ApiClient.deleteDirect("/cycles/clear-history", token: token);
      
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Failed to clear history"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}

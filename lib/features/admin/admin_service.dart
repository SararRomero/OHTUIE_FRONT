import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';

class AdminService {
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await ApiClient.get("/admin/statistics", token: token);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": jsonDecode(response.body)
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error['detail'] ?? "Error fetching statistics"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e"
      };
    }
  }

  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await ApiClient.get("/users/", token: token);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": jsonDecode(response.body)
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error['detail'] ?? "Error fetching users"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e"
      };
    }
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await ApiClient.putDirect("/users/$userId", data, token: token);

      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Error updating user"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await ApiClient.deleteDirect("/users/$userId", token: token);
      
      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Error deleting user"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> verifyAdminPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await ApiClient.post("/admin/verify-password", {"password": password}, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Contraseña incorrecta"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}

// Extension to ApiClient if needed, or I should update ApiClient.dart

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
}

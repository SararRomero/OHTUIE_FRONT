import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/auth_service.dart';
import '../../core/network/api_client.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserMe() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {"success": false, "message": "No token found"};

      final response = await ApiClient.get("/users/me", token: token);
      
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Failed to fetch profile"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateUserMe({
    String? fullName,
    String? email,
    String? password,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {"success": false, "message": "No token found"};

      final Map<String, dynamic> body = {};
      if (fullName != null) body["full_name"] = fullName;
      if (email != null) body["email"] = email;
      if (password != null) body["password"] = password;

      // ApiClient.putDirect handles the PUT request
      final response = await ApiClient.putDirect("/users/me", body, token: token);
      
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Failed to update profile"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}

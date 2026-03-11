import 'dart:convert';
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

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {"success": false, "message": "No token found"};

      final body = {
        "current_password": currentPassword,
        "new_password": newPassword,
      };

      final response = await ApiClient.putDirect("/users/me/password", body, token: token);
      
      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Failed to update password"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<bool> verifyPassword(String password) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final body = {"current_password": password, "new_password": "placeholder"};

      final response = await ApiClient.post("/users/me/verify-password", body, token: token);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> deleteUserMe() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {"success": false, "message": "No token found"};

      final response = await ApiClient.deleteDirect("/users/me", token: token);
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {"success": true, "message": "User deleted successfully"};
      } else {
        String errorMsg = "Failed to delete account";
        try {
          if (response.body.isNotEmpty) {
            final error = jsonDecode(response.body);
            errorMsg = error['detail'] ?? errorMsg;
          }
        } catch (_) {}
        return {"success": false, "message": errorMsg};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}

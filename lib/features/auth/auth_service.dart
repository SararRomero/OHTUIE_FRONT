import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiClient.postForm("/login/access-token", {
        "username": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        // Fetch user profile to get role
        final profileResponse = await ApiClient.get("/users/me", token: token);
        String role = "user";
        if (profileResponse.statusCode == 200) {
          final profileData = jsonDecode(profileResponse.body);
          role = profileData['role'] ?? "user";
          await prefs.setString('user_role', role);
        }
        
        return {"success": true, "token": token, "role": role};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    DateTime? birthday,
    DateTime? cycleStartDate,
    int? cycleDuration,
    int? periodDuration,
  }) async {
    try {
      final response = await ApiClient.post("/users/open", {
        "user": {
          "email": email,
          "password": password,
          "full_name": fullName,
          "birthday": birthday?.toIso8601String().split('T')[0],
        },
        "cycle_start_date": cycleStartDate?.toIso8601String().split('T')[0],
        "cycle_duration": cycleDuration,
        "period_duration": periodDuration,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Signup failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> recoverPassword(String email) async {
    try {
      final response = await ApiClient.post("/auth/password-recovery/$email", {});
      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Error sending recovery code"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.post("/auth/reset-password", {
        "email": email,
        "code": code,
        "new_password": newPassword,
      });
      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['detail'] ?? "Error resetting password"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

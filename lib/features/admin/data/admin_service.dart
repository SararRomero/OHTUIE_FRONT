import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/network/api_client.dart';

class AdminService {
  static Future<Map<String, dynamic>> getSecurityStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await ApiClient.get("/admin/security-stats", token: token);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": jsonDecode(response.body)
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error['detail'] ?? "Error fetching security statistics"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e"
      };
    }
  }

  static Future<Map<String, dynamic>> getStatistics({
    String? fStart, String? fEnd,
    String? rStart, String? rEnd,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      String url = "/admin/statistics";
      List<String> params = [];
      if (fStart != null) params.add("f_start=$fStart");
      if (fEnd != null) params.add("f_end=$fEnd");
      if (rStart != null) params.add("r_start=$rStart");
      if (rEnd != null) params.add("r_end=$rEnd");
      
      if (params.isNotEmpty) {
        url += "?${params.join("&")}";
      }
      
      final response = await ApiClient.get(url, token: token);
      
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

  static Future<Map<String, dynamic>> getUserCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await ApiClient.get("/users/counts", token: token);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": jsonDecode(response.body)
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error['detail'] ?? "Error fetching user counts"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e"
      };
    }
  }

  static Future<Map<String, dynamic>> getUsers({int page = 1, int limit = 20, String status = "all", String? search}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final skip = (page - 1) * limit;
      String url = "/users?skip=$skip&limit=$limit&status=$status";
      if (search != null && search.isNotEmpty) {
        url += "&search=${Uri.encodeComponent(search)}";
      }
      final response = await ApiClient.get(url, token: token);
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

  static Future<Map<String, dynamic>> exportUsersToExcel() async {
    try {
      // 1. Fetch all users
      final result = await getUsers(page: 1, limit: 1000);
      if (!result['success']) return result;

      List users;
      final rawData = result['data'];
      
      if (rawData is List) {
        users = rawData;
      } else if (rawData is Map) {
        // If it's a map, try to find the list of users
        // common keys: 'users', 'data', 'items'
        users = (rawData['users'] ?? rawData['data'] ?? rawData['items'] ?? []) as List;
      } else {
        users = [];
      }
      
      // 2. Create Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Usuarios'];
      excel.delete('Sheet1'); // Remove default sheet

      // Add Headers
      sheetObject.appendRow([
        TextCellValue('Nombre Completo'),
        TextCellValue('Email / Gmail'),
      ]);

      // Add Data
      for (var user in users) {
        sheetObject.appendRow([
          TextCellValue(user['name'] ?? 'N/A'),
          TextCellValue(user['email'] ?? 'N/A'),
        ]);
      }

      // Add Total Count row
      sheetObject.appendRow([]); // Empty row
      sheetObject.appendRow([
        TextCellValue('Total de Usuarios:'),
        IntCellValue(users.length),
      ]);

      // 3. Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/reporte_usuarios_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final fileBytes = excel.save();
      
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        
        // 4. Open file
        await OpenFilex.open(filePath);
        
        return {
          "success": true, 
          "message": "Reporte exportado exitosamente",
          "path": filePath
        };
      } else {
        return {"success": false, "message": "Error al generar el archivo Excel"};
      }
    } catch (e) {
      return {"success": false, "message": "Error durante la exportación: $e"};
    }
  }
}

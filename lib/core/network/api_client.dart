import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://192.168.50.20:8000";
  static const String apiV1 = "/api/v1";

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final url = Uri.parse("$baseUrl$apiV1$endpoint");
    final defaultHeaders = {"Content-Type": "application/json"};
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    print("Sending POST to $url with body: $body");
    return await http.post(
      url,
      headers: defaultHeaders,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> postForm(String endpoint, Map<String, String> body) async {
    final url = Uri.parse("$baseUrl$apiV1$endpoint");
    print("Sending POST Form to $url with body: $body");
    return await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: body,
    ).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse("$baseUrl$apiV1$endpoint");
    final headers = {"Content-Type": "application/json"};
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }
    print("Sending GET to $url");
    return await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
  }
}

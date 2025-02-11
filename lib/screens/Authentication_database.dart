import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure token storage

class ApiService {
  static const String baseUrl =
      'http://192.168.59.92:5000'; // Update for live server
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // User Signup
  Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print("Signup Response: ${response.body}");

      final responseData = json.decode(response.body);
      return response.statusCode == 201 && responseData["success"] == true
          ? responseData
          : {
              "success": false,
              "message": responseData["message"] ?? "Signup failed."
            };
    } catch (e) {
      print("Signup Exception: $e");
      return {"success": false, "message": "Network error. Please try again."};
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print("API request started...");
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: jsonEncode({"email": email, "password": password}),
        headers: {"Content-Type": "application/json"},
      );
      print("API request completed. Response received!");

      if (response.statusCode == 200) {
        print("API Response Body: ${response.body}");
        return jsonDecode(response.body);
      } else {
        print("API Error - Status Code: ${response.statusCode}");
        print("API Error - Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in API call: $e");
      return null;
    }
  }

  // Fetch Dashboard Data (Requires JWT)
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        return {"success": false, "message": "No token found. Please log in."};
      }

      final url = Uri.parse('$baseUrl/dashboard');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Dashboard Response: ${response.body}");
      return response.statusCode == 200
          ? json.decode(response.body)
          : {
              "success": false,
              "message": "Failed to fetch dashboard. Please try again."
            };
    } catch (e) {
      print("Dashboard Fetch Error: $e");
      return {"success": false, "message": "Network error."};
    }
  }

  // Logout (Clears Token)
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'token');
      print("Token deleted successfully!");
    } catch (e) {
      print("Logout Exception: $e");
    }
  }
}

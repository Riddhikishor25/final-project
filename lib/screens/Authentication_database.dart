import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure token storage

class ApiService {
  static const String baseUrl =
      'http://192.168.1.9:5000'; // Replace with your Flask app's URL if deployed
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Method for user signup (updated according to changes in Flask)
  Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username, // Updated field
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      // Success: Decode response if the backend returns token and status
      return json.decode(response.body);
    } else {
      // Handle different error statuses
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  // Method for user login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Decode the response body
      Map<String, dynamic> data = json.decode(response.body);
      await _secureStorage.write(
          key: 'token', value: data['token']); // Store the token securely

      // You can also access the username if needed
      String username = data['username'];
      print("Logged in as $username");

      return {
        'token': data['token'], // Return token
        'username': username, // Return username if you need it
      };
    } else {
      // Handle login error
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Method for accessing the dashboard (JWT required)
  Future<Map<String, dynamic>> getDashboard() async {
    final token = await _secureStorage.read(key: 'token'); // Read stored token
    if (token == null) {
      throw Exception('No token found');
    }

    final url = Uri.parse('$baseUrl/dashboard');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include JWT token in header
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Success
    } else {
      throw Exception('Failed to fetch dashboard: ${response.body}');
    }
  }

  // Method to logout (delete token)
  Future<void> logout() async {
    await _secureStorage.delete(key: 'token'); // Delete the stored token
  }
}

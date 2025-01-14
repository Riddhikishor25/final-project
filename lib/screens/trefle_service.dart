import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = 'W7YU9OS6f6et7vguVqcSHsyv7_RO7W3PRKpOLIsJWUs';
const String baseUrl = 'https://trefle.io/api/v1';

Future<List<dynamic>> searchPlantByCommonName(String commonName) async {
  final encodedName =
      Uri.encodeComponent(commonName); // URL encode the common name
  final url = '$baseUrl/plants/search?q=$encodedName&token=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      // Check if the response data is null or empty
      if (data == null || data.isEmpty) {
        throw Exception('No plants found for "$commonName"');
      }

      return data;
    } else {
      // Log the error response for debugging
      print('Failed to load data: ${response.body}');
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    // Catch any unexpected errors (e.g., network issues)
    print('Exception occurred: $e');
    throw Exception('Failed to load plant data: $e');
  }
}

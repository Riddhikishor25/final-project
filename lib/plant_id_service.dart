import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PlantIdService {
  final String apiKey = "8Hlh2zEWKWYzGWR6nwV2KXvLvMMIBFDHOHlAJasUN5cNLjdSsu";
  final String endpoint = "https://plant.id/api/v3/identification";

  Future<Map<String, dynamic>?> identifyPlant(File imageFile) async {
    try {
      // Convert the image to Base64
      String base64Image = base64Encode(imageFile.readAsBytesSync());

      // Prepare the request payload
      Map<String, dynamic> payload = {
        "images": [base64Image],
        "similar_images": true
      };

      // Set headers
      Map<String, String> headers = {
        "Api-Key":
            "8Hlh2zEWKWYzGWR6nwV2KXvLvMMIBFDHOHlAJasUN5cNLjdSsu", // Add "Bearer" followed by the API key
        "Content-Type": "application/json",
      };

      // Send POST request
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // Return parsed JSON response
      } else {
        print("Error: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}

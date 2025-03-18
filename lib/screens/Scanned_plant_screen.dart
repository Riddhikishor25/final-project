import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'plant_search_screen.dart';
import 'plant_detail_screen.dart';
import 'plant_id_service.dart'; // Import the PlantIdService class
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert'; // For base64 encoding
import 'dart:typed_data';
import 'package:image/image.dart' as img; // Import the image package
import 'package:path_provider/path_provider.dart'; // Import the path_provider package

class ScanPlantScreen extends StatefulWidget {
  @override
  _ScanPlantScreenState createState() => _ScanPlantScreenState();
}

class _ScanPlantScreenState extends State<ScanPlantScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final PlantIdService _plantIdService =
      PlantIdService(); // Create instance of PlantIdService

  // Function to choose image source (camera or gallery)
  Future<void> _chooseImageSource() async {
    print("Choosing image source..."); // Debugging

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                print("Camera option selected"); // Debugging
                pickImage(ImageSource.camera); // Pick from camera
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                print("Gallery option selected"); // Debugging
                pickImage(ImageSource.gallery); // Pick from gallery
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Scanning plant... Please wait."),
              ],
            ),
          );
        },
      );

      // Call the plant identification API
      PlantIdService plant_id = PlantIdService();
      var result = await plant_id.identifyPlant(_selectedImage!);

      // Close loading dialog
      Navigator.pop(context);

      if (result != null &&
          result['result']['classification']['suggestions'][0] != null &&
          result['result']['classification']['suggestions'][0].isNotEmpty) {
        String plantName =
            result['result']['classification']['suggestions'][0]['name'];

        // Fetch plant details from your API
        var plantData = await fetchPlantDetails(plantName);

        if (plantData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantDetailsScreen(
                plantName: plantData['name'],
                imageUrl: plantData['image']['value'] ?? '',
                plantDescription: plantData['description']['value'] ?? '',
                commonNames: List<String>.from(plantData['common_names'] ?? []),
                edibleParts: List<String>.from(plantData['edible_parts'] ?? []),
                propagationMethods:
                    List<String>.from(plantData['propagation_methods'] ?? []),
                watering: plantData['watering'] ?? {"min": 0, "max": 0},
                wikiUrl: plantData['url'] ?? '',
              ),
            ),
          );
        } else {
          _showErrorDialog("Plant Not Found",
              "We couldn't fetch the details for the plant.");
        }
      } else {
        _showErrorDialog(
            "Plant Not Identified", "Please try again with a clearer image.");
      }
    }
  }

// Function to show an error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<File?> _convertToJpeg(List<int> imageBytes) async {
    try {
      final img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
      if (image == null) {
        print("Error decoding image");
        return null;
      }

      // Encode the image to JPEG format
      List<int> jpegBytes = img.encodeJpg(image);

      // Convert List<int> to Uint8List
      Uint8List byteData = Uint8List.fromList(jpegBytes);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile
          .writeAsBytes(byteData); // Write the image as bytes to the file

      return tempFile;
    } catch (e) {
      print('Error converting image to JPEG: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> identifyPlantWithFlaskApi(
      File imageFile) async {
    final String apiUrl =
        'http://192.168.59.92:5000/identify-by-image'; // Flask API URL

    try {
      // Load the image and convert to a byte list
      //img.Image? image = img.decodeImage(await imageFile.readAsBytes());

      // Check if the image is null
      // if (image == null) {
      //  print("Error decoding image");
      // return null;
      // }

      // Encode image to JPEG format
      //List<int> jpegBytes = img.encodeJpg(image);

      // Convert List<int> to Uint8List
      //Uint8List byteData = Uint8List.fromList(jpegBytes);
      String base64Image = base64Encode(imageFile.readAsBytesSync());
      print(base64Image); // Debugging base64 string

      // Prepare the payload for the Flask backend
      var payload = {
        "images": "data:image/jpeg;base64," + base64Image,
        "latitude": 49.207,
        "longitude": 16.608,
        "similar_images": true
        // Ensuring proper format
      };
      // Debugging base64 string

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key':
              '9Lq9z0dToP2CLh1hK0r4gyz8dDYJzp3Wy2UmotaUnoM0FaCSrP', // Add your actual API key
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result;
      } else {
        print('Failed to identify plant: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error identifying plant: $e');
      return null;
    }
  }

  // Fetch plant details from the Flask API
  Future<Map<String, dynamic>?> fetchPlantDetails(String plantName) async {
    final String apiUrl =
        'http://192.168.59.92:5000/get-plant'; // Replace with your Flask API URL

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?name=$plantName'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // Return the plant details as a map
      } else {
        print('Failed to fetch plant details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching plant details: $e');
      return null;
    }
  }

  // Helper widget to build a plant tile
  Widget _buildPlantTile({
    required String imagePath,
    required String name,
    required String details,
    required Widget widgetBelow,
  }) {
    return Container(
      padding: const EdgeInsets.all(13.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  imagePath,
                  height: 75,
                  width: 75,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          widgetBelow,
        ],
      ),
    );
  }

  // Helper widget to display icons with labels inside a curved container
  Widget _buildCurvedWidget(IconData icon, String label,
      {bool showLabel = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 14),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Now add your first plant",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Identify plant with photo or search for common name, scientific name, or variety.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar and Scan Plant Button Side by Side
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlantSearchScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(
                            "Search for a plant...",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _chooseImageSource(),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    "Scan plant",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Curved Label for Common Houseplants
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Common houseplants",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Plant List
            Expanded(
              child: ListView(
                children: [
                  _buildPlantTile(
                    imagePath: 'assets/images/golden_pothos.jpg',
                    name: "Golden Pothos",
                    details: "Devil's Ivy, Money Plant, Ceylon Creeper",
                    widgetBelow: Row(
                      children: [
                        const SizedBox(width: 80),
                        _buildCurvedWidget(Icons.label_important, "Easy"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "Bright",
                            showLabel: false),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.wb_sunny, "Light",
                            showLabel: false),
                      ],
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/peace_lily.jpg',
                    name: "Peace Lily",
                    details: "Spathiphyllum",
                    widgetBelow: Row(
                      children: [
                        const SizedBox(width: 80),
                        _buildCurvedWidget(Icons.label_important, "Moderate"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "High Water",
                            showLabel: false),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.wb_sunny, "Low Light",
                            showLabel: false),
                      ],
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/monstera.jpg',
                    name: "Monstera",
                    details: "Swiss Cheese Plant",
                    widgetBelow: Row(
                      children: [
                        const SizedBox(width: 80),
                        _buildCurvedWidget(Icons.label_important, "Easy"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "Medium Water",
                            showLabel: false),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(
                            Icons.wb_sunny, "Bright Indirect Light",
                            showLabel: false),
                      ],
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/snake_plant.jpg',
                    name: "Snake Plant",
                    details: "Sansevieria, Mother-in-Law's Tongue",
                    widgetBelow: Row(
                      children: [
                        const SizedBox(width: 80),
                        _buildCurvedWidget(Icons.label_important, "Easy"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "Low Water",
                            showLabel: false),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(
                            Icons.wb_sunny, "Low to Bright Light",
                            showLabel: false),
                      ],
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/aloe_vera.jpg',
                    name: "Aloe Vera",
                    details: "Aloe barbadensis miller",
                    widgetBelow: Row(
                      children: [
                        const SizedBox(width: 80),
                        _buildCurvedWidget(Icons.label_important, "Easy"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "Low Water",
                            showLabel: false),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(
                            Icons.wb_sunny, "Bright Indirect Light",
                            showLabel: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

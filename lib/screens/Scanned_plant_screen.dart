import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'plant_search_screen.dart';

class ScanPlantScreen extends StatefulWidget {
  @override
  _ScanPlantScreenState createState() => _ScanPlantScreenState();
}

class _ScanPlantScreenState extends State<ScanPlantScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Pick image from the camera or gallery
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12.0),
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
                  height: 62,
                  width: 62,
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

  // Helper widget for labels
  Widget _buildCurvedWidget(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
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
          icon: Icon(Icons.close, color: Colors.black),
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
              "Identify plant with photo or search for common name, scientific name, or variety",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            // Scan Button and Navigate to Search
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
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
                    backgroundColor: Colors.green.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlantSearchScreen()),
                    );
                  },
                  child: const Text("Search Plant"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Common Houseplants",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildPlantTile(
                    imagePath: 'assets/images/golden_pothos.jpg',
                    name: "Golden Pothos",
                    details: "Devil's Ivy, Money Plant, Ceylon Creeper",
                    widgetBelow: Row(
                      children: [
                        _buildCurvedWidget(Icons.label_important, "Easy"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "Water"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.wb_sunny, "Light"),
                      ],
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/peace_lily.jpg',
                    name: "Peace Lily",
                    details: "Spathiphyllum",
                    widgetBelow: Row(
                      children: [
                        _buildCurvedWidget(Icons.label_important, "Moderate"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "High Water"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.wb_sunny, "Low Light"),
                      ],
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/monstera.jpg',
                    name: "Monstera",
                    details: "Swiss Cheese Plant",
                    widgetBelow: Row(
                      children: [
                        _buildCurvedWidget(Icons.label_important, "Easy"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "Medium Water"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(
                            Icons.wb_sunny, "Bright Indirect Light"),
                      ],
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/snake_plant.jpg',
                    name: "Snake Plant",
                    details: "Sansevieria, Mother-in-Law's Tongue",
                    widgetBelow: Row(
                      children: [
                        _buildCurvedWidget(Icons.label_important, "Easy"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "Low Water"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(
                            Icons.wb_sunny, "Low to Bright Light"),
                      ],
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/aloe_vera.jpg',
                    name: "Aloe Vera",
                    details: "Aloe barbadensis miller",
                    widgetBelow: Row(
                      children: [
                        _buildCurvedWidget(Icons.label_important, "Easy"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(Icons.water_drop, "Low Water"),
                        const SizedBox(width: 8),
                        _buildCurvedWidget(
                            Icons.wb_sunny, "Bright Indirect Light"),
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

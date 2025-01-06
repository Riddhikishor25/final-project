import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScanPlantScreen extends StatefulWidget {
  @override
  _ScanPlantScreenState createState() => _ScanPlantScreenState();
}

class _ScanPlantScreenState extends State<ScanPlantScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Matches the login screen
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
                color: Colors.green[500],
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              "Identify plant with photo or search for common name, scientific name, or variety",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            // Search Bar + Scan Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      hintText: "Search plants",
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    "Scan Plants",
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
              ],
            ),
            const SizedBox(height: 24),
            // Curved Label for Common Houseplants
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Common houseplants",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
                    name: 'Golden Pothos',
                    details: "Devil's Ivy, Money Plant, Ceylon Creeper",
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/monstera.jpg',
                    name: 'Monstera',
                    details:
                        "Swiss Cheese Plant, Fruit Salad Plant, Hurricane Plant",
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/snake_plant.jpg',
                    name: 'Snake Plant',
                    details:
                        "Mother-in-law's Tongue, Bowstring Hemp, Rufus Plant",
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/aloe_vera.jpg',
                    name: 'Aloe Vera',
                    details: "Medicinal Aloe, Barbados Aloe, Bitter Aloe",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantTile({
    required String imagePath,
    required String name,
    required String details,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(imagePath,
                height: 56, width: 56, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          // Text and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Icon Indicators
                Row(
                  children: [
                    _buildIconWithLabel(Icons.label_important, "Easy"),
                    const SizedBox(width: 12),
                    _buildIconWithLabel(Icons.water_drop, "Water"),
                    const SizedBox(width: 12),
                    _buildIconWithLabel(Icons.wb_sunny, "Light"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

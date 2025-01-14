import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'trefle_service.dart';

class ScanPlantScreen extends StatefulWidget {
  @override
  _ScanPlantScreenState createState() => _ScanPlantScreenState();
}

class _ScanPlantScreenState extends State<ScanPlantScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Pick image from the camera or gallery
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Search for plants based on the query
  Future<void> searchPlants() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final results =
          await searchPlantByCommonName(query); // Trefle API service
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Building a list tile for each plant in common houseplants section
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
        boxShadow: [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Image
              ClipOval(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(2.0),
                  child: Image.asset(
                    imagePath,
                    height: 62,
                    width: 62,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Text and Details
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
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Curved Label Widgets slightly adjusted to sit below name and description
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
                    controller: _searchController,
                    onSubmitted: (_) => searchPlants(),
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
            // Plant List (Static common houseplants)
            Expanded(
              child: ListView(
                children: [
                  _buildPlantTile(
                    imagePath: 'assets/images/golden_pothos.jpg',
                    name: "Golden Pothos",
                    details: "Devil's Ivy, Money Plant, Ceylon Creeper",
                    widgetBelow: Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const SizedBox(width: 80),
                          _buildCurvedWidget(Icons.label_important, "Easy",
                              showLabel: true),
                          const SizedBox(width: 8),
                          _buildCurvedWidget(Icons.water_drop, "Water",
                              showLabel: false),
                          const SizedBox(width: 8),
                          _buildCurvedWidget(Icons.wb_sunny, "Light",
                              showLabel: false),
                        ],
                      ),
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/monstera.jpg',
                    name: "Monstera",
                    details:
                        "Swiss Cheese Plant, Fruit Salad Plant, Hurricane Plant",
                    widgetBelow: Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          const SizedBox(width: 15),
                          _buildCurvedWidget(Icons.label_important, "Moderate",
                              showLabel: true),
                          const SizedBox(width: 8),
                          _buildCurvedWidget(Icons.water_drop, "Medium",
                              showLabel: false),
                          const SizedBox(width: 8),
                          _buildCurvedWidget(Icons.wb_sunny, "Bright",
                              showLabel: false),
                        ],
                      ),
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/snake_plant.jpg',
                    name: "Snake Plant",
                    details:
                        "Mother-in-law's Tongue, Bowstring Hemp, Rufus Plant",
                    widgetBelow: Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 80),
                          _buildCurvedWidget(Icons.label_important, "Low",
                              showLabel: true),
                          const SizedBox(width: 8),
                          _buildCurvedWidget(Icons.water_drop, "Dry",
                              showLabel: false),
                          const SizedBox(width: 8),
                          _buildCurvedWidget(Icons.wb_sunny, "Indirect",
                              showLabel: false),
                        ],
                      ),
                    ),
                  ),
                  _buildPlantTile(
                    imagePath: 'assets/images/aloe_vera.jpg',
                    name: "Aloe Vera",
                    details: "Medicinal Aloe, Barbados Aloe, Bitter Aloe",
                    widgetBelow: Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 80),
                          _buildCurvedWidget(Icons.label_important, "Easy",
                              showLabel: true),
                          const SizedBox(width: 8),
                          _buildCurvedWidget(Icons.water_drop, "Dry",
                              showLabel: false),
                          const SizedBox(width: 8),
                          _buildCurvedWidget(Icons.wb_sunny, "Bright",
                              showLabel: false),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Search Results
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final plant = _searchResults[index];
                            return ListTile(
                              title: Text(plant['common_name'] ?? 'Unknown'),
                              subtitle: Text(plant['scientific_name'] ?? ''),
                            );
                          },
                        ),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}

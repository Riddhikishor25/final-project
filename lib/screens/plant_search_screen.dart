import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'plant_detail_screen.dart'; // Import your PlantDetailsScreen

class PlantSearchScreen extends StatefulWidget {
  @override
  _PlantSearchScreenState createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends State<PlantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchPlantFromBackend(String plantName) async {
    final String backendUrl =
        "http://192.168.1.7:5000/get-plant?name=$plantName";

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey("error")) {
          print("❌ API Error: ${data["error"]}");
          return null;
        }
        print("🔍 Plant Data: $data"); // Debugging response
        return data;
      } else {
        print("❌ Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🔥 API Request Failed: $e");
      return null;
    }
  }

  Future<void> searchPlant() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _hasSearched = true;
    });

    final plantData = await fetchPlantFromBackend(query);

    if (plantData != null) {
      setState(() {
        _searchResults = [plantData];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // UI for household plants
  Widget _buildHouseholdPlants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Common Household Plants",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPlantTile(
          imagePath: 'assets/images/golden_pothos.jpg',
          name: "Golden Pothos",
          details: "Devil's Ivy, Money Plant, Ceylon Creeper",
          onTap: () {
            _navigateToPlantDetails("Golden Pothos");
          },
        ),
        _buildPlantTile(
          imagePath: 'assets/images/peace_lily.jpg',
          name: "Peace Lily",
          details: "Spathiphyllum",
          onTap: () {
            _navigateToPlantDetails("Peace Lily");
          },
        ),
        _buildPlantTile(
          imagePath: 'assets/images/monstera.jpg',
          name: "Monstera",
          details: "Swiss Cheese Plant",
          onTap: () {
            _navigateToPlantDetails("Monstera");
          },
        ),
        _buildPlantTile(
          imagePath: 'assets/images/snake_plant.jpg',
          name: "Snake Plant",
          details: "Sansevieria, Mother-in-Law's Tongue",
          onTap: () {
            _navigateToPlantDetails("Snake Plant");
          },
        ),
        _buildPlantTile(
          imagePath: 'assets/images/aloe_vera.jpg',
          name: "Aloe Vera",
          details: "Aloe barbadensis miller",
          onTap: () {
            _navigateToPlantDetails("Aloe Vera");
          },
        ),
      ],
    );
  }

  // UI for plant search results
  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
            child: Text(
              "No plant found.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          )
        : Column(
            children: _searchResults.map((plant) {
              final plantName = plant['query_name'] ?? 'Unknown Plant';
              final imageUrl =
                  (plant['image'] != null && plant['image']['value'] != null)
                      ? plant['image']['value']
                      : '';

              // Get top 3 or 4 common names
              final commonNames =
                  List<String>.from(plant['common_names'] ?? []);
              final topCommonNames =
                  commonNames.take(4).join(", "); // Take top 4 names

              // If common names are fewer than 4, we just show all available names
              final details = topCommonNames.isNotEmpty
                  ? topCommonNames
                  : "No common names available";

              return GestureDetector(
                onTap: () {
                  _navigateToPlantDetails(plantName);
                },
                child: _buildPlantTile(
                  imagePath: imageUrl.isNotEmpty
                      ? imageUrl
                      : 'assets/images/default_plant.jpg',
                  name: plantName,
                  details: details, // Show common names instead of description
                  isNetworkImage: imageUrl.isNotEmpty,
                  onTap: () {
                    _navigateToPlantDetails(plantName);
                  },
                ),
              );
            }).toList(),
          );
  }

  // Helper function to build plant tile (Supports Network & Local Images)
  Widget _buildPlantTile({
    required String imagePath,
    required String name,
    required String details,
    bool isNetworkImage = false, // Flag for network images
    required VoidCallback onTap, // On tap callback for navigation
  }) {
    return Container(
      padding: const EdgeInsets.all(13.0),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          ClipOval(
            child: isNetworkImage
                ? Image.network(
                    imagePath,
                    height: 75,
                    width: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default_plant.jpg',
                        height: 75,
                        width: 75,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    imagePath,
                    height: 75,
                    width: 75,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 15),

          // Prevents text overflow
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle navigation to PlantDetailsScreen
  void _navigateToPlantDetails(String plantName) async {
    final plantData = await fetchPlantFromBackend(plantName);

    if (plantData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetailsScreen(
            plantName: plantName,
            imageUrl: plantData['image']['value'] ?? '',
            plantDescription: plantData['description']?['value'] ?? '',
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
      // Handle null data case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch plant data.')),
      );
    }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.green[800]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search for a plant...",
                          border: InputBorder.none,
                        ),
                        onChanged: (query) {
                          if (query.isNotEmpty) {
                            setState(() {
                              _hasSearched = true;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.green[800]),
                      onPressed: searchPlant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Show "Common Household Plants" if no search results
              _hasSearched && !_isLoading && _searchResults.isEmpty
                  ? _buildHouseholdPlants()
                  : _buildSearchResults(),

              // Show loading spinner if searching
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

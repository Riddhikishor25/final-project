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
        "http://192.168.59.92:5000/get-plant?name=$plantName";

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
              // Search Bar with Cross Icon
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.green[800]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchResults.clear();
                              _hasSearched = false;
                            });
                          },
                        )
                      : null,
                  hintText: "Search for a plant...",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (_) => searchPlant(),
              ),
              const SizedBox(height: 20),
              _hasSearched && !_isLoading && _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        "No plant found.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : Column(
                      children: _searchResults.map((plant) {
                        final plantName =
                            plant['query_name'] ?? 'Unknown Plant';
                        final commonNames = (plant['common_names'] != null &&
                                plant['common_names'].isNotEmpty)
                            ? plant['common_names'].join(", ")
                            : 'No common names available';
                        final imageUrl = (plant['image'] != null &&
                                plant['image']['value'] != null)
                            ? plant['image']['value']
                            : '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlantDetailsScreen(
                                  plantName: plantName,
                                  imageUrl: imageUrl,
                                  plantDescription:
                                      plant['description']?['value'] ?? '',
                                  commonNames: List<String>.from(
                                      plant['common_names'] ?? []),
                                  edibleParts: List<String>.from(
                                      plant['edible_parts'] ?? []),
                                  propagationMethods: List<String>.from(
                                      plant['propagation_methods'] ?? []),
                                  watering:
                                      plant['watering'] ?? {"min": 0, "max": 0},
                                  wikiUrl: plant['url'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(13.0),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          height: 75,
                                          width: 75,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/default_plant.jpg',
                                          height: 75,
                                          width: 75,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plantName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        commonNames,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              if (_isLoading) Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

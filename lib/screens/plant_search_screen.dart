import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PlantSearchScreen extends StatefulWidget {
  @override
  _PlantSearchScreenState createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends State<PlantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Update UI when the search field changes
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to fetch plant details, including image, from the Plant.id API
  Future<Map<String, dynamic>> fetchPlantDetails(String accessToken) async {
    final String apiKey = '8Hlh2zEWKWYzGWR6nwV2KXvLvMMIBFDHOHlAJasUN5cNLjdSsu';
    final String detailsEndpoint =
        'https://plant.id/api/v3/kb/plants/$accessToken?details=common_names%2Curl%2Cdescription%2Ctaxonomy%2Crank%2Cgbif_id%2Cinaturalist_id%2Cimage%2Csynonyms%2Cedible_parts%2Cwatering%2Cpropagation_methods&language=en';

    int retryCount = 0;
    const maxRetries = 5;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse(detailsEndpoint),
          headers: {
            'Api-Key': apiKey,
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 429) {
          // Too Many Requests - Handle rate limiting
          retryCount++;
          final delay =
              Duration(seconds: (retryCount * 2)); // Exponential backoff
          print('Rate limit hit, retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        } else {
          print('Error fetching plant details: ${response.reasonPhrase}');
          break;
        }
      } catch (e) {
        print('Error: $e');
        break;
      }
    }
    return {};
  }

  // Remove duplicates based on unique access_token, matched_in, and matched_in_type
  void removeDuplicatePlants() {
    final seen = <String>{};
    _searchResults = _searchResults.where((plant) {
      final matchedIn = plant['matched_in'] ?? '';
      final accessToken = plant['access_token'] ?? '';
      final uniqueKey = '$matchedIn|$accessToken';

      if (seen.contains(uniqueKey)) {
        return false;
      } else {
        seen.add(uniqueKey);
        return true;
      }
    }).toList();
  }

  // Search for plants using the Plant Search API
  Future<void> searchPlants() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    final String apiUrl = 'https://plant.id/api/v3/kb/plants/name_search?q=';
    final String apiKey = '8Hlh2zEWKWYzGWR6nwV2KXvLvMMIBFDHOHlAJasUN5cNLjdSsu';

    try {
      final response = await http.get(
        Uri.parse('$apiUrl${Uri.encodeComponent(query)}'),
        headers: {
          'Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['entities'] ?? [];
          removeDuplicatePlants();
        });
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.black54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          // Update UI as the user types
                        });
                      },
                      onSubmitted: (_) => searchPlants(),
                      decoration: InputDecoration(
                        hintText: "Search plant",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.black54),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchResults = []; // Clear search results
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Results
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            "No plants found.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final plant = _searchResults[index];
                            final accessToken = plant['access_token'];

                            // Safe check for 'matched_in'
                            final plantName = plant['matched_in'] != null &&
                                    plant['matched_in'] is String
                                ? plant['matched_in']
                                : 'Unknown Plant';

                            // Fetch plant details (including image) for each plant
                            return FutureBuilder<Map<String, dynamic>>(
                              future: fetchPlantDetails(accessToken),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ListTile(
                                    leading: CircularProgressIndicator(),
                                    title: Text(plantName),
                                    subtitle: Text(plant['matched_in_type'] ??
                                        'Unknown Type'),
                                  );
                                }

                                final plantDetails = snapshot.data ?? {};
                                final imageUrl =
                                    plantDetails['image']?['value'] ?? '';

                                return ListTile(
                                  leading: ClipOval(
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            height: 55,
                                            width: 55,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.local_florist,
                                            size: 50,
                                            color: Colors.green,
                                          ),
                                  ),
                                  title: Text(
                                    plantName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    plant['matched_in_type'] ?? 'Unknown Type',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

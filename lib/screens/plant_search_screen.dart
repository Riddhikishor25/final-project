import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlantSearchScreen extends StatefulWidget {
  @override
  _PlantSearchScreenState createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends State<PlantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Search for plants using a Plant API
  Future<void> searchPlants() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    final String apiUrl = 'https://plant.id/api/v3/kb/plants/name_search?q=';
    final String apiKey =
        '8Hlh2zEWKWYzGWR6nwV2KXvLvMMIBFDHOHlAJasUN5cNLjdSsu'; // Replace with your actual API Key

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
                      onSubmitted: (_) => searchPlants(),
                      decoration: InputDecoration(
                        hintText: "Search plant",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.black54),
                    onPressed: () {},
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
                            return ListTile(
                              leading: ClipOval(
                                child: Image.network(
                                  plant['image_url'] ?? '',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    Icons.local_florist,
                                    size: 50,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              title: Text(
                                plant['matched_in'] ?? 'Unknown Plant',
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
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

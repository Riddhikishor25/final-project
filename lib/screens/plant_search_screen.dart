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
      appBar: AppBar(
        title: Text("Search Plants"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: (_) => searchPlants(),
              decoration: InputDecoration(
                hintText: "Enter plant name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final plant = _searchResults[index];
                        return ListTile(
                          title: Text(plant['matched_in'] ?? 'Unknown'),
                          subtitle:
                              Text(plant['matched_in_type'] ?? 'Unknown type'),
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

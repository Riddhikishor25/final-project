import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlantDetailsScreen extends StatelessWidget {
  final String plantName;
  final String imageUrl;
  final String plantDescription;
  final List<String> commonNames;
  final List<String> edibleParts;
  final List<String> propagationMethods;
  final int watering;
  final String wikiUrl;

  PlantDetailsScreen({
    required this.plantName,
    required this.imageUrl,
    required this.plantDescription,
    required this.commonNames,
    required this.edibleParts,
    required this.propagationMethods,
    required this.watering,
    required this.wikiUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stack for Image and Overlapping Description Box
            Stack(
              children: [
                // Background Image
                Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                // Other UI components for tags, close, and share button
                // Your existing code for these remains the same
              ],
            ),
            // White Description Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    plantDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Extra Plant Information
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Common Names"),
                  _buildList(commonNames),
                  _buildSectionTitle("Edible Parts"),
                  _buildList(edibleParts),
                  _buildSectionTitle("Watering Needs"),
                  Text(
                    watering == 1
                        ? "Minimal watering required"
                        : "Frequent watering needed",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  _buildSectionTitle("Propagation Methods"),
                  _buildList(propagationMethods),
                  SizedBox(height: 20),
                  _buildWikiButton(wikiUrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to Create Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[700]),
      ),
    );
  }

  // Helper to Build List of Items
  Widget _buildList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Text("• $item", style: TextStyle(fontSize: 16)))
          .toList(),
    );
  }

  // Helper to Create Wikipedia Button
  Widget _buildWikiButton(String url) {
    return ElevatedButton.icon(
      onPressed: () => _launchURL(url),
      icon: Icon(Icons.open_in_browser),
      label: Text("Read More on Wikipedia"),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700], foregroundColor: Colors.white),
    );
  }

  // Launch URL
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString(), forceWebView: true, enableJavaScript: true);
    } else {
      throw "Could not launch $url";
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavouritePlantsScreen extends StatefulWidget {
  final String username;

  FavouritePlantsScreen({required this.username});

  @override
  _FavouritePlantsScreenState createState() => _FavouritePlantsScreenState();
}

class _FavouritePlantsScreenState extends State<FavouritePlantsScreen> {
  List<Map<String, dynamic>> favoritePlants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoritePlants();
  }

  Future<void> fetchFavoritePlants() async {
    final String apiUrl =
        'http://192.168.59.92:5000/get_favorites?username=${widget.username}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData.containsKey('favorites') &&
            decodedData['favorites'] is List) {
          setState(() {
            favoritePlants =
                List<Map<String, dynamic>>.from(decodedData['favorites']);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
        print('Error: Failed to load favorites');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Favourite Plants 🌿",
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoritePlants.isEmpty
              ? buildEmptyState()
              : buildPlantList(),

      // ✅ Floating Scan Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () {
          Navigator.pop(context);
        },
        child: Image.asset(
          'assets/icons/scan_icon.png',
          width: 150, // Adjust size as needed
          height: 150,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ Bottom Navigation Bar (Restored)
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFDCE4C7),
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.grey),
                onPressed: () {
                  Navigator.pop(context); // Navigate back to HomeScreen
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite, color: Colors.green[900]),
                onPressed: () {}, // Already on Favorite screen
              ),
              SizedBox(width: 40), // Space for FloatingActionButton
              IconButton(
                icon: Icon(Icons.local_florist, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/empty_favorites.png",
          height: 200,
        ),
        SizedBox(height: 20),
        Text(
          "Your garden is empty! 🌱",
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Start adding your favorite plants to build your dream garden. 🌿",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.green[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPlantList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Plants you love make your world greener! 🍃",
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: favoritePlants.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  color: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        favoritePlants[index]['image_url'] ??
                            'https://via.placeholder.com/150',
                      ),
                    ),
                    title: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        favoritePlants[index]['plant_name'] ?? 'Unknown plant',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class PlantListScreen extends StatefulWidget {
  final String username;

  PlantListScreen({required this.username});

  @override
  _PlantListScreenState createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  List<Map<String, dynamic>> plants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyPlants();
  }

  Future<void> fetchMyPlants() async {
    final response = await http.get(
      Uri.parse(
          "http://192.168.1.7:5000/get_my_plants?username=${widget.username}"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey("my_plants")) {
        setState(() {
          plants = List<Map<String, dynamic>>.from(data["my_plants"]);
          isLoading = false;
        });
      }
    } else {
      print("❌ Failed to fetch plants: ${response.statusCode}");
      setState(() {
        isLoading = false;
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
        title: Text(
          "My Plants 🌿",
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : plants.isEmpty
              ? buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your beautiful garden awaits! 🌿",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: plants.length,
                          itemBuilder: (context, index) {
                            return buildPlantCard(plants[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // 🌱 **Build Plant Card**
  Widget buildPlantCard(Map<String, dynamic> plant) {
    return GestureDetector(
      onTap: () {
        showCareScheduleBottomSheet(context, plant);
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 🌿 Plant Image
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(
                  plant['image_url'] ?? 'https://via.placeholder.com/150',
                ),
                onBackgroundImageError: (_, __) =>
                    Icon(Icons.image, color: Colors.grey),
              ),
              SizedBox(width: 16),

              // 🌿 Plant Name & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant['plant_name'] ?? "Unknown Plant",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tap to view care schedule",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
            ],
          ),
        ),
      ),
    );
  }

  // 🌱 **Empty State UI**
  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/empty_plants.png", height: 200),
          SizedBox(height: 20),
          Text(
            "No plants added yet! 🌱",
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Start growing your garden by adding plants. 🌿",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(180, 48),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Add Plants",
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🌱 **Build Care Info Tile with Custom Icons**
  Widget buildCareInfoTile(String title, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[900]),
          // 🟢 Custom icon for each task
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: ${value ?? 'Not Available'}",
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

// 🌱 **Show Care Schedule Bottom Sheet**
  void showCareScheduleBottomSheet(
      BuildContext context, Map<String, dynamic> plant) {
    Map<String, dynamic>? careSchedule = plant['care_schedule'];

    showModalBottomSheet(
      backgroundColor: Color(0xFFDCE4C7),
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 10),

              // 🌱 Plant Name
              Text(
                "${plant['plant_name']} - Care Guide",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.green[900],
                ),
              ),
              SizedBox(height: 15),

              // 🌱 Display Care Details with Icons
              buildCareInfoTile(
                  " Watering", careSchedule?['watering'], Icons.water_drop),
              buildCareInfoTile(
                  "Sunlight", careSchedule?['sunlight'], Icons.wb_sunny),
              buildCareInfoTile(
                  "Fertilizing",
                  "${careSchedule?['fertilizing']?['frequency']} (${careSchedule?['fertilizing']?['best_time']})",
                  Icons.eco),
              buildCareInfoTile(
                  "Pruning",
                  "${careSchedule?['pruning']?['frequency']} (${careSchedule?['pruning']?['best_time']})",
                  Icons.content_cut),

              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 48),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Close",
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

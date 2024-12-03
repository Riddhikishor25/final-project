import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantName;
  final String plantAge;
  final int health;
  final String plantImage;

  const PlantDetailScreen({
    required this.plantName,
    required this.plantAge,
    required this.health,
    required this.plantImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/plant_screen_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // "Detail Plant" Text on the Background
          Positioned(
            top: 112,
            left: 27,
            child: Text(
              "Detail Plant",
              style: GoogleFonts.lato(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
          ),

          // Water and Fertilizer Status Cards on Background
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusCard(
                  title: "Water",
                  status: "Bad",
                  percentage: "20%",
                  color: Colors.redAccent,
                ),
                _StatusCard(
                  title: "Fertilizer",
                  status: "Good",
                  percentage: "20%",
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Daily Task Section on Background
          Positioned(
            bottom: 92,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Task",
                  style: GoogleFonts.lato(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100
                        .withOpacity(0.7), // Background with slight opacity
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Water the plant",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Status Card Widget
class _StatusCard extends StatelessWidget {
  final String title;
  final String status;
  final String percentage;
  final Color color;

  const _StatusCard({
    required this.title,
    required this.status,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4, // Adjust width
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherCard extends StatelessWidget {
  final String location;
  final int temperature;
  final String weatherDescription;
  final String backgroundImage;

  const WeatherCard({
    required this.location,
    required this.temperature,
    required this.weatherDescription,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          // Background Image Container (smaller size)
          Container(
            height: 150, // Adjusted height for the card
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(15), // Slightly smaller border radius
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover, // Ensure image fits without stretching
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          // Weather Information Overlay
          Container(
            height: 150, // Match the background container height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black
                  .withOpacity(0.2), // Slightly dark overlay for contrast
            ),
            padding: EdgeInsets.all(12), // Slightly reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Text Row
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: Colors.green[800],
                        size: 22), // Smaller icon size
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      location,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Smaller font size for location
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8), // Adjust spacing
                // Temperature Text
                Text(
                  "$temperature°C",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35, // Smaller font size for temperature
                  ),
                ),
                // Weather Description Text
                Text(
                  weatherDescription,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Smaller font size for description
                  ),
                ),
              ],
            ),
          ),
          // Arrow Icon at the top-right corner of the stack (slightly lower)
          Align(
            alignment:
                Alignment(1, -0.3), // Shift the arrow down a bit (Y: -0.3)
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18, // Smaller arrow icon size
              ),
            ),
          ),
        ],
      ),
    );
  }
}

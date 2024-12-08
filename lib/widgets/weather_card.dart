import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherCard extends StatefulWidget {
  final String location;

  const WeatherCard({required this.location});

  @override
  _WeatherCardState createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late Future<Map<String, dynamic>> _weatherData;

  @override
  void initState() {
    super.initState();
    _weatherData = fetchWeatherData(widget.location);
  }

  Future<Map<String, dynamic>> fetchWeatherData(String location) async {
    const String apiKey =
        '9c70a4631add50cb22594b3934b54109'; // Replace with your API key
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _weatherData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error fetching weather data',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (snapshot.hasData) {
          final weather = snapshot.data!;
          final temperature = weather['main']['temp'].toInt();
          final description = weather['weather'][0]['description'];
          final weatherIconCode = weather['weather'][0]['icon'];
          final weatherIconUrl =
              'http://openweathermap.org/img/wn/$weatherIconCode@2x.png';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(weatherIconUrl),
                      fit: BoxFit.cover,
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
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.green[800], size: 22),
                          SizedBox(width: 8),
                          Text(
                            widget.location,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "$temperature°C",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

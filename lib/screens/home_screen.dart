import 'package:flutter/material.dart';
import '../widgets/plant_card.dart';
import '../widgets/weather_card.dart'; // Importing WeatherCard widget
import 'package:google_fonts/google_fonts.dart';
import '../screens/scanned_plant_screen.dart'; // Importing ScanPlantScreen
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart'; // Import the weather_icons package

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = "Mumbai"; // Default city
  String temperature = "Loading...";
  String weatherCondition = "";
  String greeting = "Good afternoon"; // Default greeting

  @override
  void initState() {
    super.initState();
    fetchWeather(city);
    setGreeting(); // Call method to update greeting based on time
  }

  void setGreeting() {
    final currentHour = DateTime.now().hour;

    if (currentHour < 12) {
      greeting = "Good morning!";
    } else if (currentHour < 18) {
      greeting = "Good afternoon!";
    } else {
      greeting = "Good evening!";
    }
  }

  Future<void> fetchWeather(String city) async {
    final String apiKey = '9c70a4631add50cb22594b3934b54109';
    final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

    try {
      final url = Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = "${data['main']['temp']}°C";
          weatherCondition = data['weather'][0]['description'];
        });
      } else {
        setState(() {
          temperature = "Error fetching weather";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "Failed to load weather";
      });
    }
  }

  // Custom method to map weather condition to a specific icon
  Icon getWeatherIcon(String condition) {
    switch (condition) {
      case 'clear sky':
        return Icon(WeatherIcons.day_sunny); // Clear sky icon
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'overcast clouds':
        return Icon(WeatherIcons.day_cloudy); // Cloudy icon
      case 'light rain':
      case 'moderate rain':
      case 'heavy intensity rain':
      case 'very heavy rain':
      case 'extreme rain':
      case 'freezing rain':
        return Icon(WeatherIcons.day_rain); // Rain icon
      case 'thunderstorm with light rain':
      case 'thunderstorm with heavy rain':
      case 'thunderstorm with hail':
        return Icon(WeatherIcons.day_thunderstorm); // Thunderstorm icon
      case 'light snow':
      case 'snow':
      case 'heavy snow':
        return Icon(WeatherIcons.day_snow); // Snow icon
      case 'sleet':
        return Icon(WeatherIcons.day_sleet); // Sleet icon
      case 'light intensity drizzle':
      case 'drizzle':
      case 'heavy intensity drizzle':
        return Icon(WeatherIcons.day_sprinkle); // Drizzle icon
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'fog':
        return Icon(WeatherIcons.day_fog); // Mist, smoke, haze, or fog icon
      case 'sand':
      case 'dust':
      case 'ash':
        return Icon(WeatherIcons.day_windy); // Windy (sand, dust, or ash) icon
      default:
        return Icon(WeatherIcons.na); // Default icon if condition doesn't match
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.green[900]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.green[900]),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting, // Display dynamic greeting
              style: GoogleFonts.roboto(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            Text(
              "Your plants are so glad you are here. It's Plant care time!",
              style: GoogleFonts.roboto(
                fontSize: 18,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Weather Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        getWeatherIcon(weatherCondition.toLowerCase())
                            .icon, // Updated weather icon
                        color: Colors.green[700],
                        size: 25,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$city",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                          Text(
                            "$temperature",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            "$weatherCondition",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the ScanPlantScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScanPlantScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: Text(
                  "Add Plant",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

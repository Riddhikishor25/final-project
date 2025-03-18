import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'Scanned_plant_screen.dart';
import 'PlantListScreen.dart'; // Add this import
import 'FavouritePlantsScreen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  HomeScreen({required this.username});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = "Fetching...";
  String temperature = "Loading...";
  String greeting = "Good afternoon";
  List<String> funFacts = ["Loading fun facts..."];

  Timer? _funFactTimer;
  final PageController _funFactController =
      PageController(viewportFraction: 0.85, initialPage: 1000);

  List<Map<String, dynamic>> myPlants = []; // Store the plant data

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    fetchFunFacts();
    setGreeting();
    fetchMyPlants();

    // ✅ Run after UI is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showWelcomePopup();
      }
    });
  }

  @override
  void dispose() {
    _funFactTimer?.cancel();
    _funFactController.dispose();
    super.dispose();
  }

  void setGreeting() {
    final currentHour = DateTime.now().hour;
    if (currentHour < 12) {
      greeting = "Good morning!";
    } else if (currentHour < 18) {
      greeting = "Good afternoon!";
    } else {
      greeting = "Good night!";
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => city = "Enable GPS");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        setState(() => city = "Location Denied");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    getCityName(position.latitude, position.longitude);
    fetchWeather(position.latitude, position.longitude);
  }

  Future<void> getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        setState(() => city = placemarks[0].locality ?? "Unknown");
      }
    } catch (e) {
      setState(() => city = "Error");
    }
  }

  Future<void> fetchWeather(double latitude, double longitude) async {
    final String apiKey = '9c70a4631add50cb22594b3934b54109';
    final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

    try {
      final url = Uri.parse(
          '$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => temperature = "${data['main']['temp']}°C");
      } else {
        setState(() => temperature = "Error fetching weather");
      }
    } catch (e) {
      setState(() => temperature = "Failed to load weather");
    }
  }

  void _startFunFactTimer() {
    _funFactTimer?.cancel();
    _funFactTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && _funFactController.hasClients) {
        _funFactController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchFunFacts() async {
    final String funFactApiUrl = 'http://192.168.59.92:5000/get_fun_fact';

    try {
      final response = await http.get(Uri.parse(funFactApiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            funFacts = data.map((fact) => fact['fact'].toString()).toList();
          });
          _startFunFactTimer();
        }
      } else {
        if (mounted) {
          setState(() => funFacts = ["Error: Failed to load fun facts."]);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => funFacts = ["Error fetching fun facts: $e"]);
      }
    }
  }

  Future<void> fetchMyPlants() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.59.92:5000/get_my_plants?username=${widget.username}'));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        final List<dynamic> plantsData = decodedData['my_plants'];

        if (mounted) {
          setState(() {
            myPlants = plantsData.map((plant) {
              return {
                'name': plant['plant_name'],
                'imageUrl': plant['image_url'],
              };
            }).toList();
          });
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // ✅ Function to show welcome message as a popup
  void _showWelcomePopup() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text("Welcome Back!"),
          content:
              Text("Hello, ${widget.username}! 🌱 Your plants missed you!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close popup
              child: Text("Okay", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.green[900]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              Text(
                "Your plants are so glad you are here. It's Plant care time!",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 20),
              // Weather Widget
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFDCE4C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud, color: Colors.green[900]),
                    SizedBox(width: 10),
                    Text(
                      "$city  $temperature",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Fun Facts Carousel
              SizedBox(
                height: 140,
                child: PageView.builder(
                  controller: _funFactController,
                  itemBuilder: (context, index) {
                    final actualIndex = index % funFacts.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFDCE4C7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Did You Know?",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              funFacts[actualIndex],
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.green[800],
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              // Add Plant Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 48),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScanPlantScreen()));
                },
                child: Text("Add Plant",
                    style:
                        GoogleFonts.roboto(fontSize: 16, color: Colors.white)),
              ),
              SizedBox(height: 20),
              // My Plants Section (Only One Plant + Show More)
              if (myPlants.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Plants",
                      style: GoogleFonts.roboto(
                        fontSize: 22, // Slightly larger heading
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    SizedBox(height: 12),

                    // **Increased Card Size**
                    Container(
                      height: 100, // Increased height of the card
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        color: Color(0xFFDCE4C7),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // More rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              16.0), // More padding inside card
                          child: Row(
                            children: [
                              // Plant Image (Same size)
                              CircleAvatar(
                                radius: 28, // Keep image size same
                                backgroundImage: NetworkImage(
                                  myPlants[0]['imageUrl'] ??
                                      'https://via.placeholder.com/150',
                                ),
                              ),
                              SizedBox(
                                  width: 16), // Space between image and text
                              // Plant Name
                              Expanded(
                                child: Text(
                                  myPlants[0]['name'] ?? 'Unknown plant',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18, // Keep font same
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Show More button if there are more than one plant
                    if (myPlants.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[900],
                              textStyle: GoogleFonts.roboto(
                                fontSize: 18, // Keep font same
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlantListScreen(
                                      username: widget.username),
                                ),
                              );
                            },
                            child: Text("Show More"),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      // Floating Scan Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ScanPlantScreen()));
        },
        child: Image.asset(
          'assets/icons/scan_icon.png',
          width: 150, // Adjust size as needed
          height: 150,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation Bar
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
                icon: Icon(Icons.home, color: Colors.green[900]),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FavouritePlantsScreen(username: widget.username)),
                  );
                },
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
}

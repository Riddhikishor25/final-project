import 'package:flutter/material.dart';
import '../widgets/plant_card.dart';
import '../widgets/weather_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  // Define a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Open the drawer using the key
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text('Riddhi'),
              accountEmail: Text('riddhi@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text('R', style: TextStyle(color: Colors.white)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                // Navigate to profile screen
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Community'),
              onTap: () {
                // Navigate to community screen
                Navigator.pushNamed(context, '/community');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to settings screen
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () {
                // Log out action
                Navigator.pop(context); // Close the drawer
                // You can add your log out functionality here
              },
            ),
            Divider(),
            // About section or any other options you want to add
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                // Navigate to About screen
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Full Background Image Section
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio:
                        16 / 16, // Adjust the ratio to match your design
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height *
                          0.4, // 40% of the screen height
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/gardening.jpg'),
                          fit: BoxFit.cover, // Ensures no cropping of the image
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 201,
                    left: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, Riddhi",
                          style: GoogleFonts.cabin(
                            fontSize: 47,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[970],
                          ),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(50, 50), // Increase button height
                            padding: EdgeInsets.symmetric(
                                vertical: 25, horizontal: 38),
                          ),
                          onPressed: () {
                            // Add plant action
                          },
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text("Add a plant",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Main Content Section
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Your Plant",
                            style: GoogleFonts.lato(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        PlantCard(
                          plantName: "Sunflower",
                          plantAge: "12 weeks old",
                          health: 72,
                          plantImage: "assets/images/sunflower.jpeg",
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: const WeatherCard(
                            location: "Mumbai, India",
                            temperature: 20,
                            weatherDescription: "Mostly clear",
                            backgroundImage: "assets/images/Weather_bg.jpg",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 3,
            left: MediaQuery.of(context).size.width / 2 - 28, // Center FAB
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {},
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {},
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'My Plant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing),
            label: 'Diagnose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/plant_card.dart';
import '../widgets/weather_card.dart'; // Import your WeatherCard widget
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
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
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Community'),
              onTap: () => Navigator.pushNamed(context, '/community'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () => Navigator.pop(context),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 16,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/gardening.jpg'),
                          fit: BoxFit.cover,
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
                            color: Colors.green[900],
                          ),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(50, 50),
                            padding: EdgeInsets.symmetric(
                                vertical: 25, horizontal: 38),
                          ),
                          onPressed: () {},
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
                          child: WeatherCard(
                            location: "Himachal Pradesh",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

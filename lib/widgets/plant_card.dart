import 'package:flutter/material.dart';
import '../screens/plant_detail_screen.dart';

class PlantCard extends StatelessWidget {
  final String plantName;
  final String plantAge;
  final int health;
  final String plantImage;

  const PlantCard({
    required this.plantName,
    required this.plantAge,
    required this.health,
    required this.plantImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailScreen(
              plantName: plantName,
              plantAge: plantAge,
              health: health,
              plantImage: plantImage,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.green.shade900,
            image: DecorationImage(
              image: AssetImage(plantImage),
              fit: BoxFit.cover,
              opacity: 0,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(plantImage),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            title: Text(
              plantName,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              plantAge,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            trailing: Text(
              "$health%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade500,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

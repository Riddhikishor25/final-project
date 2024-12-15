import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../plant_id_service.dart';

class ScanPlantScreen extends StatefulWidget {
  @override
  _ScanPlantScreenState createState() => _ScanPlantScreenState();
}

class _ScanPlantScreenState extends State<ScanPlantScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _plantName;
  bool _isLoading = false;

  final PlantIdService _plantIdService = PlantIdService();

  // Function to pick an image from the camera or gallery
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      identifyPlant();
    }
  }

  // Function to display the image source selection dialog
  Future<void> showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> identifyPlant() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _plantName = null;
    });

    final response = await _plantIdService.identifyPlant(_selectedImage!);
    if (response != null) {
      print('hello');
      print(response);
      setState(() {
        _plantName =
            response['result']['classification']['suggestions'][0]['name'];
        _isLoading = false;
      });
    } else {
      print('hello2');
      print(response);
      setState(() {
        _plantName = "Plant could not be identified.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan a Plant"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text("No image selected"),
                    ),
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: showImageSourceDialog,
              child: Text("Upload or Take a Photo"),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _plantName != null
                    ? Text(
                        "Plant Identified: $_plantName",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

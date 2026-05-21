import 'package:flutter/material.dart';
import 'package:sltnoc/home_page.dart'; // Import home page file

class ImagePage extends StatelessWidget {
  final String displayName;
  const ImagePage({Key? key, required this.displayName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0), // Adjust the right margin as needed
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.white, size: 30),
        onPressed: () {
          // Navigate to the SettingsPage when the settings icon is tapped
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(displayName:displayName)));
        },
      ),
    );
  }
}

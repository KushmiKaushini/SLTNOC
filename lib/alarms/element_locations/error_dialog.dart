import 'package:flutter/material.dart';

class ErrorBottomSheet extends StatelessWidget {
  final String elementName;
  final String site;

  const ErrorBottomSheet({
    Key? key,
    required this.elementName,
    required this.site,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Error', style: TextStyle(fontSize: 0.05 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.bold, color: Colors.black)),
              Spacer(), // Add a spacer to push the close button to the right corner
              GestureDetector( // Use GestureDetector for handling tap events
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: Icon(
                  Icons.cancel, // Use cancel icon
                  color: Colors.grey.shade400, // Adjust the icon color as needed
                  // color: Colors.red,
                  size: 20, // Adjust the icon size as needed
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'No Geo Coordinates found!',
            style: TextStyle(
              fontSize: 0.037 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Divider(color: Colors.grey.shade300),
          // const SizedBox(height: 16),
          const SizedBox(height: 8),
          _buildText2(context, 'MSAN:', elementName),
          // Divider(color: Colors.grey.shade300),
          const SizedBox(height: 8),
          _buildText2(context, 'Site:', site),
        ],
      ),
    );
  }
}

Widget _buildText2(context, String label, String value) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 0.037 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 0.037 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w500, color: Color(0xFF0056A2)),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    ],
  );
}
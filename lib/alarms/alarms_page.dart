// alarms_page.dart

import 'package:flutter/material.dart';
import 'package:sltnoc/alarms/current_alarms/alarms_options.dart';
import 'package:sltnoc/alarms/element_locations/elements_location1.dart';
import 'package:sltnoc/alarms/update_element_locations/update_elements_location1.dart';
import 'package:sltnoc/alarms/elements_map/elementsMap1.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/settings_button.dart';

class AlarmsPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String newSubtitle;

  const AlarmsPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.newSubtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title:  Text(title, style: TextStyle(fontSize: 0.045 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppConfig.appBarBG,
        toolbarHeight: 0.13 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          SettingsButton(),
        ],
      ),
      body: Container(
        // color: AppConfig.BodyBG, // Background color
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig.bodyBackgroundImagePath), // Replace 'background_image.jpg' with your image path
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.tablePagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyCard(
                        title: 'ALARMS',
                        subtitle: 'Current Alarms',
                        newSubtitle: 'Source: EMS / NMS',
                        borderColor: const Color(0xFF0056A2),
                        page: 'current alarms',
                        onTap: () {
                          // Navigate to the Current Alarms Page when the alarms card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AlarmsOptionsPage()));
                        },
                      ),
                      MyCard(
                        title: 'ELEMENT LOCATIONS',
                        subtitle: 'Element Locations in Google Map',
                        newSubtitle: 'Source: Network Engineers',
                        borderColor: const Color(0xFF0056A2),
                        page: 'element locations',
                        onTap: () {
                          // Navigate to the Element Locations Page when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ElementsLocationPage()));
                        },
                      ),
                      MyCard(
                        title: 'UPDATE ELEMENT LOCATION',
                        subtitle: 'Update Element GPS',
                        newSubtitle: 'Source: Network Engineers',
                        borderColor: const Color(0xFF0056A2),
                        page: 'update element location',
                        onTap: () {
                          // Navigate to the Current Alarms Page when the alarms card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateElementsLocationPage()));
                        },
                      ),
                      MyCard(
                        title: 'ELEMENTS MAP',
                        subtitle: 'Elements on Google Map',
                        newSubtitle: 'Source: Network Engineers',
                        borderColor: const Color(0xFF0056A2),
                        page: 'elements map',
                        onTap: () {
                          // Navigate to the Current Alarms Page when the alarms card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const elementsMapPage()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class MyCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String newSubtitle;
//   final Color borderColor;
//   final String page;
//   final VoidCallback onTap; // Add onTap parameter
//
//   const MyCard({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//     required this.newSubtitle,
//     required this.borderColor,
//     required this.page,
//     required this.onTap, // Include onTap in the constructor
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap, // Use the provided onTap callback
//       splashColor: Colors.white,
//       child: Card(
//         margin: const EdgeInsets.symmetric(vertical: 20),
//         shape: RoundedRectangleBorder(
//           side: BorderSide(color: borderColor, width: 1.5),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         color: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.black),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 subtitle,
//                 style: const TextStyle(color: Color(0xFF0056A2), fontSize: 20, fontWeight: FontWeight.w500),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 newSubtitle,
//                 style: const TextStyle(color: Color(0xFF50B748), fontSize: 20, fontWeight: FontWeight.w500),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


class MyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String newSubtitle;
  final Color borderColor;
  final String page;
  final VoidCallback onTap; // Add onTap parameter

  const MyCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.newSubtitle,
    required this.borderColor,
    required this.page,
    required this.onTap, // Include onTap in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: onTap, // Use the provided onTap callback
      splashColor: Colors.white,
      child: Card(
        elevation: AppConfig.elevation,
        margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        // color: Colors.white,
        color: Colors.transparent, // Set card color to transparent
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig.cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
              fit: BoxFit.cover, // Adjust the fit as needed
          ),
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius), // Match card's border radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              _buildIcon(context),
              const SizedBox(width: AppConfig.widthBetweenIconAndContent), // Add spacing between icon and text
              // Title, subtitle, and newSubtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 0.042 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                    const SizedBox(height: AppConfig.lineSpacing),
                    Text(
                      subtitle,
                      style: TextStyle(color: Color(0xFF0056A2), fontSize: 0.037 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: AppConfig.lineSpacing),
                    Text(
                      newSubtitle,
                      style: TextStyle(color: Colors.green, fontSize: 0.037 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(AppConfig.forwardIcon, size: AppConfig.forwardIconSize, color: AppConfig.forwardIconColor), // Adjust size and color as needed
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // Define the icon size
    double iconSize = 0.08 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight);
    Color? iconColor = AppConfig.iconColor;

    switch (title) {
      case 'ALARMS':
        return Icon(Icons.notifications, size: iconSize, color: iconColor);
      case 'ELEMENT LOCATIONS':
        return Icon(Icons.location_on, size: iconSize, color: iconColor);
      case 'UPDATE ELEMENT LOCATION':
        return Icon(Icons.add_location, size: iconSize, color: iconColor);
      case 'ELEMENTS MAP':
        return Icon(Icons.map, size: iconSize, color: iconColor);
      default:
        return SizedBox.shrink(); // Return an empty SizedBox if the title does not match any case
    }
  }
}

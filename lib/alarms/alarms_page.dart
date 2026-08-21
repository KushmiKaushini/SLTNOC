// alarms_page.dart

import 'package:flutter/material.dart';
import 'package:sltnoc/alarms/current_alarms/alarms_options.dart' hide MyCard;
import 'package:sltnoc/alarms/element_locations/elements_location1.dart';
import 'package:sltnoc/alarms/update_element_locations/update_elements_location1.dart';
import 'package:sltnoc/alarms/elements_map/elementsMap1.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/widgets/my_card.dart';

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
        title: Text(title,
            style: TextStyle(
                fontSize: 0.045 *
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenWidth
                        : screenHeight),
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppConfig.appBarBG,
        toolbarHeight: 0.13 *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? screenWidth
                : screenHeight),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          SettingsButton(),
        ],
      ),
      body: Container(
        // color: AppConfig.BodyBG, // Background color
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig
                .bodyBackgroundImagePath), // Replace 'background_image.jpg' with your image path
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
                      MyCard.list(
                        title: 'ALARMS',
                        subtitle: 'Current Alarms',
                        newSubtitle: 'Source: EMS / NMS',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to the Current Alarms Page when the alarms card is clicked
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AlarmsOptionsPage()));
                        },
                      ),
                      MyCard.list(
                        title: 'ELEMENT LOCATIONS',
                        subtitle: 'Element Locations in Google Map',
                        newSubtitle: 'Source: Network Engineers',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to the Element Locations Page when the card is clicked
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ElementsLocationPage()));
                        },
                      ),
                      MyCard.list(
                        title: 'UPDATE ELEMENT LOCATION',
                        subtitle: 'Update Element GPS',
                        newSubtitle: 'Source: Network Engineers',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to the Current Alarms Page when the alarms card is clicked
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const UpdateElementsLocationPage()));
                        },
                      ),
                      MyCard.list(
                        title: 'ELEMENTS MAP',
                        subtitle: 'Elements on Google Map',
                        newSubtitle: 'Source: Network Engineers',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to the Current Alarms Page when the alarms card is clicked
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const elementsMapPage()));
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

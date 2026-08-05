import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/alarms/current_alarms/regions.dart';
import 'package:sltnoc/alarms/current_alarms/alarms_by_alarm_types.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

import 'current_alarms.dart';

class AlarmsOptionsPage extends StatefulWidget {
  const AlarmsOptionsPage({Key? key}) : super(key: key);

  @override
  _AlarmsOptionsPageState createState() => _AlarmsOptionsPageState();
}

class _AlarmsOptionsPageState extends State<AlarmsOptionsPage> {
  List<String> regions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarms Categories',
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConfig.bodyBackgroundImagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: Scrollbar(
              // Wrap ListView.builder with Scrollbar widget
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.tablePagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Add the new card widget here
                            MyCard(
                              title: 'Alarms by NW Engineers',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CurrentAlarmsPage(province: 'ALL'),
                                  ),
                                );
                              },
                              borderColor: Colors.blue,
                              height: 150,
                              icon: Icons
                                  .people_alt, // Specify the icon for this card
                            ),
                            MyCard(
                              title: 'Alarms by Regions',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegionsPage(),
                                  ),
                                );
                              },
                              borderColor: Colors.blue,
                              height: 150,
                              icon: Icons
                                  .public, // Specify the icon for this card
                            ),
                            MyCard(
                              title: 'Alarms by Alarm Types',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AlarmsByAlarmTypesPage(),
                                  ),
                                );
                              },
                              borderColor: Colors.blue,
                              height: 150,
                              icon: Icons
                                  .notifications, // Specify the icon for this card
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) CustomLoadingIndicator(),
        ],
      ),
    );
  }
}

class MyCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color borderColor;
  final double height;
  final IconData icon; // Add this line

  const MyCard({
    Key? key,
    required this.title,
    required this.onTap,
    required this.borderColor,
    required this.height,
    required this.icon, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white,
      child: Card(
        elevation: AppConfig.elevation,
        margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig.cardBackgroundImagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.metroCardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon,
                    size: AppConfig.iconSize,
                    color: AppConfig.iconColor), // Updated line
                const SizedBox(width: AppConfig.widthBetweenIconAndContent),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 0.042 *
                                (MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? screenWidth
                                    : screenHeight),
                            fontWeight: FontWeight.w800,
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Icon(AppConfig.forwardIcon,
                    size: AppConfig.forwardIconSize,
                    color: AppConfig.forwardIconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

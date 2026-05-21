// escalations_page.dart

import 'package:flutter/material.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/escalations/FAULTS/faults.dart';
import 'package:sltnoc/escalations/Planned Events/planned_events.dart';
import 'package:sltnoc/escalations/Problems/problems.dart';
import 'package:sltnoc/escalations/Common Issues/common_issues.dart';

class EscalationsPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String newSubtitle;

  const EscalationsPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.newSubtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppConfig.appBarTextStyle),
        centerTitle: true,
        backgroundColor: AppConfig.appBarBG,
        toolbarHeight: AppConfig.toolbarHeight,
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
                        title: 'FAULTS',
                        subtitle: 'Fault Escalation',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: Color(0xFF0056A2),
                        page: 'faults',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const faultsPage(title: 'FAULTS',)));
                        },
                      ),
                      MyCard(
                        title: 'PLANNED EVENTS',
                        subtitle: 'Network Maintenance Activities',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: Color(0xFF0056A2),
                        page: 'planned events',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const plannedEventsPage(title: 'PLANNED EVENTS',)));
                        },
                      ),
                      MyCard(
                        title: 'PROBLEMS',
                        subtitle: 'Network Related Problems',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: Color(0xFF0056A2),
                        page: 'problems',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const problemsPage(title: 'PROBLEMS',)));
                        },
                      ),
                      MyCard(
                        title: 'COMMON ISSUES',
                        subtitle: 'Common Issues',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: Color(0xFF0056A2),
                        page: 'common issues',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const commonIssuesPage(title: 'COMMON ISSUES',)));
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
      case 'FAULTS':
        return Icon(Icons.report_problem, size: iconSize, color: iconColor);
      case 'PLANNED EVENTS':
        return Icon(Icons.event, size: iconSize, color: iconColor);
      case 'PROBLEMS':
        return Icon(Icons.error, size: iconSize, color: iconColor);
      case 'COMMON ISSUES':
        return Icon(Icons.help, size: iconSize, color: iconColor);
      default:
        return SizedBox.shrink(); // Return an empty SizedBox if the title does not match any case
    }
  }
}
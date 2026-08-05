// clarity_page.dart

import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/clarity/work_groups/work_groups1.dart';
import 'package:sltnoc/clarity/CEN-CSC-NW/cen-csc-nw.dart';
import 'package:sltnoc/clarity/CEN-CSC-DATA/cen-csc-data.dart';
import 'package:sltnoc/clarity/CEN-CSC-CC/cen-csc-cc.dart';
//
import 'package:sltnoc/clarity/CEN-CSC-MS/cen-csc-ms.dart';
//
import 'package:sltnoc/clarity/Service-Order-Details/service_order_details.dart';
import 'package:sltnoc/clarity/CLARITY NW FAULTS/clarity-nw-faults.dart';
import 'package:sltnoc/app_config.dart';

class ClarityPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String newSubtitle;

  const ClarityPage({
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
                        title: 'CLARITY NW FAULTS',
                        subtitle: 'Pending Network Faults',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        page: 'clarity nw faults',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ClarityNwFaultsPage(title: 'CLARITY NW FAULTS',)));
                        },
                      ),
                      MyCard(
                        title: 'CEN-CSC-DATA',
                        subtitle: 'Pending Clarity Fault Dockets',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        page: 'cen csc data',
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const cenCscDataPage(title: 'CEN-CSC-DATA',)));
                        },
                      ),
                      MyCard(
                        title: 'CEN-CSC-NW',
                        subtitle: 'Pending Clarity Fault Dockets',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        page: 'cen csc nw',
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const cenCscNwPage(title: 'CEN-CSC-NW',)));
                        },
                      ),
                      MyCard(
                        title: 'CEN-CSC-CC',
                        subtitle: 'Pending Clarity Fault Dockets',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        page: 'cen csc cc',
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const cenCscCCPage(title: 'CEN-CSC-CC',)));
                        },
                      ),
                      //
                      MyCard(
                        title: 'CEN-CSC-MS',
                        subtitle: 'Pending Clarity Fault Dockets',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        page: 'cen csc ms',
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const cenCscmsPage(title: 'CEN-CSC-MS',)));
                        },
                      ),
                      //
                      MyCard(
                        title: 'WORK GROUPS',
                        subtitle: 'Pending Work Orders',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        page: 'work groups',
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkGroupsPage()));
                        },
                      ),
                      MyCard(
                        title: 'SERVICE ORDER DETAILS',
                        subtitle: 'CCT Details',
                        newSubtitle: 'Source: Clarity',
                        borderColor: const Color(0xFF0056A2),
                        page: 'serviceOrder',
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceOrderDetailsPage()));
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
      case 'CLARITY NW FAULTS':
        return Icon(Icons.report, size: iconSize, color: iconColor);
      case 'CEN-CSC-NW':
        return Icon(Icons.error, size: iconSize, color: iconColor);
      case 'CEN-CSC-DATA':
        return Icon(Icons.error_outline, size: iconSize, color: iconColor);
      case 'CEN-CSC-CC':
        return Icon(Icons.report_gmailerrorred_outlined, size: iconSize, color: iconColor);
      case 'CEN-CSC-MS':
        return Icon(Icons.error, size: iconSize, color: iconColor);  
      case 'WORK GROUPS':
        return Icon(Icons.group, size: iconSize, color: iconColor);
      case 'SERVICE ORDER DETAILS':
        return Icon(Icons.data_thresholding, size: iconSize, color: iconColor);
      default:
        return SizedBox.shrink(); // Return an empty SizedBox if the title does not match any case
    }
  }
}

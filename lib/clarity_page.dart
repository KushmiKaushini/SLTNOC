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
import 'package:sltnoc/widgets/my_card.dart';

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
                      MyCard.list(
                        title: 'CLARITY NW FAULTS',
                        subtitle: 'Pending Network Faults',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ClarityNwFaultsPage(title: 'CLARITY NW FAULTS',)));
                        },
                      ),
                      MyCard.list(
                        title: 'CEN-CSC-DATA',
                        subtitle: 'Pending Clarity Fault Dockets',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const cenCscDataPage(title: 'CEN-CSC-DATA',)));
                        },
                      ),
                      MyCard.list(
                        title: 'CEN-CSC-NW',
                        subtitle: 'Pending Clarity Fault Dockets',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const cenCscNwPage(title: 'CEN-CSC-NW',)));
                        },
                      ),
                      MyCard.list(
                        title: 'CEN-CSC-CC',
                        subtitle: 'Pending Clarity Fault Dockets',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const cenCscCCPage(title: 'CEN-CSC-CC',)));
                        },
                      ),
                      //
                      MyCard.list(
                        title: 'CEN-CSC-MS',
                        subtitle: 'Pending Clarity Fault Dockets',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const cenCscmsPage(title: 'CEN-CSC-MS',)));
                        },
                      ),
                      //
                      MyCard.list(
                        title: 'WORK GROUPS',
                        subtitle: 'Pending Work Orders',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          // Navigate to WorkGroupsPage when the card is clicked
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkGroupsPage()));
                        },
                      ),
                      MyCard.list(
                        title: 'SERVICE ORDER DETAILS',
                        subtitle: 'CCT Details',
                        newSubtitle: 'Source: Clarity',
                        borderColor: const Color(0xFF0056A2),
                        badgeCount: 0,
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

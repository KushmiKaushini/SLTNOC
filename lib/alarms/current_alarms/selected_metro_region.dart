// import 'package:flutter/material.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:sltnoc/alarms/current_alarms/current_alarms.dart';
// import 'package:sltnoc/app_config.dart';
//
// class SelectedMetroRegionPage extends StatefulWidget {
//   final String title;
//
//   const SelectedMetroRegionPage({Key? key, required this.title}) : super(key: key);
//
//   @override
//   _SelectedMetroRegionPageState createState() => _SelectedMetroRegionPageState();
// }
//
// class _SelectedMetroRegionPageState extends State<SelectedMetroRegionPage> {
//   List<String> provinces = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchProvinces();
//   }
//
//   Future<void> fetchProvinces() async {
//     // final String apiUrl = 'http://192.168.1.11:3000/api/provinces/data/${widget.title}';
//     // final String apiUrl = 'http://192.168.1.100:3000/api/provinces/data/${widget.title}';
//     final String apiUrl = 'http://192.168.1.8:3000/api/provinces/data/${widget.title}';
//
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           provinces = List<String>.from(jsonData);
//         });
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (error) {
//       print('Error: $error');
//       // Handle error appropriately, e.g., show an error message to the user
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title, style: AppConfig.appBarTextStyle),
//         centerTitle: true,
//         backgroundColor: AppConfig.appBarBG,
//         toolbarHeight: AppConfig.toolbarHeight,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: const [
//           SettingsButton(),
//         ],
//       ),
//       body: Container(
//       // color: AppConfig.BodyBG, // Background color
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(AppConfig.bodyBackgroundImagePath), // Replace 'background_image.jpg' with your image path
//             fit: BoxFit.cover, // Adjust the fit as needed
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(AppConfig.tablePagePadding),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//             // const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: provinces.length,
//                 itemBuilder: (context, index) {
//                   return MyCard(
//                     title: provinces[index],
//                     onTap: () {
//                       // Navigate to CurrentAlarmsPage with the selected province
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const CurrentAlarmsPage(),
//                           // builder: (context) => CurrentAlarmsPage(province: provinces[index]),
//                         ),
//                       );
//                     },
//                     borderColor: const Color(0xFF0056A2),
//                     height: 150,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       ),
//     );
//   }
// }
//
// class MyCard extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;
//   final Color borderColor;
//   final double height;
//
//   const MyCard({
//     Key? key,
//     required this.title,
//     required this.onTap,
//     required this.borderColor,
//     required this.height,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap, // Use the provided onTap callback
//       splashColor: Colors.white,
//       child: Card(
//         elevation: AppConfig.elevation,
//         margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//         ),
//         // color: Colors.white,
//         color: Colors.transparent, // Set card color to transparent
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(AppConfig.cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
//               // image: AssetImage(AppConfig.metroCardBackgroundImagePath),
//               fit: BoxFit.cover, // Adjust the fit as needed
//             ),
//             borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius), // Match card's border radius
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(AppConfig.metroCardPadding),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildIcon(),
//                 const SizedBox(width: AppConfig.metroWidthBetweenIconAndContent), // Add spacing between icon and text
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
//                         textAlign: TextAlign.left,
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Arrow Icon
//                 Icon(AppConfig.forwardIcon, size: AppConfig.forwardIconSize, color: AppConfig.forwardIconColor), // Adjust size and color as needed
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildIcon() {
//     // Define the icon size
//     double iconSize = AppConfig.iconSize;
//     Color? iconColor = AppConfig.iconColor;
//
//     return Icon(Icons.public, size: iconSize, color: iconColor);
//   }
// }

import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/alarms/current_alarms/current_alarms.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sltnoc/widgets/my_card.dart';

class SelectedMetroRegionPage extends StatefulWidget {
  final String title;

  const SelectedMetroRegionPage({Key? key, required this.title})
      : super(key: key);

  @override
  _SelectedMetroRegionPageState createState() =>
      _SelectedMetroRegionPageState();
}

class _SelectedMetroRegionPageState extends State<SelectedMetroRegionPage> {
  List<String> provinces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final useLocalServer = prefs.getBool('useLocalServer') ?? true;
      final serverUrl =
          prefs.getString('serverUrl') ?? 'http://192.168.1.14:3000';

      if (useLocalServer) {
        final response = await http.get(
          Uri.parse('$serverUrl/api/provinces/data/${widget.title}'),
        );
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          setState(() {
            provinces = List<String>.from(jsonData);
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Local fetch provinces failed, trying SOAP fallback: $e');
    }

    // SOAP Fallback / Production Mode
    final String soapRequest = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <get_province xmlns="http://tempuri.org/">
            <region>${widget.title}</region>
          </get_province>
        </soap:Body>
      </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/get_province',
        },
        body: soapRequest,
      );

      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.body);
        final elements = xmlDoc.findAllElements('province');

        setState(() {
          provinces = elements.map((element) => element.text).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load data from SOAP');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('SOAP Fetch failed: $error');
      // Re-throw or handle gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
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
                      child: isLoading
                          ? Center(child: CustomLoadingIndicator())
                          : provinces.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/NoData.png', // Replace 'no_data_found.png' with your image asset path
                                        width:
                                            100, // Adjust the width as needed
                                        height:
                                            100, // Adjust the height as needed
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'No Provinces Found!!',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00305e)),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: provinces.length,
                                  itemBuilder: (context, index) {
                                    return MyCard.metro(
                                      title: provinces[index],
                                      borderColor: const Color(0xFF0056A2),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CurrentAlarmsPage(
                                                    province: provinces[index]),
                                          ),
                                        );
                                      },
                                      height: 150,
                                      forwardIconColor2:
                                          AppConfig.forwardIconColor2,
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

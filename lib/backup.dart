// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
// import 'package:flutter/material.dart';
// import 'package:sltnoc/alarms/alarms_page.dart';
// import 'package:sltnoc/clarity_page.dart';
// import 'package:sltnoc/escalations_page.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:location/location.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/app_config.dart';
//
//
// class MyHomePage extends StatelessWidget {
//   final String displayName;
//   const MyHomePage({Key? key, required this.displayName}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 3.0, right: 3.0), // Add left-margin as needed
//               child: Image.asset('assets/SLTLogo.png', width: 28),
//             ),
//             const SizedBox(width: 8), // Add some space between the logo and the title
//             const Text(
//               'SLT NOC',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF0056a2),
//         toolbarHeight: 70,
//         actions: const [
//           SettingsButton(),
//         ],
//       ),
//       body: Container(
//         // color: Colors.grey[300], // Set light gray background color
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/appbarbg2.png'), // Replace 'background_image.jpg' with your image path
//             fit: BoxFit.cover, // Adjust the fit as needed
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text.rich(
//                 TextSpan(
//                   text: '👋 Hello, ',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,),
//                   children: [
//                     TextSpan(
//                       text: '$displayName!',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16, // Adjust the font size as needed
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 15),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.445, // Set a specific height
//                 child: FractionallySizedBox(
//                   widthFactor: 1.0,
//                   heightFactor: 1.0,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(5),
//                     child: GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: LatLng(6.928037,79.844473),
//                         zoom: 14,
//                       ),
//                       trafficEnabled: true,
//                       markers: {Marker(markerId: MarkerId('marker_1'), position: LatLng(6.928037,79.844473))},
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: true,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               // New Card representing the legacy bar
//               Card(
//                 color: Colors.white,
//                 // elevation: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 1', Colors.blue),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 2', Colors.green),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 3', Colors.orange),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 4', Colors.red),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'alarms',
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: MyCard(
//                       title: 'OSS',
//                       subtitle: 'Clarity Fault Dockets',
//                       newSubtitle: 'Clarity',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'clarity',
//                     ),
//                   ),
//                 ],
//               ),
//               // const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ESCALATIONS',
//                       subtitle: 'Fault Escalations',
//                       newSubtitle: 'FMT / SAT',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'escalations',
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'alarms',
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Function to build each item in the legacy bar
//   Widget _buildLegacyBarItem(String itemName, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             color: color,
//             margin: const EdgeInsets.only(right: 8),
//           ),
//           Text(
//             itemName,
//             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }
//
// }
//
// class MyCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String newSubtitle;
//   final Color borderColor;
//   final String page;
//
//   const MyCard({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//     required this.newSubtitle,
//     required this.borderColor,
//     required this.page,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         if (page == 'alarms') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AlarmsPage(
//                 title: 'Alarms',
//                 subtitle: 'Network Alarms',
//                 newSubtitle: 'EMS / NMS',
//               ),
//             ),
//           );
//         } else if (page == 'clarity') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const ClarityPage(
//                 title: 'Clarity',
//                 subtitle: 'Clarity Fault Dockets',
//                 newSubtitle: 'Clarity',
//               ),
//             ),
//           );
//         } else if (page == 'escalations') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const EscalationsPage(
//                 title: 'Escalations',
//                 subtitle: 'Fault Escalations',
//                 newSubtitle: 'FMT / SAT',
//               ),
//             ),
//           );
//         }
//       },
//       splashColor: Colors.white,
//       child: Card(
//         elevation: AppConfig.elevation, // Add elevation for box shadows
//         margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
//         shape: RoundedRectangleBorder(
//           // side: BorderSide(color: borderColor, width: 1.5),
//           borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//         ),
//         color: Colors.transparent, // Set card color to transparent
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(AppConfig.cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
//               fit: BoxFit.cover, // Adjust the fit as needed
//             ),
//             borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius), // Match card's border radius
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(AppConfig.tablePagePadding),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(color: Color(0xFF0056A2), fontSize: 15, fontWeight: FontWeight.w500),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   newSubtitle,
//                   style: const TextStyle(color: Color(0xFF50B748), fontSize: 15, fontWeight: FontWeight.w500),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
// import 'package:flutter/material.dart';
// import 'package:sltnoc/alarms/alarms_page.dart';
// import 'package:sltnoc/clarity_page.dart';
// import 'package:sltnoc/escalations_page.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:location/location.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/app_config.dart';
//
// class MyHomePage extends StatelessWidget {
//   final String displayName;
//   const MyHomePage({Key? key, required this.displayName}) : super(key: key);
//
//   Future<Map<String, String>> fetchFaults($displayName) async {
//     const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
//     final String soapRequest =
//     '''<?xml version="1.0" encoding="utf-8"?>
//     <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//       <soap:Body>
//         <faults3 xmlns="http://tempuri.org/">
//           <nweng>$displayName</nweng>
//           <alarm_type>...ALL...</alarm_type>
//         </faults3>
//       </soap:Body>
//     </soap:Envelope>''';
//
//     try {
//       final http.Response response = await http.post(
//         Uri.parse(soapEndpoint),
//         headers: {
//           'Content-Type': 'text/xml; charset=utf-8',
//           'SOAPAction': 'http://tempuri.org/faults3',
//         },
//         body: soapRequest,
//       );
//
//       if (response.statusCode == 200) {
//         var xmlDoc = xml.XmlDocument.parse(response.body);
//         var resultNode = xmlDoc.findAllElements("faults3Result").first;
//         var resultString = resultNode.text.trim();
//         print('SOAP Response: $resultString');
//
//         List<String> faultList = resultString.split(',');
//         print('Fault List: $faultList');
//
//         Map<String, String> faultMap = {};
//
//         for (String fault in faultList) {
//           List<String> parts = fault.trim().split('::');
//           if (parts.length >= 4) {
//             faultMap[parts[0]] = parts[2];
//           }
//         }
//         print('Fault Map: $faultMap');
//         return faultMap;
//       } else {
//         print('Failed to load faults: ${response.statusCode}');
//         throw Exception('Failed to load faults');
//       }
//     } catch (error) {
//       print('Error fetching faults: $error');
//       throw Exception('Error fetching faults: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 3.0, right: 3.0), // Add left-margin as needed
//               child: Image.asset('assets/SLTLogo.png', width: 28),
//             ),
//             const SizedBox(width: 8), // Add some space between the logo and the title
//             const Text(
//               'SLT NOC',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF0056a2),
//         toolbarHeight: 70,
//         actions: const [
//           SettingsButton(),
//         ],
//       ),
//       body: Container(
//         // color: Colors.grey[300], // Set light gray background color
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/appbarbg2.png'), // Replace 'background_image.jpg' with your image path
//             fit: BoxFit.cover, // Adjust the fit as needed
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text.rich(
//                 TextSpan(
//                   text: '👋 Hello, ',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,),
//                   children: [
//                     TextSpan(
//                       text: '$displayName!',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16, // Adjust the font size as needed
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 15),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.445, // Set a specific height
//                 child: FractionallySizedBox(
//                   widthFactor: 1.0,
//                   heightFactor: 1.0,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(5),
//                     child: GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: LatLng(6.928037,79.844473),
//                         zoom: 14,
//                       ),
//                       trafficEnabled: true,
//                       markers: {Marker(markerId: MarkerId('marker_1'), position: LatLng(6.928037,79.844473))},
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: true,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               // New Card representing the legacy bar
//               Card(
//                 color: Colors.white,
//                 // elevation: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 1', Colors.blue),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 2', Colors.green),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 3', Colors.orange),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 4', Colors.red),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'alarms',
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: MyCard(
//                       title: 'OSS',
//                       subtitle: 'Clarity Fault Dockets',
//                       newSubtitle: 'Clarity',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'clarity',
//                     ),
//                   ),
//                 ],
//               ),
//               // const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ESCALATIONS',
//                       subtitle: 'Fault Escalations',
//                       newSubtitle: 'FMT / SAT',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'escalations',
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'alarms',
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Function to build each item in the legacy bar
//   Widget _buildLegacyBarItem(String itemName, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             color: color,
//             margin: const EdgeInsets.only(right: 8),
//           ),
//           Text(
//             itemName,
//             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }
//
// }
//
// class MyCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String newSubtitle;
//   final Color borderColor;
//   final String page;
//
//   const MyCard({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//     required this.newSubtitle,
//     required this.borderColor,
//     required this.page,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         if (page == 'alarms') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AlarmsPage(
//                 title: 'Alarms',
//                 subtitle: 'Network Alarms',
//                 newSubtitle: 'EMS / NMS',
//               ),
//             ),
//           );
//         } else if (page == 'clarity') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const ClarityPage(
//                 title: 'Clarity',
//                 subtitle: 'Clarity Fault Dockets',
//                 newSubtitle: 'Clarity',
//               ),
//             ),
//           );
//         } else if (page == 'escalations') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const EscalationsPage(
//                 title: 'Escalations',
//                 subtitle: 'Fault Escalations',
//                 newSubtitle: 'FMT / SAT',
//               ),
//             ),
//           );
//         }
//       },
//       splashColor: Colors.white,
//       child: Card(
//         elevation: AppConfig.elevation, // Add elevation for box shadows
//         margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
//         shape: RoundedRectangleBorder(
//           // side: BorderSide(color: borderColor, width: 1.5),
//           borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//         ),
//         color: Colors.transparent, // Set card color to transparent
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(AppConfig.cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
//               fit: BoxFit.cover, // Adjust the fit as needed
//             ),
//             borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius), // Match card's border radius
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(AppConfig.tablePagePadding),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(color: Color(0xFF0056A2), fontSize: 15, fontWeight: FontWeight.w500),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   newSubtitle,
//                   style: const TextStyle(color: Color(0xFF50B748), fontSize: 15, fontWeight: FontWeight.w500),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// original code

// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
// import 'package:flutter/material.dart';
// import 'package:sltnoc/alarms/alarms_page.dart';
// import 'package:sltnoc/clarity_page.dart';
// import 'package:sltnoc/escalations_page.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/app_config.dart';

// class MyHomePage extends StatefulWidget {
//   final String displayName;
//   const MyHomePage({Key? key, required this.displayName}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late GoogleMapController _googleMapController;
//   Set<Marker> _markers = {};

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 3.0, right: 3.0),
//               child: Image.asset('assets/SLTLogo.png', width: 28),
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'SLT NOC',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF0056a2),
//         toolbarHeight: 70,
//         actions: const [
//           SettingsButton(),
//         ],
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/appbarbg2.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text.rich(
//                 TextSpan(
//                   text: '👋 Hello, ',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,),
//                   children: [
//                     TextSpan(
//                       text: '${widget.displayName}!',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 15),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.445,
//                 child: FractionallySizedBox(
//                   widthFactor: 1.0,
//                   heightFactor: 1.0,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(5),
//                     child: GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: LatLng(6.928037,79.844473),
//                         zoom: 7,
//                       ),
//                       trafficEnabled: true,
//                       markers: _markers,
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: true,
//                       onMapCreated: (controller) {
//                         _googleMapController = controller;
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Card(
//                 color: Colors.white,
//                 margin: const EdgeInsets.symmetric(vertical: 0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 1', Colors.blue),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 2', Colors.green),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 3', Colors.orange),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: _buildLegacyBarItem('Item 4', Colors.red),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'alarms',
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: MyCard(
//                       title: 'OSS',
//                       subtitle: 'Clarity Fault Dockets',
//                       newSubtitle: 'Clarity',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'clarity',
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ESCALATIONS',
//                       subtitle: 'Fault Escalations',
//                       newSubtitle: 'FMT / SAT',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'escalations',
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'alarms',
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLegacyBarItem(String itemName, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             color: color,
//             margin: const EdgeInsets.only(right: 8),
//           ),
//           Text(
//             itemName,
//             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> process1() async {
//     // Call faults3 web service with placeholders and get response
//     final faults3Response = await http.post(
//       Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/faults3',
//       },
//       body: '''<?xml version="1.0" encoding="utf-8"?>
//       <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//         <soap:Body>
//           <faults3 xmlns="http://tempuri.org/">
//             <nweng>ALL</nweng>
//             <alarm_type>ALL</alarm_type>
//           </faults3>
//         </soap:Body>
//       </soap:Envelope>''',
//     );

//     if (faults3Response.statusCode == 200) {
//       final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
//       final faults3Result = faults3Xml.findAllElements('faults3Result').single.text;

//       // Process faults3Result and filter records with hours <= 4
//       final timeFilteredMSANs = <String>[];
//       final faults = faults3Result.split(',');
//       for (final fault in faults) {
//         final fields = fault.split('::');

//         final hours = int.tryParse(fields[2].trim().split(' ')[0]);
//         //my

//         if (hours != null && hours <= 4) {
//           timeFilteredMSANs.add(fault);
//         }
//       }

//       // Call get_MSAN_Location web service for each MSAN unit
//       final finalMapWithGeo = <String>[];
//       for (final msan in timeFilteredMSANs) {
//         final nodeName = msan.split('::')[0];
//         final msanLocationResponse = await http.post(
//           Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
//           headers: {
//             'Content-Type': 'text/xml; charset=utf-8',
//             'SOAPAction': 'http://tempuri.org/get_MSAN_Location',
//           },
//           body: '''<?xml version="1.0" encoding="utf-8"?>
//           <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//             <soap:Body>
//               <get_MSAN_Location xmlns="http://tempuri.org/">
//                 <node>$nodeName</node>
//               </get_MSAN_Location>
//             </soap:Body>
//           </soap:Envelope>''',
//         );

//         if (msanLocationResponse.statusCode == 200) {
//           final msanLocationXml = xml.XmlDocument.parse(msanLocationResponse.body);
//           final msanLocationResult = msanLocationXml.findAllElements('get_MSAN_LocationResult').single.text;

//           if (msanLocationResult != 'NO ALARMS') {
//             finalMapWithGeo.add('$msan::$msanLocationResult');
//           }
//         }
//       }

//       // Update markers on Google Map based on finalMapWithGeo
//       updateMarkers(finalMapWithGeo);
//     }
//   }

//   Future<void> process2() async {
//     // Call faults3 web service with displayName and get response
//     final faults3Response = await http.post(
//       Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/faults3',
//       },
//       body:
//       '''<?xml version="1.0" encoding="utf-8"?>
//       <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//         <soap:Body>
//           <faults3 xmlns="http://tempuri.org/">
//             <nweng>${widget.displayName}</nweng>
//             <alarm_type>ALL</alarm_type>
//           </faults3>
//         </soap:Body>
//       </soap:Envelope>''',
//     );

//     if (faults3Response.statusCode == 200) {
//       final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
//       final faults3Result = faults3Xml.findAllElements('faults3Result').single.text;

//       if (faults3Result == 'NO ALARMS') {
//         // Display Sri Lanka on the map
//         // You can set a default location or center the map to Sri Lanka
//         // Example:
//         final sriLankaLatLng = LatLng(7.8731, 80.7718); // Center of Sri Lanka
//         final cameraPosition = CameraPosition(target: sriLankaLatLng, zoom: 7);
//         _googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//       } else {
//         // Follow Process 1 with the received response
//         process1();
//       }
//     }
//   }

//   void updateMarkers(List<String> msansWithGeo) {
//     final updatedMarkers = msansWithGeo.map((msanWithGeo) {
//       final parts = msanWithGeo.split('::');
//       final latLng = parts[1].split('::').map(double.parse).toList();
//       return Marker(
//         markerId: MarkerId(parts[0]),
//         position: LatLng(latLng[0], latLng[1]),
//         infoWindow: InfoWindow(
//           title: parts[0],
//           snippet: parts[2],
//         ),
//       );
//     }).toSet();

//     setState(() {
//       _markers = updatedMarkers;
//     });
//   }
// }

// class MyCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String newSubtitle;
//   final Color borderColor;
//   final String page;

//   const MyCard({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//     required this.newSubtitle,
//     required this.borderColor,
//     required this.page,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         if (page == 'alarms') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AlarmsPage(
//                 title: 'Alarms',
//                 subtitle: 'Network Alarms',
//                 newSubtitle: 'EMS / NMS',
//               ),
//             ),
//           );
//         } else if (page == 'clarity') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const ClarityPage(
//                 title: 'Clarity',
//                 subtitle: 'Clarity Fault Dockets',
//                 newSubtitle: 'Clarity',
//               ),
//             ),
//           );
//         } else if (page == 'escalations') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const EscalationsPage(
//                 title: 'Escalations',
//                 subtitle: 'Fault Escalations',
//                 newSubtitle: 'FMT / SAT',
//               ),
//             ),
//           );
//         }
//       },
//       splashColor: Colors.white,
//       child: Card(
//         elevation: AppConfig.elevation, // Add elevation for box shadows
//         margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
//         shape: RoundedRectangleBorder(
//           // side: BorderSide(color: borderColor, width: 1.5),
//           borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//         ),
//         color: Colors.transparent, // Set card color to transparent
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(AppConfig.cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
//               fit: BoxFit.cover, // Adjust the fit as needed
//             ),
//             borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius), // Match card's border radius
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(AppConfig.tablePagePadding),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(color: Color(0xFF0056A2), fontSize: 15, fontWeight: FontWeight.w500),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   newSubtitle,
//                   style: const TextStyle(color: Color(0xFF50B748), fontSize: 15, fontWeight: FontWeight.w500),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/material.dart';
import 'package:sltnoc/alarms/alarms_page.dart';
import 'package:sltnoc/clarity_page.dart';
import 'package:sltnoc/escalations_page.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sltnoc/app_config.dart';

class MyHomePage extends StatefulWidget {
  final String displayName;
  const MyHomePage({Key? key, required this.displayName}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _googleMapController;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 3.0, right: 3.0),
              child: Image.asset('assets/SLTLogo.png', width: 28),
            ),
            const SizedBox(width: 8),
            const Text(
              'SLT NOC',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0056a2),
        toolbarHeight: 70,
        actions: const [
          SettingsButton(),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/appbarbg2.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  text: '👋 Hello, ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: '${widget.displayName}!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.445,
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(6.928037, 79.844473),
                        zoom: 7,
                      ),
                      trafficEnabled: true,
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) {
                        _googleMapController = controller;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLegacyBarItem('Item 1', Colors.blue),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildLegacyBarItem('Item 2', Colors.green),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildLegacyBarItem('Item 3', Colors.orange),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildLegacyBarItem('Item 4', Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: MyCard(
                      title: 'ALARMS',
                      subtitle: 'Network Alarms',
                      newSubtitle: 'EMS / NMS',
                      borderColor: Color(0xFF0056A2),
                      page: 'alarms',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyCard(
                      title: 'OSS',
                      subtitle: 'Clarity Fault Dockets',
                      newSubtitle: 'Clarity',
                      borderColor: Color(0xFF0056A2),
                      page: 'clarity',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: MyCard(
                      title: 'ESCALATIONS',
                      subtitle: 'Fault Escalations',
                      newSubtitle: 'FMT / SAT',
                      borderColor: Color(0xFF0056A2),
                      page: 'escalations',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyCard(
                      title: 'ALARMS',
                      subtitle: 'Network Alarms',
                      newSubtitle: 'EMS / NMS',
                      borderColor: Color(0xFF0056A2),
                      page: 'alarms',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyBarItem(String itemName, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          Text(
            itemName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> process1() async {
    // Call faults3 web service with placeholders and get response
    final faults3Response = await http.post(
      Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/faults3',
      },
      body: '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <faults3 xmlns="http://tempuri.org/">
            <nweng>ALL</nweng>
            <alarm_type>ALL</alarm_type>
          </faults3>
        </soap:Body>
      </soap:Envelope>''',
    );

    ///

    if (faults3Response.statusCode == 200) {
      final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
      final faults3Result =
          faults3Xml.findAllElements('faults3Result').single.text;

      // Process faults3Result and filter records with hours <= 4
      final timeFilteredMSANs = <String>[];
      final faults = faults3Result.split(',');
      for (final fault in faults) {
        final fields = fault.split('::');

        final hours = int.tryParse(fields[2].trim().split(' ')[0]);

        if (hours != null && hours <= 4) {
          timeFilteredMSANs.add(fault);
        }
      }

      // Call get_MSAN_Location web service for each MSAN unit
      final finalMapWithGeo = <String>[];
      for (final msan in timeFilteredMSANs) {
        final nodeName = msan.split('::')[0];
        final msanLocationResponse = await http.post(
          Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': 'http://tempuri.org/get_MSAN_Location',
          },
          body: '''<?xml version="1.0" encoding="utf-8"?>
          <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              <get_MSAN_Location xmlns="http://tempuri.org/">
                <node>$nodeName</node>
              </get_MSAN_Location>
            </soap:Body>
          </soap:Envelope>''',
        );

        if (msanLocationResponse.statusCode == 200) {
          final msanLocationXml =
              xml.XmlDocument.parse(msanLocationResponse.body);
          final msanLocationResult = msanLocationXml
              .findAllElements('get_MSAN_LocationResult')
              .single
              .text;

          if (msanLocationResult != 'NO ALARMS') {
            finalMapWithGeo.add('$msan::$msanLocationResult');
          }
        }
      }

      // Update markers on Google Map based on finalMapWithGeo
      updateMarkers(finalMapWithGeo);
    }
  }

  Future<void> process2() async {
    // Call faults3 web service with displayName and get response
    final faults3Response = await http.post(
      Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/faults3',
      },
      body: '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <faults3 xmlns="http://tempuri.org/">
            <nweng>${widget.displayName}</nweng>
            <alarm_type>ALL</alarm_type>
          </faults3>
        </soap:Body>
      </soap:Envelope>''',
    );

    if (faults3Response.statusCode == 200) {
      final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
      final faults3Result =
          faults3Xml.findAllElements('faults3Result').single.text;

      if (faults3Result == 'NO ALARMS') {
        // Display Sri Lanka on the map
        // You can set a default location or center the map to Sri Lanka
        // Example:
        final sriLankaLatLng = LatLng(7.8731, 80.7718); // Center of Sri Lanka
        final cameraPosition = CameraPosition(target: sriLankaLatLng, zoom: 7);
        _googleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      } else {
        // Follow Process 1 with the received response
        process1();
      }
    }
  }

  void updateMarkers(List<String> msansWithGeo) {
    final updatedMarkers = msansWithGeo.map((msanWithGeo) {
      final parts = msanWithGeo.split('::');
      final latLng = parts[1].split('::').map(double.parse).toList();
      return Marker(
        markerId: MarkerId(parts[0]),
        position: LatLng(latLng[0], latLng[1]),
        infoWindow: InfoWindow(
          title: parts[0],
          snippet: parts[2],
        ),
      );
    }).toSet();

    setState(() {
      _markers = updatedMarkers;
    });
  }
}

class MyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String newSubtitle;
  final Color borderColor;
  final String page;

  const MyCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.newSubtitle,
    required this.borderColor,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (page == 'alarms') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AlarmsPage(
                title: 'Alarms',
                subtitle: 'Network Alarms',
                newSubtitle: 'EMS / NMS',
              ),
            ),
          );
        } else if (page == 'clarity') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClarityPage(
                title: 'Clarity',
                subtitle: 'Clarity Fault Dockets',
                newSubtitle: 'Clarity',
              ),
            ),
          );
        } else if (page == 'escalations') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EscalationsPage(
                title: 'Escalations',
                subtitle: 'Fault Escalations',
                newSubtitle: 'FMT / SAT',
              ),
            ),
          );
        }
      },
      splashColor: Colors.white,
      child: Card(
        elevation: AppConfig.elevation, // Add elevation for box shadows
        margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
        shape: RoundedRectangleBorder(
          // side: BorderSide(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        color: Colors.transparent, // Set card color to transparent
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig
                  .cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
            borderRadius: BorderRadius.circular(
                AppConfig.cardBorderRadius), // Match card's border radius
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.tablePagePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: Color(0xFF0056A2),
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  newSubtitle,
                  style: const TextStyle(
                      color: Color(0xFF50B748),
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //my//

  //
}

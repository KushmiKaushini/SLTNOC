// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
// import 'package:flutter/material.dart';
// import 'package:sltnoc/alarms/alarms_page.dart';
// import 'package:sltnoc/clarity_page.dart';
// import 'package:sltnoc/escalations_page.dart';
// import 'package:sltnoc/planOutages/plan_Outages.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/app_config.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class MyHomePage extends StatefulWidget {
//   final String displayName;
//   // final String myText = "A.Gunalathas";
//   const MyHomePage({Key? key, required this.displayName}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late GoogleMapController _googleMapController;
//   Map<String, bool> engNameList = {};
//   Set<Marker> _markers = {};
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     // Request location permission
//     _requestLocationPermission();
//     fetchDataAndProcess();
//   }
//
//   Future<void> _requestLocationPermission() async {
//     // Check if location permission is granted
//     final PermissionStatus status = await Permission.locationWhenInUse.request();
//     if (status != PermissionStatus.granted) {
//       // Handle denied or restricted permissions
//       // You can show a dialog or message to inform the user about the importance of location permissions
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
//               padding: const EdgeInsets.only(left: 3.0, right: 3.0),
//               child: Image.asset('assets/SLTLogo.png', width: 28),
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'NOC Portal',
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
//                   text: 'Hello, ',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,),
//                   children: [
//                     TextSpan(
//                       text: '${widget.displayName}! 👋',
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
//                     child: Stack(
//                       children: [
//                         _buildGoogleMapWithLoading(), // Display GoogleMap with loading indicator
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Container(
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(AppConfig.cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
//                       fit: BoxFit.cover, // Adjust the fit as needed
//                     ),
//                     borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius), // Match card's border radius
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: _buildLegacyBarItem('MSAN', Colors.blue),
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: _buildLegacyBarItem('CEA', Colors.green),
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: _buildLegacyBarItem('GPON', Colors.orange),
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: _buildLegacyBarItem('RPB', Colors.yellow),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//               const SizedBox(height: 5),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       displayName: widget.displayName,
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
//                       displayName: widget.displayName,
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
//                       displayName: widget.displayName,
//                       subtitle: 'Fault Escalations',
//                       newSubtitle: 'FMT / SAT',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'escalations',
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: MyCard(
//                       title: 'COMMERCIALLY PLANNED OUTAGES',
//                       displayName: widget.displayName,
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'planOutages',
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
//   Widget _buildGoogleMapWithLoading() {
//     return Stack(
//       children: [
//         Container(
//           height: MediaQuery.of(context).size.height * 0.445,
//           child: FractionallySizedBox(
//             widthFactor: 1.0,
//             heightFactor: 1.0,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(5),
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(7.8731, 80.7718),
//                   zoom: 7,
//                 ),
//                 trafficEnabled: true,
//                 markers: _markers,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 onMapCreated: (controller) {
//                   _googleMapController = controller;
//                 },
//                 // Add your other GoogleMap properties here...
//               ),
//             ),
//           ),
//         ),
//         if (_isLoading) // Show loading indicator only when isLoading is true
//           Container(
//             color: Colors.black.withOpacity(0.7), // Semi-transparent black color
//             height: MediaQuery.of(context).size.height * 0.445,
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(
//                     backgroundColor: Colors.white,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Colors.blue,
//                     ),
//                   ),
//                   SizedBox(height: 10), // Adjust the space between the indicator and text
//                   Text(
//                     'Fetching Node Down alarms upto 4 days...',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
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
//   // Method to fetch data and process accordingly
//   Future<void> fetchDataAndProcess() async {
//     await fetchEngNameList(); // Fetch data using fullenglist web service
//     if (engNameList.containsKey(widget.displayName)) {
//       // If displayName exists in engNameList, proceed with Process 2
//       await process2();
//     } else {
//       // If displayName doesn't exist in engNameList, proceed with Process 1
//       await process1(nweng: '...ALL...');
//       print('${widget.displayName} not found in engNameList');
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   // Method to fetch data using fullenglist web service
//   Future<void> fetchEngNameList() async {
//     final fullEngListResponse = await http.post(
//       Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/fullenglist',
//       },
//       body: '''<?xml version="1.0" encoding="utf-8"?>
//         <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//           <soap:Body>
//             <fullenglist xmlns="http://tempuri.org/">
//             </fullenglist>
//           </soap:Body>
//         </soap:Envelope>''',
//     );
//
//     print('Faults 3 Response: ${fullEngListResponse.body}');
//
//     if (fullEngListResponse.statusCode == 200) {
//       // Parse the response and update engNameList map
//       final fullEngListXml = xml.XmlDocument.parse(fullEngListResponse.body);
//       final fullEngListResult = fullEngListXml.findAllElements('fullenglistResult').single.text;
//
//       final names = fullEngListResult.split(',').map((record) {
//         // Extract the name from each record
//         final name = record.split('::')[0];
//         return name.trim(); // Trim any leading/trailing spaces
//       });
//
//       // Add extracted names to the engNameList map
//       for (final name in names) {
//         engNameList[name] = true;
//       }
//     } else {
//       // Handle error case
//       print('Failed to fetch engNameList: ${fullEngListResponse.statusCode}');
//     }
//     print(engNameList);
//   }
//
//   Future<void> process1({required String nweng}) async {
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
//             <nweng>${nweng}</nweng>
//             <alarm_type>Node Down</alarm_type>
//           </faults3>
//         </soap:Body>
//       </soap:Envelope>''',
//     );
//     print('Faults 3 Response: ${faults3Response.body}');
//
//
//     if (faults3Response.statusCode == 200) {
//       final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
//       final faults3Result = faults3Xml.findAllElements('faults3Result').single.text;
//
//       // Process faults3Result and filter records with hours <= 4
//       final timeFilteredMSANs = <String>[];
//       final faults = faults3Result.split(',');
//       for (final fault in faults) {
//         final fields = fault.split('::');
//         final hours = int.tryParse(fields[2].trim().split(' ')[0]);
//         if (hours != null && hours <= 96) {
//           timeFilteredMSANs.add(fault);
//         }
//       }
//
//       print(timeFilteredMSANs);
//
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
//
//         if (msanLocationResponse.statusCode == 200) {
//           final msanLocationXml = xml.XmlDocument.parse(msanLocationResponse.body);
//           final msanLocationResult = msanLocationXml.findAllElements('get_MSAN_LocationResult').single.text;
//
//           if (msanLocationResult != 'NO ALARMS') {
//             finalMapWithGeo.add('$msan::$msanLocationResult');
//           }
//         }
//
//       }
//       print(finalMapWithGeo);
//       // Update markers on Google Map based on finalMapWithGeo
//       updateMarkers(finalMapWithGeo);
//     }
//   }
//
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
//             <alarm_type>Node Down</alarm_type>
//           </faults3>
//         </soap:Body>
//       </soap:Envelope>''',
//     );
//     print('Faults 3 Response: ${faults3Response.body}'); // Add this line to print the response
//
//     if (faults3Response.statusCode == 200) {
//       final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
//       final faults3Result = faults3Xml.findAllElements('faults3Result').single.text;
//
//       if (faults3Result == 'NO ALARMS') {
//         final sriLankaLatLng = LatLng(7.8731, 80.7718); // Center of Sri Lanka
//         final cameraPosition = CameraPosition(target: sriLankaLatLng, zoom: 7);
//         _googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//       } else {
//         // Follow Process 1 with the received response
//         process1(nweng: widget.displayName);
//       }
//     }
//
//   }
//
//   void updateMarkers(List<String> msansWithGeo) {
//     final updatedMarkers = msansWithGeo.map((msanWithGeo) {
//       final parts = msanWithGeo.split('::');
//       print('Parts length: ${parts.length}');
//       print('Parts: ${parts}');
//       if (parts.length >= 7) { // Change the condition to check for at least 7 elements
//         final lat = double.tryParse(parts[5]);
//         final lng = double.tryParse(parts[6]);
//         if (lat != null && lng != null) {
//           // Determine marker color based on parts[4]
//           BitmapDescriptor markerIcon;
//           switch (parts[4]) {
//             case 'MSAN':
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//               break;
//             case 'CEA':
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//               break;
//             case 'GPON':
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
//               break;
//             case 'RPB':
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
//               break;
//             default:
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//               break;
//           }
//
//           return Marker(
//             markerId: MarkerId(parts[0]),
//             position: LatLng(lng, lat),
//             icon: markerIcon, // Set marker icon based on parts[4]
//             infoWindow: InfoWindow(
//               title: parts[0],
//               snippet: parts[2]+'| '+parts[3],
//             ),
//           );
//         } else {
//           return null;
//         }
//       } else {
//         // Handle the case where parts doesn't have enough elements
//         return null;
//       }
//     }).where((marker) => marker != null).map((marker) => marker!).toSet(); // Filter out null markers and remove nullability
//     print(updatedMarkers);
//     if (mounted) { // Check if the widget is still mounted before calling setState
//       setState(() {
//         _markers = updatedMarkers; // Assign updatedMarkers directly without casting
//       });
//     }
//   }
//
// }
//
// class MyCard extends StatelessWidget {
//   final String title;
//   final String displayName;
//   final String subtitle;
//   final String newSubtitle;
//   final Color borderColor;
//   final String page;
//
//   const MyCard({
//     Key? key,
//     required this.title,
//     required this.displayName,
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
//         else if (page == 'planOutages') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PlanOutagesPage(
//                 title: 'Plan Outages',
//                 name: displayName,
//               ),
//             ),
//           );
//         }
//
//       },
//       splashColor: Colors.white,
//       child: Card(
//         elevation: AppConfig.elevation, // Add elevation for box shadows
//         margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
//         shape: RoundedRectangleBorder(
//           // side: BorderSide(color: borderColor, width: 1.5),
//           borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//         ),
//         color: Colors.white, // Set card color to transparent
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
//                 if (page != 'planOutages') ...[
//                   const SizedBox(height: 8),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(color: Color(0xFF0056A2), fontSize: 15, fontWeight: FontWeight.w500),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     newSubtitle,
//                     style: const TextStyle(color: Color(0xFF50B748), fontSize: 15, fontWeight: FontWeight.w500),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

///////////////////////////up mukuth karannna epa

// this is this code my edit orignal code this not work//

//start original this file code //

// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
// import 'package:flutter/material.dart';
// import 'package:sltnoc/alarms/alarms_page.dart';
// import 'package:sltnoc/clarity_page.dart';
// import 'package:sltnoc/escalations_page.dart';
// import 'package:sltnoc/planOutages/plan_Outages.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/app_config.dart';
// import 'package:permission_handler/permission_handler.dart';

// class MyHomePage extends StatefulWidget {
//   final String displayName;
//   const MyHomePage({Key? key, required this.displayName}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
//   late GoogleMapController _googleMapController;
//   Map<String, bool> engNameList = {};
//   Set<Marker> _markers = {};
//   bool _isLoading = true;

//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _requestLocationPermission();
//     fetchDataAndProcess();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Future<void> _requestLocationPermission() async {
//   //   final PermissionStatus status = await Permission.locationWhenInUse.request();
//   //   if (status != PermissionStatus.granted) {
//   //     // Handle denied or restricted permissions
//   //   }
//   // }

//   Future<void> _requestLocationPermission() async {
//   try {
//     final PermissionStatus status = await Permission.locationWhenInUse.request();
//     if (status != PermissionStatus.granted) {
//       // Handle denied or restricted permissions
//       print("Location permission denied or restricted.");
//     }
//   } catch (e) {
//     // Handle any errors that occur during the permission request
//     print("An error occurred while requesting location permission: $e");
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 3.0, right: 3.0),
//               child: Image.asset('assets/SLTLogo.png', width: 0.05 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//             ),
//             SizedBox(width: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//             Text(
//               'NOC Portal',
//               style: TextStyle(fontSize: 0.045 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF0056a2),
//         toolbarHeight: 0.13 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
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
//         padding: EdgeInsets.all(0.04 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text.rich(
//                 TextSpan(
//                   text: 'Hello, ',
//                   style: TextStyle(fontSize: 0.04 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w400),
//                   children: [
//                     TextSpan(
//                       text: '${widget.displayName}! 👋',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 0.04 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 0.03 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//               SizedBox(
//                 height: 1 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//                 child: FractionallySizedBox(
//                   widthFactor: 1.0,
//                   heightFactor: 1.0,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(5),
//                     child: Stack(
//                       children: [
//                         _buildGoogleMapWithLoading(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 0.03 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(AppConfig.cardBackgroundImagePath),
//                     fit: BoxFit.cover,
//                   ),
//                   borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: _buildLegacyBarItem('MSAN', Colors.blue),
//                       ),
//                       SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                       Expanded(
//                         child: _buildLegacyBarItem('CEA', Colors.green),
//                       ),
//                       // SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                       // Expanded(
//                       //   child: _buildLegacyBarItem('GPON', Colors.orange),
//                       // ),
//                       SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                       Expanded(
//                         child: _buildLegacyBarItem('RPB', Colors.yellow),
//                       ),
//                       SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                       Expanded(
//                         child: _buildLegacyBarItem('OTHER', Colors.red),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       displayName: widget.displayName,
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'alarms',
//                     ),
//                   ),
//                   SizedBox(width: 0.03 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Expanded(
//                     child: MyCard(
//                       title: 'OSS',
//                       displayName: widget.displayName,
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
//                       displayName: widget.displayName,
//                       subtitle: 'Fault Escalations',
//                       newSubtitle: 'FMT / SAT',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'escalations',
//                     ),
//                   ),
//                   SizedBox(width: 0.03 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Expanded(
//                     child: MyCard(
//                       title: 'COMMERCIAL POs',
//                       displayName: widget.displayName,
//                       subtitle: 'Planned Outages',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'planOutages',
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

//   Widget _buildGoogleMapWithLoading() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Stack(
//       children: [
//         Container(
//           height: 1 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//           child: FractionallySizedBox(
//             widthFactor: 1.0,
//             heightFactor: 1.0,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(5),
//               child: GoogleMap(
//                 gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//                   Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
//                 }.toSet(),
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(7.8731, 80.7718),
//                   zoom: 7,
//                 ),
//                 trafficEnabled: true,
//                 markers: _markers,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 onMapCreated: (controller) {
//                   _googleMapController = controller;
//                 },
//               ),
//             ),
//           ),
//         ),
//         if (_isLoading)
//           Container(
//             color: Colors.black.withOpacity(0.7),
//             height: 1 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(
//                     backgroundColor: Colors.white,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Colors.blue,
//                     ),
//                   ),
//                   SizedBox(height: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Text(
//                     'Fetching Node Down alarms upto 4 days...',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 0.035 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildLegacyBarItem(String itemName, Color color) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), horizontal: 0.03 * MediaQuery.of(context).size.width),
//       child: Row(
//         children: [
//           Container(
//             width: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//             height: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//             color: color,
//             margin: EdgeInsets.only(right: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//           ),
//           Text(
//             itemName,
//             style: TextStyle(fontSize: 0.035 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> fetchDataAndProcess() async {
//     await fetchEngNameList();
//     if (engNameList.containsKey(widget.displayName)) {
//       await process2();
//     } else {
//       await process1(nweng: '...ALL...');
//       print('${widget.displayName} not found in engNameList');
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> fetchEngNameList() async {
//     final fullEngListResponse = await http.post(
//       Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/fullenglist',
//       },
//       body: '''<?xml version="1.0" encoding="utf-8"?>
//         <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//           <soap:Body>
//             <fullenglist xmlns="http://tempuri.org/">
//             </fullenglist>
//           </soap:Body>
//         </soap:Envelope>''',
//     );

//     if (fullEngListResponse.statusCode == 200) {
//       final fullEngListXml = xml.XmlDocument.parse(fullEngListResponse.body);
//       final fullEngListResult = fullEngListXml.findAllElements('fullenglistResult').single.text;

//       final names = fullEngListResult.split(',').map((record) {
//         final name = record.split('::')[0];
//         return name.trim();
//       });

//       for (final name in names) {
//         engNameList[name] = true;
//       }
//     } else {
//       print('Failed to fetch engNameList: ${fullEngListResponse.statusCode}');
//     }
//     print(engNameList);
//   }

//   Future<void> process1({required String nweng}) async {
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
//             <nweng>${nweng}</nweng>
//             <alarm_type>Node Down</alarm_type>
//           </faults3>
//         </soap:Body>
//       </soap:Envelope>''',
//     );
//     print('Faults 3 Response: ${faults3Response.body}');

//     if (faults3Response.statusCode == 200) {
//       final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
//       final faults3Result = faults3Xml.findAllElements('faults3Result').single.text;

//       final timeFilteredMSANs = <String>[];
//       final faults = faults3Result.split(',');
//       for (final fault in faults) {
//         final fields = fault.split('::');
//         final hours = int.tryParse(fields[2].trim().split(' ')[0]);
//         if (hours != null && hours <= 96) {
//           timeFilteredMSANs.add(fault);
//         }
//       }

//       print(timeFilteredMSANs);

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
//       print(finalMapWithGeo);
//       updateMarkers(finalMapWithGeo);
//     }
//   }

//   Future<void> process2() async {
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
//             <nweng>${widget.displayName}</nweng>
//             <alarm_type>Node Down</alarm_type>
//           </faults3>
//         </soap:Body>
//       </soap:Envelope>''',
//     );
//     print('Faults 3 Response: ${faults3Response.body}');

//     if (faults3Response.statusCode == 200) {
//       final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
//       final faults3Result = faults3Xml.findAllElements('faults3Result').single.text;

//       if (faults3Result == 'NO ALARMS') {
//         final sriLankaLatLng = LatLng(7.8731, 80.7718);
//         final cameraPosition = CameraPosition(target: sriLankaLatLng, zoom: 7);
//         _googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//       }
//        else {
//         process1(nweng: widget.displayName);
//       }
//     }
//   }

//   /////

// // original code

//   // void updateMarkers(List<String> msansWithGeo) {
//   //   final updatedMarkers = msansWithGeo.map((msanWithGeo) {
//   //     final parts = msanWithGeo.split('::');
//   //     print('Parts length: ${parts.length}');
//   //     print('Parts: ${parts}');
//   //     if (parts.length >= 7) {
//   //       final lat = double.tryParse(parts[5]);
//   //       final lng = double.tryParse(parts[6]);
//   //       if (lat != null && lng != null) {
//   //         BitmapDescriptor markerIcon;
//   //         switch (parts[4]) {
//   //           case 'MSAN':
//   //             markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//   //             break;
//   //           case 'CEA':
//   //             markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//   //             break;
//   //           // case 'GPON':
//   //           //   markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
//   //           //   break;
//   //           case 'RPB':
//   //             markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
//   //             break;
//   //           default:
//   //             markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//   //             break;
//   //         }

//   //         return Marker(
//   //           markerId: MarkerId(parts[0]),
//   //           position: LatLng(lng, lat),
//   //           icon: markerIcon,
//   //           infoWindow: InfoWindow(
//   //             title: parts[0],
//   //             snippet: parts[2] + '| ' + parts[3],
//   //           ),
//   //         );
//   //       } else {
//   //         return null;
//   //       }
//   //     } else {
//   //       return null;
//   //     }
//   //   }).where((marker) => marker != null).map((marker) => marker!).toSet();
//   //   print(updatedMarkers);
//   //   if (mounted) {
//   //     setState(() {
//   //       _markers = updatedMarkers;
//   //     });
//   //   }
//   // }

//   //////

//   void updateMarkers(List<String> msansWithGeo) {
//   final updatedMarkers = msansWithGeo.map((msanWithGeo) {
//     final parts = msanWithGeo.split('::');
//     if (parts.length >= 7) {
//       final lat = double.tryParse(parts[5]);
//       final lng = double.tryParse(parts[6]);

//       if (lat != null && lng != null) {
//         BitmapDescriptor markerIcon;
//         switch (parts[4]) {
//           case 'MSAN':
//             markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//             break;
//           case 'CEA':
//             markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//             break;
//           case 'RPB':
//             markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
//             break;
//           default:
//             markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//             break;
//         }

//         return Marker(
//           markerId: MarkerId(parts[0]),
//           position: LatLng(lat, lng),
//           icon: markerIcon,
//           infoWindow: InfoWindow(
//             title: parts[0],
//             snippet: '${parts[2]} | ${parts[3]} | ${parts[5]}',
//             onTap: () async {
//               // Fetch details on marker tap
//               final details = await fetchRelevantDetails(parts[0]); // Pass identifier
//               showDetailsDialog(details); // Show details in a dialog
//             },
//           ),
//         );
//       }
//     }
//     return null;
//   }).where((marker) => marker != null).map((marker) => marker!).toSet();

//   if (mounted) {
//     setState(() {
//       _markers = updatedMarkers;
//     });
//   }
// }

// // Fetch details based on marker identifier
// Future<Map<String, dynamic>> fetchRelevantDetails(String msan) async {
//   const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
//   final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
//     <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//       <soap:Body>
//         <get_MSAN_details_2_new xmlns="http://tempuri.org/">
//           <msan>$msan</msan>
//         </get_MSAN_details_2_new>
//       </soap:Body>
//     </soap:Envelope>''';

//   final response = await http.post(
//     Uri.parse(url),
//     headers: {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/get_MSAN_details_2_new',
//     },
//     body: soapXML,
//   );

//   if (response.statusCode == 200) {
//     String soapResponse = response.body;
//     RegExp regex = RegExp(r'<get_MSAN_details_2_newResult>(.*?)<\/get_MSAN_details_2_newResult>');
//     String result = regex.firstMatch(soapResponse)?.group(1) ?? '';
//     List<String> fields = result.split('::');

//     return {
//       'eleName': fields[0],
//       'nwEngName': fields[3],
//       'site': fields[5],
//       'num1': fields[9],
//       'num2': fields[11],
//       'num3': fields[13],
//       'num4': fields[15],
//       'num5': fields[17],
//       'num6': fields[7],
//       'vendor': fields[18],
//       'contName1': fields[8],
//       'contName2': fields[10],
//       'contName3': fields[12],
//       'contName4': fields[14],
//       'contName5': fields[16],
//       'contName6': fields[6],
//       'issues': fields[19].split('=')[0],
//       'CSCID': fields[20],
//       'AGG': fields[21],
//       'ODF': fields[22],
//     };
//   } else {
//     throw Exception('Failed to fetch details');
//   }
// }

// // Show details in a dialog
// void showDetailsDialog(Map<String, dynamic> details) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(details['eleName']),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Network Engineer: ${details['nwEngName']}'),
//             Text('Site: ${details['site']}'),
//             Text('Vendor: ${details['vendor']}'),
//             Text('Issues: ${details['issues']}'),
//             // Add other fields as needed
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Close'),
//           ),
//         ],
//       );
//     },
//   );
// }

// }

// class MyCard extends StatelessWidget {
//   final String title;
//   final String displayName;
//   final String subtitle;
//   final String newSubtitle;
//   final Color borderColor;
//   final String page;

//   const MyCard({
//     Key? key,
//     required this.title,
//     required this.displayName,
//     required this.subtitle,
//     required this.newSubtitle,
//     required this.borderColor,
//     required this.page,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
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
//         } else if (page == 'planOutages') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PlanOutagesPage(
//                 title: 'Planned Outages',
//                 name: displayName,
//               ),
//             ),
//           );
//         }
//       },
//       splashColor: Colors.white,
//       child: Card(
//         elevation: AppConfig.elevation,
//         margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//         ),
//         color: Colors.white,
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(AppConfig.cardBackgroundImagePath),
//               fit: BoxFit.cover,
//             ),
//             borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(AppConfig.homePageCardPadding),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 0.04 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w900, color: Colors.black),
//                   textAlign: TextAlign.center,
//                 ),

//                   SizedBox(height: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Text(
//                     subtitle,
//                     style: TextStyle(color: Color(0xFF0056A2), fontSize: 0.035 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w500),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Text(
//                     newSubtitle,
//                     style: TextStyle(color: Color(0xFF50B748), fontSize: 0.035 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w500),
//                     textAlign: TextAlign.center,
//                   ),

//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   //MY

//   //  Future<Map<String, dynamic>> fetchRelevantDetails() async {
//   //   const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
//   //   final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
//   // <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   //   <soap:Body>
//   //     <get_MSAN_details_2_new xmlns="http://tempuri.org/">

//   //     </get_MSAN_details_2_new>
//   //   </soap:Body>
//   // </soap:Envelope>''';
//   //   final response = await http.post(
//   //     Uri.parse(url),
//   //     headers: {
//   //       'Content-Type': 'text/xml; charset=utf-8',
//   //       'SOAPAction': 'http://tempuri.org/get_MSAN_details_2_new',
//   //     },
//   //     body: soapXML,
//   //   );

//   //   if (response.statusCode == 200) {
//   //     String soapResponse = response.body;
//   //     RegExp regex1 = RegExp(r'<get_MSAN_details_2_newResult>(.*?)<\/get_MSAN_details_2_newResult>');
//   //     String result = regex1.firstMatch(soapResponse)?.group(1) ?? '';
//   //     List<String> fields = result.split('::');
//   //     String eleName = fields[0];
//   //     String nwEngName = fields[3];
//   //     String site = fields[5];
//   //     String num1 = fields[9];
//   //     String num2 = fields[11];
//   //     String num3 = fields[13];
//   //     String num4 = fields[15];
//   //     String num5 = fields[17];
//   //     String num6 = fields[7];
//   //     String vendor = fields[18];
//   //     String contName1 = fields[8];
//   //     String contName2 = fields[10];
//   //     String contName3 = fields[12];
//   //     String contName4 = fields[14];
//   //     String contName5 = fields[16];
//   //     String contName6 = fields[6];
//   //     String issues = fields[19];
//   //     String cscid=fields[20];
//   //     String AGG=fields[21];
//   //     String ODF=fields[22];

//   //     // Extract data before '=' symbol
//   //     int indexOfEquals = issues.indexOf('=');
//   //     String issues2 = indexOfEquals != -1 ? issues.substring(0, indexOfEquals) : issues;
//   //     print('Issues2: $issues2');

//   //     return {
//   //       'eleName': eleName, // Corrected key name
//   //       'nwEngName': nwEngName,
//   //       'site': site,
//   //       'num1': num1,
//   //       'num2': num2,
//   //       'num3': num3,
//   //       'num4': num4,
//   //       'num5': num5,
//   //       'num6': num6,
//   //       'vendor': vendor,
//   //       'contName1': contName1,
//   //       'contName2': contName2,
//   //       'contName3': contName3,
//   //       'contName4': contName4,
//   //       'contName5': contName5,
//   //       'contName6': contName6,
//   //       'issues': issues,
//   //       'issues2': issues2,
//   //       'CSCID':cscid,
//   //       'AGG':AGG,
//   //       'ODF':ODF
//   //     };
//   //   }
//   //   else {
//   //     throw Exception('Failed to fetch coordinates');
//   //   }
//   // }
// }

//end original this file code //

// This is Original code enother file. this code is work
// DO NOT edit

// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
// import 'package:flutter/material.dart';
// import 'package:sltnoc/alarms/alarms_page.dart';
// import 'package:sltnoc/clarity_page.dart';
// import 'package:sltnoc/escalations_page.dart';
// import 'package:sltnoc/planOutages/plan_Outages.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/app_config.dart';
// import 'package:permission_handler/permission_handler.dart';

// class MyHomePage extends StatefulWidget {
//   final String displayName;
//   const MyHomePage({Key? key, required this.displayName}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
//   late GoogleMapController _googleMapController;
//   Map<String, bool> engNameList = {};
//   Set<Marker> _markers = {};
//   bool _isLoading = true;

//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _requestLocationPermission();
//     fetchDataAndProcess();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Future<void> _requestLocationPermission() async {
//   //   final PermissionStatus status = await Permission.locationWhenInUse.request();
//   //   if (status != PermissionStatus.granted) {
//   //     // Handle denied or restricted permissions
//   //   }
//   // }

//   Future<void> _requestLocationPermission() async {
//   try {
//     final PermissionStatus status = await Permission.locationWhenInUse.request();
//     if (status != PermissionStatus.granted) {
//       // Handle denied or restricted permissions
//       print("Location permission denied or restricted.");
//     }
//   } catch (e) {
//     // Handle any unexpected errors
//     print("An error occurred while requesting location permission: $e");
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 3.0, right: 3.0),
//               child: Image.asset('assets/SLTLogo.png', width: 0.05 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//             ),
//             SizedBox(width: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//             Text(
//               'NOC Portal',
//               style: TextStyle(fontSize: 0.045 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF0056a2),
//         toolbarHeight: 0.13 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
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
//         padding: EdgeInsets.all(0.04 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text.rich(
//                 TextSpan(
//                   text: 'Hello, ',
//                   style: TextStyle(fontSize: 0.04 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w400),
//                   children: [
//                     TextSpan(
//                       text: '${widget.displayName}! 👋',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 0.04 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 0.03 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//               SizedBox(
//                 height: 1 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//                 child: FractionallySizedBox(
//                   widthFactor: 1.0,
//                   heightFactor: 1.0,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(5),
//                     child: Stack(
//                       children: [
//                         _buildGoogleMapWithLoading(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 0.03 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(AppConfig.cardBackgroundImagePath),
//                     fit: BoxFit.cover,
//                   ),
//                   borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: _buildLegacyBarItem('MSAN', Colors.blue),
//                       ),
//                       SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                       Expanded(
//                         child: _buildLegacyBarItem('CEA', Colors.green),
//                       ),
//                       // SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                       // Expanded(
//                       //   child: _buildLegacyBarItem('GPON', Colors.orange),
//                       // ),
//                       SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                       Expanded(
//                         child: _buildLegacyBarItem('RPB', Colors.yellow),
//                       ),
//                       SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                       Expanded(
//                         child: _buildLegacyBarItem('OTHER', Colors.red),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//               Row(
//                 children: [
//                   Expanded(
//                     child: MyCard(
//                       title: 'ALARMS',
//                       displayName: widget.displayName,
//                       subtitle: 'Network Alarms',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'alarms',
//                     ),
//                   ),
//                   SizedBox(width: 0.03 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Expanded(
//                     child: MyCard(
//                       title: 'OSS',
//                       displayName: widget.displayName,
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
//                       displayName: widget.displayName,
//                       subtitle: 'Fault Escalations',
//                       newSubtitle: 'FMT / SAT',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'escalations',
//                     ),
//                   ),
//                   SizedBox(width: 0.03 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Expanded(
//                     child: MyCard(
//                       title: 'COMMERCIAL POs',
//                       displayName: widget.displayName,
//                       subtitle: 'Planned Outages',
//                       newSubtitle: 'EMS / NMS',
//                       borderColor: Color(0xFF0056A2),
//                       page: 'planOutages',
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

//   Widget _buildGoogleMapWithLoading() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Stack(
//       children: [
//         Container(
//           height: 1 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//           child: FractionallySizedBox(
//             widthFactor: 1.0,
//             heightFactor: 1.0,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(5),
//               child: GoogleMap(
//                 gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//                   Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
//                 }.toSet(),
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(7.8731, 80.7718),
//                   zoom: 7,
//                 ),
//                 trafficEnabled: true,
//                 markers: _markers,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 onMapCreated: (controller) {
//                   _googleMapController = controller;
//                 },
//               ),
//             ),
//           ),
//         ),
//         if (_isLoading)
//           Container(
//             color: Colors.black.withOpacity(0.7),
//             height: 1 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(
//                     backgroundColor: Colors.white,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Colors.blue,
//                     ),
//                   ),
//                   SizedBox(height: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Text(
//                     'Fetching Node Down alarms upto 4 days...',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 0.035 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildLegacyBarItem(String itemName, Color color) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), horizontal: 0.03 * MediaQuery.of(context).size.width),
//       child: Row(
//         children: [
//           Container(
//             width: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//             height: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight),
//             color: color,
//             margin: EdgeInsets.only(right: 0.02 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//           ),
//           Text(
//             itemName,
//             style: TextStyle(fontSize: 0.035 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> fetchDataAndProcess() async {
//     await fetchEngNameList();
//     if (engNameList.containsKey(widget.displayName)) {
//       await process2();
//     } else {
//       await process1(nweng: '...ALL...');
//       print('${widget.displayName} not found in engNameList');
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> fetchEngNameList() async {
//     final fullEngListResponse = await http.post(
//       Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/fullenglist',
//       },
//       body: '''<?xml version="1.0" encoding="utf-8"?>
//         <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//           <soap:Body>
//             <fullenglist xmlns="http://tempuri.org/">
//             </fullenglist>
//           </soap:Body>
//         </soap:Envelope>''',
//     );

//     if (fullEngListResponse.statusCode == 200) {
//       final fullEngListXml = xml.XmlDocument.parse(fullEngListResponse.body);
//       final fullEngListResult = fullEngListXml.findAllElements('fullenglistResult').single.text;

//       final names = fullEngListResult.split(',').map((record) {
//         final name = record.split('::')[0];
//         return name.trim();
//       });

//       for (final name in names) {
//         engNameList[name] = true;
//       }
//     } else {
//       print('Failed to fetch engNameList: ${fullEngListResponse.statusCode}');
//     }
//     print(engNameList);
//   }

//   Future<void> process1({required String nweng}) async {
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
//             <nweng>${nweng}</nweng>
//             <alarm_type>Node Down</alarm_type>
//           </faults3>
//         </soap:Body>
//       </soap:Envelope>''',
//     );
//     print('Faults 3 Response: ${faults3Response.body}');

//     if (faults3Response.statusCode == 200) {
//       final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
//       final faults3Result = faults3Xml.findAllElements('faults3Result').single.text;

//       final timeFilteredMSANs = <String>[];
//       final faults = faults3Result.split(',');
//       for (final fault in faults) {
//         final fields = fault.split('::');
//         final hours = int.tryParse(fields[2].trim().split(' ')[0]);
//         if (hours != null && hours <= 96) {
//           timeFilteredMSANs.add(fault);
//         }
//       }

//       print(timeFilteredMSANs);

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
//       print(finalMapWithGeo);
//       updateMarkers(finalMapWithGeo);
//     }
//   }

//   Future<void> process2() async {
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
//             <nweng>${widget.displayName}</nweng>
//             <alarm_type>Node Down</alarm_type>
//           </faults3>
//         </soap:Body>
//       </soap:Envelope>''',
//     );
//     print('Faults 3 Response: ${faults3Response.body}');

//     if (faults3Response.statusCode == 200) {
//       final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
//       final faults3Result = faults3Xml.findAllElements('faults3Result').single.text;

//       if (faults3Result == 'NO ALARMS') {
//         final sriLankaLatLng = LatLng(7.8731, 80.7718);
//         final cameraPosition = CameraPosition(target: sriLankaLatLng, zoom: 7);
//         _googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//       } else {
//         process1(nweng: widget.displayName);
//       }
//     }
//   }

//   void updateMarkers(List<String> msansWithGeo) {
//     final updatedMarkers = msansWithGeo.map((msanWithGeo) {
//       final parts = msanWithGeo.split('::');
//       print('Parts length: ${parts.length}');
//       print('Parts: ${parts}');
//       if (parts.length >= 7) {
//         final lat = double.tryParse(parts[5]);
//         final lng = double.tryParse(parts[6]);
//         if (lat != null && lng != null) {
//           BitmapDescriptor markerIcon;
//           switch (parts[4]) {
//             case 'MSAN':
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//               break;
//             case 'CEA':
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//               break;
//             // case 'GPON':
//             //   markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
//             //   break;
//             case 'RPB':
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
//               break;
//             default:
//               markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//               break;
//           }

//           return Marker(
//             markerId: MarkerId(parts[0]),
//             position: LatLng(lng, lat),
//             icon: markerIcon,
//             infoWindow: InfoWindow(
//               title: parts[0],
//               snippet: parts[2] + '| ' + parts[3],
//             ),
//           );
//         } else {
//           return null;
//         }
//       } else {
//         return null;
//       }
//     }).where((marker) => marker != null).map((marker) => marker!).toSet();
//     print(updatedMarkers);
//     if (mounted) {
//       setState(() {
//         _markers = updatedMarkers;
//       });
//     }
//   }
// }

// class MyCard extends StatelessWidget {
//   final String title;
//   final String displayName;
//   final String subtitle;
//   final String newSubtitle;
//   final Color borderColor;
//   final String page;

//   const MyCard({
//     Key? key,
//     required this.title,
//     required this.displayName,
//     required this.subtitle,
//     required this.newSubtitle,
//     required this.borderColor,
//     required this.page,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
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
//         } else if (page == 'planOutages') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PlanOutagesPage(
//                 title: 'Planned Outages',
//                 name: displayName,
//               ),
//             ),
//           );
//         }
//       },
//       splashColor: Colors.white,
//       child: Card(
//         elevation: AppConfig.elevation,
//         margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//         ),
//         color: Colors.white,
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(AppConfig.cardBackgroundImagePath),
//               fit: BoxFit.cover,
//             ),
//             borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(AppConfig.homePageCardPadding),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 0.04 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w900, color: Colors.black),
//                   textAlign: TextAlign.center,
//                 ),

//                   SizedBox(height: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Text(
//                     subtitle,
//                     style: TextStyle(color: Color(0xFF0056A2), fontSize: 0.035 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w500),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
//                   Text(
//                     newSubtitle,
//                     style: TextStyle(color: Color(0xFF50B748), fontSize: 0.035 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight), fontWeight: FontWeight.w500),
//                     textAlign: TextAlign.center,
//                   ),

//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

///////////////////// Original code working properly //////

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/material.dart';
import 'package:sltnoc/alarms/alarms_page.dart';
import 'package:sltnoc/clarity_page.dart';
import 'package:sltnoc/escalations_page.dart';
import 'package:sltnoc/planOutages/plan_Outages.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sltnoc/app_config.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  final String displayName;
  const MyHomePage({Key? key, required this.displayName}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late GoogleMapController _googleMapController;
  Map<String, bool> engNameList = {};
  Set<Marker> _markers = {};
  bool _isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _requestLocationPermission();
    fetchDataAndProcess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Future<void> _requestLocationPermission() async {
  //   final PermissionStatus status = await Permission.locationWhenInUse.request();
  //   if (status != PermissionStatus.granted) {
  //     // Handle denied or restricted permissions
  //   }
  // }

  Future<void> _requestLocationPermission() async {
    try {
      final PermissionStatus status =
          await Permission.locationWhenInUse.request();
      if (status != PermissionStatus.granted) {
        // Handle denied or restricted permissions
        print("Location permission denied or restricted.");
      }
    } catch (e) {
      // Handle any unexpected errors
      print("An error occurred while requesting location permission: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 3.0, right: 3.0),
              child: Image.asset('assets/SLTLogo.png',
                  width: 0.05 *
                      (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth
                          : screenHeight)),
            ),
            SizedBox(
                width: 0.02 *
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenWidth
                        : screenHeight)),
            Text(
              'NOC Portal',
              style: TextStyle(
                  fontSize: 0.045 *
                      (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth
                          : screenHeight),
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0056a2),
        toolbarHeight: 0.13 *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? screenWidth
                : screenHeight),
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
        padding: EdgeInsets.all(0.04 *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? screenWidth
                : screenHeight)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Hello, ',
                  style: TextStyle(
                      fontSize: 0.04 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.w400),
                  children: [
                    TextSpan(
                      text: '${widget.displayName}! 👋',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 0.04 *
                            (MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? screenWidth
                                : screenHeight),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  height: 0.03 *
                      (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth
                          : screenHeight)),
              SizedBox(
                height: 1 *
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenWidth
                        : screenHeight),
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: [
                        _buildGoogleMapWithLoading(),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: 0.03 *
                      (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth
                          : screenHeight)),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConfig.cardBackgroundImagePath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppConfig.cardBorderRadius),
                ),
                child: Padding(
                  padding: EdgeInsets.all(0.01 *
                      (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth
                          : screenHeight)),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLegacyBarItem('MSAN', Colors.blue),
                      ),
                      SizedBox(
                          width: 0.01 *
                              (MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? screenWidth
                                  : screenHeight)),
                      Expanded(
                        child: _buildLegacyBarItem('CEA', Colors.green),
                      ),
                      // SizedBox(width: 0.01 * (MediaQuery.of(context).orientation == Orientation.portrait ? screenWidth : screenHeight)),
                      // Expanded(
                      //   child: _buildLegacyBarItem('GPON', Colors.orange),
                      // ),
                      SizedBox(
                          width: 0.01 *
                              (MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? screenWidth
                                  : screenHeight)),
                      Expanded(
                        child: _buildLegacyBarItem('RPB', Colors.yellow),
                      ),
                      SizedBox(
                          width: 0.01 *
                              (MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? screenWidth
                                  : screenHeight)),
                      Expanded(
                        child: _buildLegacyBarItem('OTHER', Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                  height: 0.02 *
                      (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth
                          : screenHeight)),
              Row(
                children: [
                  Expanded(
                    child: MyCard(
                      title: 'ALARMS',
                      displayName: widget.displayName,
                      subtitle: 'Network Alarms',
                      newSubtitle: 'EMS / NMS',
                      borderColor: Color(0xFF0056A2),
                      page: 'alarms',
                    ),
                  ),
                  SizedBox(
                      width: 0.03 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight)),
                  Expanded(
                    child: MyCard(
                      title: 'OSS',
                      displayName: widget.displayName,
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
                      displayName: widget.displayName,
                      subtitle: 'Fault Escalations',
                      newSubtitle: 'FMT / SAT',
                      borderColor: Color(0xFF0056A2),
                      page: 'escalations',
                    ),
                  ),
                  SizedBox(
                      width: 0.03 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight)),
                  Expanded(
                    child: MyCard(
                      title: 'COMMERCIAL POs',
                      displayName: widget.displayName,
                      subtitle: 'Planned Outages',
                      newSubtitle: 'EMS / NMS',
                      borderColor: Color(0xFF0056A2),
                      page: 'planOutages',
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

  Widget _buildGoogleMapWithLoading() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Container(
          height: 1 *
              (MediaQuery.of(context).orientation == Orientation.portrait
                  ? screenWidth
                  : screenHeight),
          child: FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: GoogleMap(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer()),
                }.toSet(),
                initialCameraPosition: CameraPosition(
                  target: LatLng(7.8731, 80.7718),
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
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.7),
            height: 1 *
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? screenWidth
                    : screenHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                  SizedBox(
                      height: 0.01 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight)),
                  Text(
                    'Fetching Node Down alarms upto 4 days...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 0.035 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLegacyBarItem(String itemName, Color color) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: 0.02 *
              (MediaQuery.of(context).orientation == Orientation.portrait
                  ? screenWidth
                  : screenHeight),
          horizontal: 0.03 * MediaQuery.of(context).size.width),
      child: Row(
        children: [
          Container(
            width: 0.02 *
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? screenWidth
                    : screenHeight),
            height: 0.02 *
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? screenWidth
                    : screenHeight),
            color: color,
            margin: EdgeInsets.only(
                right: 0.02 *
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenWidth
                        : screenHeight)),
          ),
          Text(
            itemName,
            style: TextStyle(
                fontSize: 0.035 *
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenWidth
                        : screenHeight)),
          ),
        ],
      ),
    );
  }

  Future<void> fetchDataAndProcess() async {
    await fetchEngNameList();
    if (engNameList.containsKey(widget.displayName)) {
      await process2();
    } else {
      await process1(nweng: '...ALL...');
      print('${widget.displayName} not found in engNameList');
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchEngNameList() async {
    final fullEngListResponse = await http.post(
      Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/fullenglist',
      },
      body: '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <fullenglist xmlns="http://tempuri.org/">
            </fullenglist>
          </soap:Body>
        </soap:Envelope>''',
    );

    if (fullEngListResponse.statusCode == 200) {
      final fullEngListXml = xml.XmlDocument.parse(fullEngListResponse.body);
      final fullEngListResult =
          fullEngListXml.findAllElements('fullenglistResult').single.text;

      final names = fullEngListResult.split(',').map((record) {
        final name = record.split('::')[0];
        return name.trim();
      });

      for (final name in names) {
        engNameList[name] = true;
      }
    } else {
      print('Failed to fetch engNameList: ${fullEngListResponse.statusCode}');
    }
    print(engNameList);
  }

  Future<void> process1({required String nweng}) async {
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
            <nweng>${nweng}</nweng>
            <alarm_type>Node Down</alarm_type>
          </faults3>
        </soap:Body>
      </soap:Envelope>''',
    );
    print('Faults 3 Response: ${faults3Response.body}');

    if (faults3Response.statusCode == 200) {
      final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
      final faults3Result =
          faults3Xml.findAllElements('faults3Result').single.text;

      final timeFilteredMSANs = <String>[];
      final faults = faults3Result.split(',');
      for (final fault in faults) {
        final fields = fault.split('::');
        final hours = int.tryParse(fields[2].trim().split(' ')[0]);
        if (hours != null && hours <= 96) {
          timeFilteredMSANs.add(fault);
        }
      }

      print(timeFilteredMSANs);

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
      print(finalMapWithGeo);
      updateMarkers(finalMapWithGeo);
    }
  }

  Future<void> process2() async {
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
            <alarm_type>Node Down</alarm_type>
          </faults3>
        </soap:Body>
      </soap:Envelope>''',
    );
    print('Faults 3 Response: ${faults3Response.body}');

    if (faults3Response.statusCode == 200) {
      final faults3Xml = xml.XmlDocument.parse(faults3Response.body);
      final faults3Result =
          faults3Xml.findAllElements('faults3Result').single.text;

      if (faults3Result == 'NO ALARMS') {
        final sriLankaLatLng = LatLng(7.8731, 80.7718);
        final cameraPosition = CameraPosition(target: sriLankaLatLng, zoom: 7);
        _googleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      } else {
        process1(nweng: widget.displayName);
      }
    }
  }

  //////

  void updateMarkers(List<String> msansWithGeo) {
    final updatedMarkers = msansWithGeo
        .map((msanWithGeo) {
          final parts = msanWithGeo.split('::');
          print('Parts length: ${parts.length}');
          print('Parts: ${parts}');
          if (parts.length >= 7) {
            final lat = double.tryParse(parts[5]);
            final lng = double.tryParse(parts[6]);
            if (lat != null && lng != null) {
              BitmapDescriptor markerIcon;
              switch (parts[4]) {
                case 'MSAN':
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure);
                  break;
                case 'CEA':
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen);
                  break;
                // case 'GPON':
                //   markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
                //   break;
                case 'RPB':
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow);
                  break;
                default:
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed);
                  break;
              }

              // String snippetText = parts[2] + ' | ' + parts[3];
              // if (parts.length > 7) snippetText += ' | ' + parts[7];
              // if (parts.length > 8) snippetText += ' | ' + parts[8];
              // if (parts.length > 20) snippetText += ' | ' + parts[20];

              return Marker(
                markerId: MarkerId(parts[0]),
                position: LatLng(lng, lat),
                icon: markerIcon,
                infoWindow: InfoWindow(
                  title: parts[0],
                  snippet: parts[2] + '| ' + parts[3],
                  //  snippet: snippetText,
                ),
              );
            } else {
              return null;
            }
          } else {
            return null;
          }
        })
        .where((marker) => marker != null)
        .map((marker) => marker!)
        .toSet();
    print(updatedMarkers);
    if (mounted) {
      setState(() {
        _markers = updatedMarkers;
      });
    }
  }

  /////
}

class MyCard extends StatelessWidget {
  final String title;
  final String displayName;
  final String subtitle;
  final String newSubtitle;
  final Color borderColor;
  final String page;

  const MyCard({
    Key? key,
    required this.title,
    required this.displayName,
    required this.subtitle,
    required this.newSubtitle,
    required this.borderColor,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
        } else if (page == 'planOutages') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanOutagesPage(
                title: 'Planned Outages',
                name: displayName,
              ),
            ),
          );
        }
      },
      splashColor: Colors.white,
      child: Card(
        elevation: AppConfig.elevation,
        margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig.cardBackgroundImagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppConfig.homePageCardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 0.04 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    height: 0.01 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight)),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: Color(0xFF0056A2),
                      fontSize: 0.035 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    height: 0.01 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight)),
                Text(
                  newSubtitle,
                  style: TextStyle(
                      color: Color(0xFF50B748),
                      fontSize: 0.035 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
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
}

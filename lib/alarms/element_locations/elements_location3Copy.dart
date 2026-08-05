// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/settings_button.dart'; // Make sure to import your SettingsButton if it's custom
//
// class ElementsLocationPage3 extends StatelessWidget {
//   final String name;
//   final String elementName;
//
//   const ElementsLocationPage3({Key? key, required this.name, required this.elementName}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Element Locations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         backgroundColor: const Color(0xFF00305e),
//         iconTheme: const IconThemeData(color: Colors.white),
//         toolbarHeight: 70,
//         actions: const [
//           SettingsButton(),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Display dynamic information based on name and elementName
//             _buildText('Name:', name),
//             const SizedBox(height: 8), // Add some vertical spacing
//             _buildText('Element Name:', elementName),
//             const SizedBox(height: 16), // Add some vertical spacing
//             Expanded(
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(7.747199, 79.984066), // Example coordinates
//                   zoom: 14,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: MarkerId('marker_1'),
//                     position: LatLng(7.747199, 79.984066), // Example coordinates
//                     infoWindow: InfoWindow(
//                       title: 'Marker Title',
//                       snippet: 'Marker Snippet',
//                     ),
//                   ),
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildText(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//             const SizedBox(width: 8), // Add some spacing between label and value
//             Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2))), // Change color as needed
//           ],
//         ),
//       ],
//     );
//   }
//
// }

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http; // Import http package
// import 'package:xml/xml.dart' as xml;
//
// class ElementsLocationPage3 extends StatelessWidget {
//   final String name;
//   final String elementName;
//
//   const ElementsLocationPage3({Key? key, required this.name, required this.elementName}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: fetchCoordinates(), // Fetch coordinates from SOAP response
//       builder: (context, AsyncSnapshot<List<double>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             appBar: AppBar(
//               title: Text(
//                 'Element Locations',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               backgroundColor: Color(0xFF00305e),
//               iconTheme: IconThemeData(color: Colors.white),
//               toolbarHeight: 70,
//             ),
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         } else {
//           if (snapshot.hasError) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text(
//                   'Element Locations',
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//                 backgroundColor: Color(0xFF00305e),
//                 iconTheme: IconThemeData(color: Colors.white),
//                 toolbarHeight: 70,
//               ),
//               body: Center(
//                 child: Text('Error: ${snapshot.error}'),
//               ),
//             );
//           } else {
//             List<double> coordinates = snapshot.data ?? [0.0, 0.0];
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text(
//                   'Element Locations',
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//                 backgroundColor: Color(0xFF00305e),
//                 iconTheme: IconThemeData(color: Colors.white),
//                 toolbarHeight: 70,
//               ),
//               body: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildText('Name:', name),
//                     SizedBox(height: 8),
//                     _buildText('Element Name:', elementName),
//                     SizedBox(height: 16),
//                     Expanded(
//                       child: GoogleMap(
//                         initialCameraPosition: CameraPosition(
//                           target: LatLng(coordinates[1], coordinates[0]), // Coordinates swapped as per your requirement
//                           zoom: 14,
//                         ),
//                         markers: {
//                           Marker(
//                             markerId: MarkerId('marker_1'),
//                             position: LatLng(coordinates[1], coordinates[0]), // Coordinates swapped as per your requirement
//                             infoWindow: InfoWindow(
//                               title: 'Marker Title',
//                               snippet: 'Marker Snippet',
//                             ),
//                           ),
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         }
//       },
//     );
//   }
//
//   Widget _buildText(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//             SizedBox(width: 8),
//             Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2))),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Future<List<double>> fetchCoordinates() async {
//     final String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx'; // Define your SOAP API URL
//     final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
//       <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//         <soap:Body>
//           <get_MSAN_details xmlns="http://tempuri.org/">
//             <msan>$elementName</msan>
//           </get_MSAN_details>
//         </soap:Body>
//       </soap:Envelope>'''; // Define your SOAP request XML
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/get_MSAN_details',
//       },
//       body: soapXML,
//     );
//
//     if (response.statusCode == 200) {
//       // Parse SOAP response to extract coordinates
//       String soapResponse = response.body;
//       RegExp regex = RegExp(r'<get_MSAN_detailsResult>(.*?)<\/get_MSAN_detailsResult>');
//       String result = regex.firstMatch(soapResponse)?.group(1) ?? '';
//       List<String> fields = result.split('::');
//       double longitude = double.parse(fields[1]);
//       double latitude = double.parse(fields[2]);
//       return [longitude, latitude];
//     } else {
//       throw Exception('Failed to fetch coordinates');
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:location/location.dart';

class CustomInfoWidget extends StatelessWidget {
  final String title;
  final Map<String, dynamic> fields; // Change the type to Map<String, dynamic>
  final double lineSpacing;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const CustomInfoWidget({
    super.key,
    required this.title,
    required this.fields,
    this.lineSpacing = 8.0,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(title),
          SizedBox(height: lineSpacing),
          _buildInfoRow('NW Eng:', fields['nwEngName'].toString()),
          _buildInfoRow('Site:', fields['site'].toString()),
          const SizedBox(height: 16),
          _buildInfoRow('${fields['contName1']} :', fields['num1'].toString()),
          _buildInfoRow('${fields['contName2']} :', fields['num2'].toString()),
          _buildInfoRow('${fields['contName3']} :', fields['num3'].toString()),
          _buildInfoRow('${fields['contName4']} :', fields['num4'].toString()),
          _buildInfoRow('${fields['contName5']} :', fields['num5'].toString()),
          _buildInfoRow('${fields['contName6']} :', fields['num6'].toString()),
          const SizedBox(height: 16),
          _buildInfoRow('Issue:', fields['issues'].toString()),
          _buildInfoRow('Vendor:', fields['vendor'].toString()),
        ],
      ),
    );
  }

  Widget _buildTitleRow(String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: lineSpacing),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0056A2),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          label,
          style: labelStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SelectableText(
            // Wrap with SelectableText
            value,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0056A2),
                ),
          ),
        ),
      ],
    );
  }
}

class ElementsLocationPage3 extends StatefulWidget {
  final String name;
  final String elementName;

  const ElementsLocationPage3(
      {Key? key, required this.name, required this.elementName})
      : super(key: key);

  @override
  _ElementsLocationPage3State createState() => _ElementsLocationPage3State();
}

class _ElementsLocationPage3State extends State<ElementsLocationPage3> {
  late GoogleMapController _controller;
  late MapType _currentMapType;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    _currentMapType = MapType.normal;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchElementDetails(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Element Locations',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF00305e),
              iconTheme: const IconThemeData(color: Colors.white),
              toolbarHeight: 70,
              actions: const [
                SettingsButton(),
              ],
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Element Locations',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF00305e),
                iconTheme: const IconThemeData(color: Colors.white),
                toolbarHeight: 70,
              ),
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else {
            Map<String, dynamic> data = snapshot.data ?? {};
            List<double> coordinates = data['coordinates'] ?? [0.0, 0.0];

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Element Locations',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF00305e),
                iconTheme: const IconThemeData(color: Colors.white),
                toolbarHeight: 70,
                actions: const [
                  SettingsButton(),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText('Name:', widget.name),
                    const SizedBox(height: 8),
                    _buildText('Element Name:', widget.elementName),
                    const SizedBox(height: 16),
                    _buildButtons(coordinates),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(coordinates[1], coordinates[0]),
                          zoom: 16,
                        ),
                        onMapCreated: (controller) => _controller = controller,
                        trafficEnabled: true,
                        mapType: _currentMapType,
                        markers: {
                          Marker(
                            markerId: const MarkerId('marker_1'),
                            position: LatLng(coordinates[1], coordinates[0]),
                            infoWindow: const InfoWindow(
                              // Set to an empty InfoWindow to disable default behavior
                              title: '',
                              snippet: '',
                            ),
                            icon: BitmapDescriptor.defaultMarker,
                            onTap: () {
                              // Show custom info window when marker is tapped
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SizedBox(
                                    height: 350,
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          16.0), // Adjust the radius as needed
                                      child: SingleChildScrollView(
                                        child: CustomInfoWidget(
                                          title: data['eleName'] ??
                                              '', // Ensure eleName is not null or empty
                                          fields: data,
                                          // fields: location,
                                          lineSpacing:
                                              8.0, // Adjust line spacing as needed
                                          labelStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          valueStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF0056A2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(width: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0056A2))),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons(List<double> coordinates) {
    String satelliteButtonText =
        _currentMapType == MapType.normal ? 'Satellite' : 'Normal';

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentMapType = _currentMapType == MapType.normal
                    ? MapType.hybrid
                    : MapType.normal;
              });
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey.shade300),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            child: Text(satelliteButtonText,
                style: const TextStyle(
                    color: Color(0xFF00305e),
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 8),
        // Expanded(
        //   flex: 1,
        //   child: ElevatedButton(
        //     onPressed: _goToCurrentLocation,
        //     style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
        //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        //         RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(5.0),
        //         ),
        //       ),
        //     ),
        //     child: const Text('Current', style: TextStyle(color: Color(0xFF00305e), fontSize: 16, fontWeight: FontWeight.w700)),
        //   ),
        // ),
        // const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              _goToElementLocation(coordinates);
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey.shade300),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            child: const Text('Element',
                style: TextStyle(
                    color: Color(0xFF00305e),
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  // Future<Map<String, dynamic>> fetchCoordinates() async {
  //   const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
  //   final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
  //     <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  //       <soap:Body>
  //         <get_MSAN_details xmlns="http://tempuri.org/">
  //           <msan>${widget.elementName}</msan>
  //         </get_MSAN_details>
  //       </soap:Body>
  //     </soap:Envelope>''';
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {
  //       'Content-Type': 'text/xml; charset=utf-8',
  //       'SOAPAction': 'http://tempuri.org/get_MSAN_details',
  //     },
  //     body: soapXML,
  //   );
  //
  //   if (response.statusCode == 200) {
  //     String soapResponse = response.body;
  //     RegExp regex = RegExp(r'<get_MSAN_detailsResult>(.*?)<\/get_MSAN_detailsResult>');
  //     String result = regex.firstMatch(soapResponse)?.group(1) ?? '';
  //     List<String> fields = result.split('::');
  //     String eleName = fields[0];
  //     double longitude = double.parse(fields[1]);
  //     double latitude = double.parse(fields[2]);
  //     String nwEngName = fields[3];
  //     String site = fields[5];
  //     String num1 = fields[6];
  //     String num2 = fields[7];
  //     String num3 = fields[8];
  //     String num4 = fields[9];
  //     String vendor = fields[10];
  //     String contName1 = fields[11];
  //     String contName2 = fields[12];
  //     String contName3 = fields[13];
  //     String contName4 = fields[14];
  //     String issues = fields.isNotEmpty ? fields.last : '';
  //
  //     return {
  //       'coordinates': [longitude, latitude],
  //       'eleName': eleName,
  //       'nwEngName': nwEngName,
  //       'site': site,
  //       'num1': num1,
  //       'num2': num2,
  //       'num3': num3,
  //       'num4': num4,
  //       'vendor': vendor,
  //       'contName1': contName1,
  //       'contName2': contName2,
  //       'contName3': contName3,
  //       'contName4': contName4,
  //       'issues': issues
  //     };
  //   } else {
  //     throw Exception('Failed to fetch coordinates');
  //   }
  // }
  Future<Map<String, dynamic>> fetchElementDetails() async {
    try {
      Map<String, dynamic> coordinatesData = await fetchCoordinates();
      Map<String, dynamic> relevantDetailsData = await fetchRelevantDetails();

      // Combine the data from both requests
      Map<String, dynamic> combinedData = {
        ...coordinatesData,
        ...relevantDetailsData,
      };

      return combinedData;
    } catch (e) {
      throw Exception('Failed to fetch element details: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCoordinates() async {
    const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <get_MSAN_Location xmlns="http://tempuri.org/">
          <node>${widget.elementName}</node>
        </get_MSAN_Location>
      </soap:Body>
    </soap:Envelope>''';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/get_MSAN_Location',
      },
      body: soapXML,
    );

    if (response.statusCode == 200) {
      String soapResponse = response.body;
      RegExp regex =
          RegExp(r'<get_MSAN_LocationResult>(.*?)<\/get_MSAN_LocationResult>');
      String result = regex.firstMatch(soapResponse)?.group(1) ?? '';
      List<String> coordinates = result.split('::');
      double longitude = double.parse(coordinates[0]);
      double latitude = double.parse(coordinates[1]);

      return {
        'coordinates': [longitude, latitude],
      };
    } else {
      throw Exception('Failed to fetch coordinates');
    }
  }

  Future<Map<String, dynamic>> fetchRelevantDetails() async {
    const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <get_MSAN_details_2 xmlns="http://tempuri.org/">
        <msan>${widget.elementName}</msan>
      </get_MSAN_details_2>
    </soap:Body>
  </soap:Envelope>''';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/get_MSAN_details_2',
      },
      body: soapXML,
    );

    if (response.statusCode == 200) {
      String soapResponse = response.body;
      RegExp regex1 = RegExp(
          r'<get_MSAN_details_2Result>(.*?)<\/get_MSAN_details_2Result>');
      String result = regex1.firstMatch(soapResponse)?.group(1) ?? '';
      List<String> fields = result.split('::');
      String eleName = fields[0];
      String nwEngName = fields[3];
      String site = fields[5];
      String num1 = fields[6];
      String num2 = fields[7];
      String num3 = fields[8];
      String num4 = fields[9];
      String num5 = fields[17];
      String num6 = fields[19];
      String vendor = fields[10];
      String contName1 = fields[11];
      String contName2 = fields[12];
      String contName3 = fields[13];
      String contName4 = fields[14];
      String contName5 = fields[16];
      String contName6 = fields[18];
      String issues = fields[15];

      return {
        'eleName': eleName, // Corrected key name
        'nwEngName': nwEngName,
        'site': site,
        'num1': num1,
        'num2': num2,
        'num3': num3,
        'num4': num4,
        'num5': num5,
        'num6': num6,
        'vendor': vendor,
        'contName1': contName1,
        'contName2': contName2,
        'contName3': contName3,
        'contName4': contName4,
        'contName5': contName5,
        'contName6': contName6,
        'issues': issues
      };
    } else {
      throw Exception('Failed to fetch coordinates');
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      LocationData locationData = await location.getLocation();

      _controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(locationData.latitude!, locationData.longitude!),
        16,
      ));
    } catch (e) {
      print("Error: $e");
    }
  }

  void _goToElementLocation(List<double> coordinates) {
    _controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(coordinates[1], coordinates[0]),
      16,
    ));
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
//
// class ElementsLocationPage3 extends StatefulWidget {
//   final String name;
//   final String elementName;
//
//   const ElementsLocationPage3({Key? key, required this.name, required this.elementName}) : super(key: key);
//
//   @override
//   _ElementsLocationPage3State createState() => _ElementsLocationPage3State();
// }
//
// class _ElementsLocationPage3State extends State<ElementsLocationPage3> {
//   late GoogleMapController _controller;
//   late MapType _currentMapType;
//   Location location = Location();
//
//   @override
//   void initState() {
//     super.initState();
//     _currentMapType = MapType.normal;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Element Locations',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF00305e),
//         iconTheme: const IconThemeData(color: Colors.white),
//         toolbarHeight: 70,
//         actions: const [
//           SettingsButton(),
//         ],
//       ),
//       body: FutureBuilder(
//         future: fetchElementDetails(),
//         builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else {
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else {
//               Map<String, dynamic> data = snapshot.data ?? {};
//               List<double> coordinates = data['coordinates'] ?? [0.0, 0.0];
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildText('Name:', widget.name),
//                   const SizedBox(height: 8),
//                   _buildText('Element Name:', widget.elementName),
//                   const SizedBox(height: 16),
//                   _buildButtons(coordinates),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: LatLng(coordinates[1], coordinates[0]),
//                         zoom: 16,
//                       ),
//                       onMapCreated: (controller) => _controller = controller,
//                       mapType: _currentMapType,
//                       markers: {
//                         Marker(
//                           markerId: const MarkerId('marker_1'),
//                           position: LatLng(coordinates[1], coordinates[0]),
//                           infoWindow: InfoWindow(
//                             // Set to an empty InfoWindow to disable default behavior
//                             title: '',
//                             snippet: '',
//                           ),
//                           icon: BitmapDescriptor.defaultMarker,
//                           onTap: () {
//                             // Handle marker tap
//                           },
//                         ),
//                       },
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: true,
//                     ),
//                   ),
//                 ],
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildText(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//             const SizedBox(width: 8),
//             Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2))),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildButtons(List<double> coordinates) {
//     String satelliteButtonText = _currentMapType == MapType.normal ? 'Satellite' : 'Normal';
//
//     return Row(
//       children: [
//         Expanded(
//           flex: 1,
//           child: ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
//               });
//             },
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
//               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                 RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//               ),
//             ),
//             child: Text(satelliteButtonText, style: const TextStyle(color: Color(0xFF00305e), fontSize: 16, fontWeight: FontWeight.w700)),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           flex: 1,
//           child: ElevatedButton(
//             onPressed: () {
//               _goToElementLocation(coordinates);
//             },
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
//               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                 RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//               ),
//             ),
//             child: const Text('Element', style: TextStyle(color: Color(0xFF00305e), fontSize: 16, fontWeight: FontWeight.w700)),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<Map<String, dynamic>> fetchElementDetails() async {
//     try {
//       Map<String, dynamic> coordinatesData = await fetchCoordinates();
//       Map<String, dynamic> relevantDetailsData = await fetchRelevantDetails();
//
//       // Combine the data from both requests
//       Map<String, dynamic> combinedData = {
//         ...coordinatesData,
//         ...relevantDetailsData,
//       };
//
//       return combinedData;
//     } catch (e) {
//       throw Exception('Failed to fetch element details: $e');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchCoordinates() async {
//     const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
//     final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
//       <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//         <soap:Body>
//           <get_MSAN_Location xmlns="http://tempuri.org/">
//             <node>${widget.elementName}</node>
//           </get_MSAN_Location>
//         </soap:Body>
//       </soap:Envelope>''';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/get_MSAN_Location',
//       },
//       body: soapXML,
//     );
//
//     if (response.statusCode == 200) {
//       String soapResponse = response.body;
//       RegExp regex = RegExp(r'<get_MSAN_LocationResult>(.*?)<\/get_MSAN_LocationResult>');
//       String result = regex.firstMatch(soapResponse)?.group(1) ?? '';
//       List<String> fields = result.split('::');
//       double longitude = double.parse(fields[0]);
//       double latitude = double.parse(fields[1]);
//
//       return {
//         'coordinates': [longitude, latitude],
//       };
//     } else {
//       throw Exception('Failed to fetch coordinates');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchRelevantDetails() async {
//     const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
//     final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
//       <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//         <soap:Body>
//           <get_MSAN_details_2 xmlns="http://tempuri.org/">
//             <msan>${widget.elementName}</msan>
//           </get_MSAN_details_2>
//         </soap:Body>
//       </soap:Envelope>''';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/get_MSAN_details_2',
//       },
//       body: soapXML,
//     );
//
//     if (response.statusCode == 200) {
//       String soapResponse = response.body;
//       RegExp regex = RegExp(r'<get_MSAN_details_2Result>(.*?)<\/get_MSAN_details_2Result>');
//       String result = regex.firstMatch(soapResponse)?.group(1) ?? '';
//       List<String> fields = result.split('::');
//       String eleName = fields[0];
//       String nwEngName = fields[3];
//       String site = fields[5];
//       String num1 = fields[6];
//       String num2 = fields[7];
//       String num3 = fields[8];
//       String num4 = fields[9];
//       String vendor = fields[10];
//       String contName1 = fields[11];
//       String contName2 = fields[12];
//       String contName3 = fields[13];
//       String contName4 = fields[14];
//       String issues = fields.isNotEmpty ? fields.last : '';
//
//       return {
//         'eleName': eleName,
//         'nwEngName': nwEngName,
//         'site': site,
//         'num1': num1,
//         'num2': num2,
//         'num3': num3,
//         'num4': num4,
//         'vendor': vendor,
//         'contName1': contName1,
//         'contName2': contName2,
//         'contName3': contName3,
//         'contName4': contName4,
//         'issues': issues
//       };
//     } else {
//       throw Exception('Failed to fetch coordinates');
//     }
//   }
//
//   void _goToElementLocation(List<double> coordinates) {
//     _controller.animateCamera(CameraUpdate.newLatLngZoom(
//       LatLng(coordinates[1], coordinates[0]),
//       16,
//     ));
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sltnoc/settings_button.dart'; // Make sure to import your SettingsButton if it's custom
//
// class ElementsLocationPage3 extends StatelessWidget {
//   final String name;
//   final String elementName;
//
//   const ElementsLocationPage3({Key? key, required this.name, required this.elementName}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Element Locations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         backgroundColor: const Color(0xFF00305e),
//         iconTheme: const IconThemeData(color: Colors.white),
//         toolbarHeight: 70,
//         actions: const [
//           SettingsButton(),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Display dynamic information based on name and elementName
//             _buildText('Name:', name),
//             const SizedBox(height: 8), // Add some vertical spacing
//             _buildText('Element Name:', elementName),
//             const SizedBox(height: 16), // Add some vertical spacing
//             Expanded(
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(7.747199, 79.984066), // Example coordinates
//                   zoom: 14,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: MarkerId('marker_1'),
//                     position: LatLng(7.747199, 79.984066), // Example coordinates
//                     infoWindow: InfoWindow(
//                       title: 'Marker Title',
//                       snippet: 'Marker Snippet',
//                     ),
//                   ),
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildText(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//             const SizedBox(width: 8), // Add some spacing between label and value
//             Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2))), // Change color as needed
//           ],
//         ),
//       ],
//     );
//   }
//
// }
//
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http; // Import http package
// import 'package:xml/xml.dart' as xml;
//
// class ElementsLocationPage3 extends StatelessWidget {
//   final String name;
//   final String elementName;
//
//   const ElementsLocationPage3({Key? key, required this.name, required this.elementName}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: fetchCoordinates(), // Fetch coordinates from SOAP response
//       builder: (context, AsyncSnapshot<List<double>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             appBar: AppBar(
//               title: Text(
//                 'Element Locations',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               backgroundColor: Color(0xFF00305e),
//               iconTheme: IconThemeData(color: Colors.white),
//               toolbarHeight: 70,
//             ),
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         } else {
//           if (snapshot.hasError) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text(
//                   'Element Locations',
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//                 backgroundColor: Color(0xFF00305e),
//                 iconTheme: IconThemeData(color: Colors.white),
//                 toolbarHeight: 70,
//               ),
//               body: Center(
//                 child: Text('Error: ${snapshot.error}'),
//               ),
//             );
//           } else {
//             List<double> coordinates = snapshot.data ?? [0.0, 0.0];
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text(
//                   'Element Locations',
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//                 backgroundColor: Color(0xFF00305e),
//                 iconTheme: IconThemeData(color: Colors.white),
//                 toolbarHeight: 70,
//               ),
//               body: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildText('Name:', name),
//                     SizedBox(height: 8),
//                     _buildText('Element Name:', elementName),
//                     SizedBox(height: 16),
//                     Expanded(
//                       child: GoogleMap(
//                         initialCameraPosition: CameraPosition(
//                           target: LatLng(coordinates[1], coordinates[0]), // Coordinates swapped as per your requirement
//                           zoom: 14,
//                         ),
//                         markers: {
//                           Marker(
//                             markerId: MarkerId('marker_1'),
//                             position: LatLng(coordinates[1], coordinates[0]), // Coordinates swapped as per your requirement
//                             infoWindow: InfoWindow(
//                               title: 'Marker Title',
//                               snippet: 'Marker Snippet',
//                             ),
//                           ),
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         }
//       },
//     );
//   }
//
//   Widget _buildText(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//             SizedBox(width: 8),
//             Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2))),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Future<List<double>> fetchCoordinates() async {
//     final String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx'; // Define your SOAP API URL
//     final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
//       <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//         <soap:Body>
//           <get_MSAN_details xmlns="http://tempuri.org/">
//             <msan>$elementName</msan>
//           </get_MSAN_details>
//         </soap:Body>
//       </soap:Envelope>'''; // Define your SOAP request XML
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/get_MSAN_details',
//       },
//       body: soapXML,
//     );
//
//     if (response.statusCode == 200) {
//       // Parse SOAP response to extract coordinates
//       String soapResponse = response.body;
//       RegExp regex = RegExp(r'<get_MSAN_detailsResult>(.*?)<\/get_MSAN_detailsResult>');
//       String result = regex.firstMatch(soapResponse)?.group(1) ?? '';
//       List<String> fields = result.split('::');
//       double longitude = double.parse(fields[1]);
//       double latitude = double.parse(fields[2]);
//       return [longitude, latitude];
//     } else {
//       throw Exception('Failed to fetch coordinates');
//     }
//   }
// }
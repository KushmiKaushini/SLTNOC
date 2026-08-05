// import 'package:flutter/material.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class NodeDetailsPage extends StatefulWidget {
//   final String alarmType;
//   final String name;
//   final String province;
//   final String nodeName;
//
//   const NodeDetailsPage({
//     Key? key,
//     required this.alarmType,
//     required this.name,
//     required this.province,
//     required this.nodeName,
//   }) : super(key: key);
//
//   @override
//   _NodeDetailsPageState createState() => _NodeDetailsPageState();
// }
//
// class _NodeDetailsPageState extends State<NodeDetailsPage> {
//   List<Map<String, dynamic>> _escalations = []; // Dummy list of escalations
//   bool _isLoading = false; // No need to load when using dummy data
//
//   @override
//   void initState() {
//     super.initState();
//     _generateDummyData();
//   }
//
//   void _generateDummyData() {
//     // Dummy data for escalations
//     _escalations = [
//       {"NAME": "John Doe", "MOBILE": "1234567890"},
//       {"NAME": "Jane Smith", "MOBILE": "0987654321"},
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.nodeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
//         backgroundColor: const Color(0xFF00305e),
//         iconTheme: const IconThemeData(color: Colors.white),
//         toolbarHeight: 70,
//         actions: const [
//           SettingsButton(),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: SizedBox(
//             width: double.infinity,
//             child: Card(
//               color: Colors.grey[50],
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Node Details',
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildText('Node:', widget.nodeName),
//                     _buildText('Alarm Type:', widget.alarmType),
//                     _buildText('NW Engineer:', widget.name),
//                     _buildText('Province:', widget.province),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'Contact Details',
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     _escalations.isEmpty
//                         ? const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 8),
//                       child: Text(
//                         'No data found',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
//                       ),
//                     )
//                         : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         for (var escalation in _escalations)
//                           _buildEscalation('${escalation['NAME']}:', escalation['MOBILE']),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
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
//             Text(
//               label,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2)),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
//
//   Widget _buildEscalation(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 value,
//                 style: label == 'NAME:'
//                     ? const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)
//                     : const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF0056A2)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }
//
//

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:location/location.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class CustomInfoWidget extends StatelessWidget {
  final String title;
  final Map<String, dynamic> fields; // Change the type to Map<String, dynamic>
  final double lineSpacing;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const CustomInfoWidget({
    Key? key,
    required this.title,
    required this.fields,
    this.lineSpacing = 8.0,
    this.labelStyle,
    this.valueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitleRow(context, title),
              GestureDetector(
                // Use GestureDetector for handling tap events
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: Icon(
                  Icons.cancel, // Use cancel icon
                  color:
                      Colors.grey.shade400, // Adjust the icon color as needed
                  // color: Colors.red,
                  size: 30, // Adjust the icon size as needed
                ),
              ),
            ],
          ),
          // SizedBox(height: lineSpacing),
          Divider(color: Colors.grey.shade300),
          _buildInfoRow('NW Engineer:', fields['nwEngName'].toString()),
          _buildInfoRow('Site:', fields['site'].toString()),
          Divider(color: Colors.grey.shade300),
          _buildInfoRow('Fault:', fields['issues'].toString()),
          _buildInfoRow('Vendor:', fields['vendor'].toString()),
          Divider(color: Colors.grey.shade300),
          _buildInfoRow('${fields['contName1']} :', fields['num1'].toString()),
          _buildInfoRow('${fields['contName2']} :', fields['num2'].toString()),
          _buildInfoRow('${fields['contName3']} :', fields['num3'].toString()),
          _buildInfoRow('${fields['contName4']} :', fields['num4'].toString()),
          _buildInfoRow('${fields['contName5']} :', fields['num5'].toString()),
          _buildInfoRow('${fields['contName6']} :', fields['num6'].toString()),

          Divider(color: Colors.grey.shade300),
          _buildInfoRow('CSCID:', fields['CSCID'].toString()),
          _buildInfoRow('AGG:', fields['AGG'].toString()),
          _buildInfoRow('ODF:', fields['ODF'].toString()),
        ],
      ),
    );
  }

  Widget _buildTitleRow(context, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(bottom: lineSpacing),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 0.045 *
              (MediaQuery.of(context).orientation == Orientation.portrait
                  ? screenWidth
                  : screenHeight),
          fontWeight: FontWeight.bold,
          color: Colors.green[600],
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
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0056A2),
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class NodeDetailsPage extends StatefulWidget {
  final String alarmType;
  final String name;
  final String province;
  final String nodeName;

  const NodeDetailsPage({
    Key? key,
    required this.alarmType,
    required this.name,
    required this.province,
    required this.nodeName,
  }) : super(key: key);

  @override
  _NodeDetailsPageState createState() => _NodeDetailsPageState();
}

class _NodeDetailsPageState extends State<NodeDetailsPage> {
  late GoogleMapController _controller;
  late MapType _currentMapType;
  Location location = Location();
  bool _isLoading = true;
  bool _hasCoordinates = false;
  List<double> _coordinates = [0.0, 0.0]; // Default coordinates
  late Map<String, dynamic> _data = {}; // Define _data here

  @override
  void initState() {
    super.initState();
    _currentMapType = MapType.normal;
    _fetchData(); // Fetch both coordinates and relevant details
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch coordinates first
      await _fetchCoordinates();

      // Fetch relevant details
      final data = await fetchRelevantDetails();
      print('Fetched data: $data'); // Debug log

      setState(() {
        _data = data; // Initialize _data with fetched details
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
        // Set empty data on error
        _data = {};
      });
    }
  }

  Future<void> _fetchCoordinates() async {
    try {
      const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
      final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <get_MSAN_Location xmlns="http://tempuri.org/">
            <node>${widget.nodeName}</node>
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
        RegExp regex = RegExp(
            r'<get_MSAN_LocationResult>(.*?)<\/get_MSAN_LocationResult>');
        String result = regex.firstMatch(soapResponse)?.group(1) ?? '';

        if (result == 'NO ALARMS') {
          setState(() {
            _isLoading = false;
          });
        } else {
          List<String> coordinates = result.split('::');
          double longitude = double.parse(coordinates[0]);
          double latitude = double.parse(coordinates[1]);
          setState(() {
            _hasCoordinates = true;
            _coordinates = [latitude, longitude];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch coordinates');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching coordinates: $e');
    }
  }

  Future<Map<String, dynamic>> fetchRelevantDetails() async {
    const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <get_MSAN_details_2_new xmlns="http://tempuri.org/">
        <msan>${widget.nodeName}</msan>
      </get_MSAN_details_2_new>
    </soap:Body>
  </soap:Envelope>''';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/get_MSAN_details_2_new',
      },
      body: soapXML,
    );

    if (response.statusCode == 200) {
      String soapResponse = response.body;
      print('SOAP Response: $soapResponse'); // Debug log
      RegExp regex1 = RegExp(
          r'<get_MSAN_details_2_newResult>(.*?)<\/get_MSAN_details_2_newResult>');
      String result = regex1.firstMatch(soapResponse)?.group(1) ?? '';
      print('Extracted result: $result'); // Debug log

      if (result.isEmpty) {
        print('Warning: Empty result from SOAP response');
        return {}; // Return empty map if no data
      }

      List<String> fields = result.split('::');
      print('Fields count: ${fields.length}'); // Debug log
      print('Fields: $fields'); // Debug log

      // Ensure we have enough fields before accessing them
      if (fields.length < 23) {
        print(
            'Warning: Insufficient fields in response. Expected at least 23, got ${fields.length}');
        return {}; // Return empty map if insufficient data
      }

      String eleName = fields.length > 0 ? fields[0] : '';
      String nwEngName = fields.length > 3 ? fields[3] : '';
      String site = fields.length > 5 ? fields[5] : '';
      String num1 = fields.length > 9 ? fields[9] : '';
      String num2 = fields.length > 11 ? fields[11] : '';
      String num3 = fields.length > 13 ? fields[13] : '';
      String num4 = fields.length > 15 ? fields[15] : '';
      String num5 = fields.length > 17 ? fields[17] : '';
      String num6 = fields.length > 7 ? fields[7] : '';
      String vendor = fields.length > 18 ? fields[18] : '';
      String contName1 = fields.length > 8 ? fields[8] : '';
      String contName2 = fields.length > 10 ? fields[10] : '';
      String contName3 = fields.length > 12 ? fields[12] : '';
      String contName4 = fields.length > 14 ? fields[14] : '';
      String contName5 = fields.length > 16 ? fields[16] : '';
      String contName6 = fields.length > 6 ? fields[6] : '';
      String issues = fields.length > 19 ? fields[19] : '';
      String cscid = fields.length > 20 ? fields[20] : '';
      String AGG = fields.length > 21 ? fields[21] : '';
      String ODF = fields.length > 22 ? fields[22] : '';

      // Extract data before '=' symbol
      int indexOfEquals = issues.indexOf('=');
      String issues2 =
          indexOfEquals != -1 ? issues.substring(0, indexOfEquals) : issues;
      print('Issues2: $issues2');

      Map<String, dynamic> resultMap = {
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
        'issues': issues,
        'issues2': issues2,
        'CSCID': cscid,
        'AGG': AGG,
        'ODF': ODF
      };

      print('Final result map: $resultMap'); // Debug log
      return resultMap;
    } else {
      print('HTTP Error: ${response.statusCode}');
      throw Exception('Failed to fetch node details');
    }
  }

  void _goToElementLocation(List<double> coordinates) {
    _controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(coordinates[0], coordinates[1]),
      16,
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Node Details',
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
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig
                .bodyBackgroundImagePath), // Replace 'background_image.jpg' with your image path
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
        ),
        child: _isLoading
            ? Center(child: CustomLoadingIndicator())
            : _hasCoordinates
                ? _buildMap()
                : _data.isNotEmpty
                    ? _buildDetails(_data)
                    : Center(child: CustomLoadingIndicator()),
      ),
    );
  }

  // Widget _buildMap() {
  //   return Padding(
  //     padding: const EdgeInsets.all(24.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(height: 16),
  //         Expanded(
  //           child: GoogleMap(
  //             initialCameraPosition: CameraPosition(
  //               target: LatLng(_coordinates[0], _coordinates[1]),
  //               zoom: 16,
  //             ),
  //             onMapCreated: (controller) => _controller = controller,
  //             trafficEnabled: true,
  //             mapType: _currentMapType,
  //             markers: {
  //               Marker(
  //                 markerId: const MarkerId('marker_1'),
  //                 position: LatLng(_coordinates[0], _coordinates[1]),
  //                 infoWindow: const InfoWindow(
  //                   // Set to an empty InfoWindow to disable default behavior
  //                   title: '',
  //                   snippet: '',
  //                 ),
  //                 icon: BitmapDescriptor.defaultMarker,
  //                 onTap: () {
  //                   showModalBottomSheet(
  //                     context: context,
  //                     builder: (context) {
  //                       return SizedBox(
  //                         height: 350,
  //                         width: MediaQuery.of(context).size.width,
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(16.0),
  //                           child: SingleChildScrollView(
  //                             child: CustomInfoWidget(
  //                               title: _data['eleName'] ?? '', // Using _data instead of data
  //                               fields: _data, // Passing _data to CustomInfoWidget
  //                               lineSpacing: 8.0,
  //                               labelStyle: const TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.black,
  //                               ),
  //                               valueStyle: const TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w500,
  //                                 color: Color(0xFF0056A2),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   );
  //                 },
  //               ),
  //             },
  //             myLocationEnabled: true,
  //             myLocationButtonEnabled: true,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMap() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFixedText(),
          const SizedBox(height: 8),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: 10), // Adjust margins as needed
            child: _buildButtons(_coordinates),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_coordinates[0], _coordinates[1]),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _controller = controller,
                  trafficEnabled: true,
                  mapType: _currentMapType,
                  markers: {
                    Marker(
                      markerId: const MarkerId('marker_1'),
                      position: LatLng(_coordinates[0], _coordinates[1]),
                      infoWindow: const InfoWindow(
                        title: '',
                        snippet: '',
                      ),
                      icon: BitmapDescriptor.defaultMarker,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(
                                  20), // Add padding to the bottom sheet content
                              child: SizedBox(
                                height: 300,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0),
                                  child: SingleChildScrollView(
                                    child: CustomInfoWidget(
                                      title: _data['eleName'] ??
                                          '', // Using _data instead of data
                                      fields:
                                          _data, // Passing _data to CustomInfoWidget
                                      lineSpacing: 8.0,
                                      labelStyle: TextStyle(
                                          fontSize: 0.037 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      valueStyle: TextStyle(
                                          fontSize: 0.037 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0056A2)),
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
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDetails(Map<String, dynamic> data) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(AppConfig.tablePagePadding),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Node Details',
                  textAlign: AppConfig.NDTitleAlignment,
                  style: TextStyle(
                      fontSize: 0.037 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConfig
                        .cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
                    fit: BoxFit.cover, // Adjust the fit as needed
                  ),
                  borderRadius: BorderRadius.circular(
                      AppConfig.NDBorderRadius), // Match card's border radius
                  border: Border.all(
                      color: AppConfig.NDBorderColor,
                      width: AppConfig.NDBorderWidth),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.NDCardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildText('Node:', widget.nodeName),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('Alarm Type:', widget.alarmType),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('NW Engineer:', widget.name),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('Province:', widget.province),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('Site:', data['site'] ?? 'N/A'),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('Vendor:', data['vendor'] ?? 'N/A'),
                      Divider(color: AppConfig.NDDivider),
                      _buildTextIssue2('Fault:', data['issues'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Contact Details',
                  textAlign: AppConfig.NDTitleAlignment,
                  style: TextStyle(
                      fontSize: 0.037 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConfig
                        .cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
                    fit: BoxFit.cover, // Adjust the fit as needed
                  ),
                  borderRadius: BorderRadius.circular(
                      AppConfig.NDBorderRadius), // Match card's border radius
                  border: Border.all(
                      color: AppConfig.NDBorderColor,
                      width: AppConfig.NDBorderWidth),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.NDCardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildText('${data['contName1'] ?? 'Contact 1'}:',
                          data['num1'] ?? 'N/A'),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('${data['contName2'] ?? 'Contact 2'}:',
                          data['num2'] ?? 'N/A'),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('${data['contName3'] ?? 'Contact 3'}:',
                          data['num3'] ?? 'N/A'),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('${data['contName4'] ?? 'Contact 4'}:',
                          data['num4'] ?? 'N/A'),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('${data['contName5'] ?? 'Contact 5'}:',
                          data['num5'] ?? 'N/A'),
                      Divider(color: AppConfig.NDDivider),
                      _buildText('${data['contName6'] ?? 'Contact 6'}:',
                          data['num6'] ?? 'N/A'),
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

  Widget _buildFixedText() {
    return Container(
      padding: EdgeInsets.all(AppConfig.textBoxPadding), // Add padding
      decoration: BoxDecoration(
        color: Colors.white, // Set background color to white
        borderRadius: BorderRadius.circular(
            AppConfig.textBoxBorderRadius), // Add border radius
        // border: Border.all(color: AppConfig.tableBorderColor), // Add border color
        boxShadow: [AppConfig.fixedTextBoxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText2('Node:', widget.nodeName),
          const SizedBox(height: AppConfig.NDlineSpacing),
          _buildText2('NW Engineer:', widget.name),
          const SizedBox(height: AppConfig.NDlineSpacing),
          _buildText2('Alarm Type:', widget.alarmType),
          const SizedBox(height: AppConfig.NDlineSpacing),
          _buildText2('Province:', widget.province),
          const SizedBox(height: AppConfig.NDlineSpacing),
          _buildTextIssue('Fault Time:',
              _data.isNotEmpty ? (_data['issues2'] ?? 'N/A') : 'Loading...'),
        ],
      ),
    );
  }

  Widget _buildText(String label, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align right the values 1
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0056A2)),
                textAlign: TextAlign.right, // Align right the values 2
                overflow: TextOverflow.ellipsis,
                maxLines: 80, // Adjust the number of lines as needed
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextIssue(String label, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 0.039 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(width: AppConfig.SizedBoxWidth),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 0.039 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.w500,
                    color: Colors.red),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextIssue2(String label, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align right the values 1
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 0.039 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 0.039 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.w500,
                    color: Colors.red),
                textAlign: TextAlign.right, // Align right the values 2
                overflow: TextOverflow.ellipsis,
                maxLines: 80,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildText2(String label, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(width: AppConfig.SizedBoxWidth),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0056A2)),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons(List<double> coordinates) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                  MaterialStateProperty.all<Color>(Colors.grey[800]!),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            child: Text(satelliteButtonText,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 0.039 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              _goToElementLocation(coordinates);
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey[800]!),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            child: Text('Element',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 0.039 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

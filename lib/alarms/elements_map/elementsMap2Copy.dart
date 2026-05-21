import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:location/location.dart';
import 'dart:async';
import 'dart:typed_data';

class elementsMapPage2 extends StatefulWidget {
  final String name;

  const elementsMapPage2({Key? key, required this.name}) : super(key: key);

  @override
  _elementsMapPage2State createState() => _elementsMapPage2State();
}

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
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
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
// final BitmapDescriptor customMarkerIcon = BitmapDescriptor.fromAsset(
//   'assets/location.png', // Replace 'custom_marker_icon.png' with your image asset path
// );

class _elementsMapPage2State extends State<elementsMapPage2> {
  late GoogleMapController _controller;
  late MapType _currentMapType;
  Location location = Location();

  late BitmapDescriptor customMarkerIcon =
      BitmapDescriptor.defaultMarker; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    _currentMapType = MapType.normal;
    _loadMarkerIcon();
  }

  Future<void> _loadMarkerIcon() async {
    const String iconText =
        'M'; // Change this to the letter you want to display
    final Uint8List markerIconBytes = await _getMarkerIcon(
        iconText,
        Colors.white,
        const Color(0xFF00305e)); // You can customize the color here
    customMarkerIcon = BitmapDescriptor.fromBytes(markerIconBytes);
    // Update the marker icon once it's loaded
    setState(() {}); // This triggers a rebuild to reflect the changes
  }

  Future<Uint8List> _getMarkerIcon(
      String iconText, Color iconColor, Color bgColor) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Draw background circle
    const double radius = 11; // Adjust the radius as needed
    final Paint bgPaint = Paint()..color = bgColor;
    const Offset circleCenter = Offset(radius, radius);
    canvas.drawCircle(circleCenter, radius, bgPaint);

    // Draw letter
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: iconText,
        style: TextStyle(
            fontSize: 20,
            color: iconColor), // You can customize the font size and color here
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final Offset textOffset = Offset(
      circleCenter.dx - textPainter.width / 2, // Center horizontally
      circleCenter.dy - textPainter.height / 2, // Center vertically
    );
    textPainter.paint(canvas, textOffset);

    final img = await pictureRecorder
        .endRecording()
        .toImage(100, 100); // You can adjust the size of the marker icon here
    final ByteData? byteData =
        await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchElementDetails(widget.name),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>>? snapshot) {
        if (snapshot == null) {
          // Handle the case where snapshot is null
          return Container(); // Return a default widget or an empty container
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Elements Map',
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
            // Data available state
            List<Map<String, dynamic>> locations = snapshot.data ?? [];
            Set<Marker> markers = {};

            // Add markers for each location
            for (int i = 0; i < locations.length; i++) {
              Map<String, dynamic> location = locations[i];
              List<double> coordinates = location['coordinates'];
              markers.add(
                Marker(
                  markerId: MarkerId('marker_$i'),
                  position: LatLng(coordinates[1], coordinates[0]),
                  icon: customMarkerIcon,
                  onTap: () {
                    // Show custom info window when marker is tapped
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          height: 350,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            // Ensure scrollability
                            child: CustomInfoWidget(
                              title: location['eleName'] ?? '',
                              // Ensure eleName is not null or empty
                              fields: location,
                              lineSpacing: 8.0,
                              // Adjust line spacing as needed
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
                        );
                      },
                    );
                  },
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Elements Map',
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
                    _buildButtons(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(locations[0]['coordinates'][1],
                              locations[0]['coordinates'][0]),
                          zoom: 10,
                        ),
                        onMapCreated: (controller) => _controller = controller,
                        mapType: _currentMapType,
                        markers: markers,
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

  Widget _buildButtons() {
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
                    ? MapType.satellite
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
        // Expanded(
        //   flex: 1,
        //   child: ElevatedButton(
        //     onPressed: () {
        //       _goToElementLocation();
        //     },
        //     style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
        //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        //         RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(5.0),
        //         ),
        //       ),
        //     ),
        //     child: const Text('Element', style: TextStyle(color: Color(0xFF00305e), fontSize: 16, fontWeight: FontWeight.w700)),
        //   ),
        // ),
      ],
    );
  }

  // Future<Map<String, dynamic>> fetchElementDetails(String name) async {
  //   const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
  //   final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
  // <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  //   <soap:Body>
  //     <get_ALL_MSAN_Locations_3 xmlns="http://tempuri.org/">
  //       <nweng>$name</nweng>
  //     </get_ALL_MSAN_Locations_3>
  //   </soap:Body>
  // </soap:Envelope>''';
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {
  //       'Content-Type': 'text/xml; charset=utf-8',
  //       'SOAPAction': 'http://tempuri.org/get_ALL_MSAN_Locations_3',
  //     },
  //     body: soapXML,
  //   );
  //
  //   if (response.statusCode == 200) {
  //     String soapResponse = response.body;
  //     RegExp regex = RegExp(r'<get_ALL_MSAN_Locations_3Result>(.*?)<\/get_ALL_MSAN_Locations_3Result>');
  //     String result = regex.firstMatch(soapResponse)?.group(1) ?? '';
  //     List<String> fields = result.split('::');
  //     double longitude = double.parse(fields[1]);
  //     double latitude = double.parse(fields[2]);
  //     String eleName = fields[0];
  //     String nwEngName = fields[3];
  //     String site = fields[5];
  //     String num1 = fields[6];
  //     String num2 = fields[7];
  //     String num3 = fields[8];
  //     String num4 = fields[9];
  //     String num5 = fields[17];
  //     String num6 = fields[19];
  //     String vendor = fields[10];
  //     String contName1 = fields[11];
  //     String contName2 = fields[12];
  //     String contName3 = fields[13];
  //     String contName4 = fields[14];
  //     String contName5 = fields[16];
  //     String contName6 = fields[18];
  //     String issues = fields[15];
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
  //       'num5': num5,
  //       'num6': num6,
  //       'vendor': vendor,
  //       'contName1': contName1,
  //       'contName2': contName2,
  //       'contName3': contName3,
  //       'contName4': contName4,
  //       'contName5': contName5,
  //       'contName6': contName6,
  //       'issues': issues
  //     };
  //   } else {
  //     throw Exception('Failed to fetch element details');
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchElementDetails(String name) async {
    const String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <get_ALL_MSAN_Locations_3 xmlns="http://tempuri.org/">
          <nweng>$name</nweng>
        </get_ALL_MSAN_Locations_3>
      </soap:Body>
    </soap:Envelope>''';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/get_ALL_MSAN_Locations_3',
      },
      body: soapXML,
    );

    if (response.statusCode == 200) {
      String soapResponse = response.body;
      RegExp regex = RegExp(
          r'<get_ALL_MSAN_Locations_3Result>(.*?)<\/get_ALL_MSAN_Locations_3Result>');
      String result = regex.firstMatch(soapResponse)?.group(1) ?? '';

      List<Map<String, dynamic>> locations = [];

      // Split the result by commas to get individual locations
      List<String> locationStrings = result.split(',');

      // Process each location separately
      for (String locationString in locationStrings) {
        List<String> fields = locationString.split('::');
        if (fields.length >= 24) {
          // Ensure all required fields are present
          double longitude = double.parse(fields[1]);
          double latitude = double.parse(fields[2]);
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

          // Add location data to the list
          locations.add({
            'coordinates': [longitude, latitude],
            'eleName': eleName,
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
          });
        }
      }

      return locations;
    } else {
      throw Exception('Failed to fetch element details');
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

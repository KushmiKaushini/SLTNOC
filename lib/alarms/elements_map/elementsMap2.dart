import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:location/location.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

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
                  size: 2, // Adjust the icon size as needed
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

class _elementsMapPage2State extends State<elementsMapPage2> {
  late GoogleMapController _controller;
  late MapType _currentMapType;
  Location location = Location();
  bool _isLoading = true;
  List<Map<String, dynamic>> _locations = [];
  BitmapDescriptor? _nodeDownIcon;
  BitmapDescriptor? _alarmOtherIcon;
  BitmapDescriptor? _alarmNoneIcon;

  @override
  void initState() {
    super.initState();
    _currentMapType = MapType.normal;
    _loadMarkerIcons();
    _fetchElementDetails();
  }

  Future<void> _loadMarkerIcons() async {
    _nodeDownIcon = await _buildMarkerIcon(Colors.red.shade700, 'M');
    _alarmOtherIcon = await _buildMarkerIcon(Colors.yellow.shade700, 'M');
    _alarmNoneIcon = await _buildMarkerIcon(Colors.green.shade600, 'M');
    if (mounted) {
      setState(() {});
    }
  }

  Future<BitmapDescriptor> _buildMarkerIcon(Color color, String label) async {
    const double size = 30;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);
    final Paint fillPaint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final double radius = size / 2;
    final Offset center = Offset(radius, radius);

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);

    final double fontSize = size * 0.5;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final Offset textOffset = Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, textOffset);

    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  String _alarmStatusFromIssues(String issues) {
    final String trimmed = issues.trim();
    if (trimmed.isEmpty) {
      return 'none';
    }
    final String value = trimmed.toLowerCase();
    if (value == '0' ||
        value == 'none' ||
        value.contains('no alarm') ||
        value.contains('no alarms')) {
      return 'none';
    }
    if (value.contains('node down')) {
      return 'down';
    }
    return 'other';
  }

  BitmapDescriptor _iconForIssues(String issues) {
    switch (_alarmStatusFromIssues(issues)) {
      case 'down':
        return _nodeDownIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'none':
        return _alarmNoneIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return _alarmOtherIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Elements Map',
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig
                .bodyBackgroundImagePath), // Replace 'background_image.jpg' with your image path
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
        ),
        child: _isLoading ? CustomLoadingIndicator() : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFixedText(),
          const SizedBox(height: 8),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: 10), // Adjust margins as needed
            child: _buildButtons(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  initialCameraPosition: _locations.isNotEmpty
                      ? CameraPosition(
                          target: LatLng(
                            _locations[0]['coordinates'][1],
                            _locations[0]['coordinates'][0],
                          ),
                          zoom: 10,
                        )
                      : CameraPosition(
                          target: LatLng(0, 0),
                          zoom: 10,
                        ),
                  onMapCreated: (controller) => _controller = controller,
                  trafficEnabled: true,
                  mapType: _currentMapType,
                  markers: _buildMarkers(),
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

  Set<Marker> _buildMarkers() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Set<Marker> markers = {};
    for (int i = 0; i < _locations.length; i++) {
      Map<String, dynamic> location = _locations[i];
      List<double> coordinates = location['coordinates'];
      final String issues = (location['issues'] ?? '').toString();
      markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: LatLng(coordinates[1], coordinates[0]),
          icon: _iconForIssues(issues),
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 300,
                    width: (MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? screenWidth
                        : screenHeight),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: SingleChildScrollView(
                        child: CustomInfoWidget(
                          title: location['eleName'] ?? '',
                          fields: location,
                          lineSpacing: 8.0,
                          labelStyle: TextStyle(
                              fontSize: 0.037 *
                                  (MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? screenWidth
                                      : screenHeight),
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          valueStyle: TextStyle(
                              fontSize: 0.037 *
                                  (MediaQuery.of(context).orientation ==
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
      );
    }
    return markers;
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
          _buildText('NW Engineer:', widget.name),
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
            Flexible(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 0.037 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0056A2)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 8),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons() {
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
                  WidgetStateProperty.all<Color>(Colors.grey[800]!),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            child: Text(
              satelliteButtonText,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 0.037 *
                      (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth
                          : screenHeight),
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchElementDetails() async {
    try {
      List<Map<String, dynamic>> locations =
          await fetchElementDetails(widget.name);
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
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
}

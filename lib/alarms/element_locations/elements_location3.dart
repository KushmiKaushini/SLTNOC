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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Element Details',
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
        child: _isLoading
            ? CustomLoadingIndicator()
            : _hasCoordinates
                ? _buildMap()
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

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
                    zoom: 16,
                  ),
                  onMapCreated: (controller) => _controller = controller,
                  trafficEnabled: true,
                  mapType: _currentMapType,
                  markers: {
                    Marker(
                      markerId: const MarkerId('marker_1'),
                      position: LatLng(_coordinates[0], _coordinates[1]),
                      infoWindow: const InfoWindow(
                        // Set to an empty InfoWindow to disable default behavior
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
                                      title: _data['eleName'] ?? '',
                                      // Using _data instead of data
                                      fields: _data,
                                      // Passing _data to CustomInfoWidget
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
          const SizedBox(height: 3),
          _buildText('Element:', widget.elementName),
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
                  WidgetStateProperty.all<Color>(Colors.grey[800]!),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            child: Text(satelliteButtonText,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 0.037 *
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
                  WidgetStateProperty.all<Color>(Colors.grey[800]!),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            child: Text('Element',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 0.037 *
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

  Future<void> _fetchData() async {
    try {
      // Fetch coordinates
      await _fetchCoordinates();
      // Fetch relevant details
      final data = await fetchRelevantDetails();
      setState(() {
        _data = data; // Initialize _data with fetched details
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> _fetchCoordinates() async {
    try {
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

  void _goToElementLocation(List<double> coordinates) {
    _controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(coordinates[0], coordinates[1]),
      16,
    ));
  }
}

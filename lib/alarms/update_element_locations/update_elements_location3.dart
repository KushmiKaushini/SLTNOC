import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:location/location.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class UpdateElementsLocationPage3 extends StatefulWidget {
  final String name;
  final String elementName;

  const UpdateElementsLocationPage3(
      {Key? key, required this.name, required this.elementName})
      : super(key: key);

  @override
  _UpdateElementsLocationPage3State createState() =>
      _UpdateElementsLocationPage3State();
}

class _UpdateElementsLocationPage3State
    extends State<UpdateElementsLocationPage3> {
  late GoogleMapController _controller;
  late MapType _currentMapType;
  Location location = Location();
  bool _isLoading = true;
  bool _hasCoordinates = false;
  List<double> _coordinates = [0.0, 0.0]; // Default coordinates
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _currentMapType = MapType.normal;
    _fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Location',
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig.bodyBackgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? CustomLoadingIndicator()
            : _hasCoordinates
                ? _buildMap()
                : const Center(child: Text('Failed to fetch location')),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFixedText(),
          const SizedBox(height: 8),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: _buildButtons(),
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
                  onTap: _handleTap,
                  mapType: _currentMapType,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markers,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _handleTap(LatLng tappedPoint) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('selectedLocation'),
          position: tappedPoint,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet:
                'Lat: ${tappedPoint.latitude}, Lng: ${tappedPoint.longitude}',
          ),
        ),
      );
      _coordinates = [tappedPoint.latitude, tappedPoint.longitude];
    });
  }

  Widget _buildFixedText() {
    return Container(
      padding: EdgeInsets.all(AppConfig.textBoxPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.textBoxBorderRadius),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 0.037 *
                    (MediaQuery.of(context).orientation == Orientation.portrait
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
              // Additional functionality to set location can be added here
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
            child: Text('Set Location',
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

  Future<void> _fetchLocation() async {
    try {
      LocationData userLocation = await location.getLocation();
      setState(() {
        _hasCoordinates = true;
        _coordinates = [
          userLocation.latitude ?? 0.0,
          userLocation.longitude ?? 0.0
        ];
        markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: LatLng(_coordinates[0], _coordinates[1]),
            infoWindow: InfoWindow(title: 'Your Location'),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching location: $e');
    }
  }
}

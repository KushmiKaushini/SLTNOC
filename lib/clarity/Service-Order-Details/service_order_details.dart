import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class ServiceOrderDetailsPage extends StatefulWidget {
  const ServiceOrderDetailsPage({Key? key}) : super(key: key);

  @override
  _ServiceOrderDetailsPageState createState() =>
      _ServiceOrderDetailsPageState();
}

class _ServiceOrderDetailsPageState extends State<ServiceOrderDetailsPage> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> soapData = [];
  TextEditingController _circuitIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = Future.value(); // Initialize to empty future
  }

  Future<void> fetchSoapData(String circuitId) async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <getcctdetails xmlns="http://tempuri.org/">
              <cctname>$circuitId</cctname>
            </getcctdetails>
          </soap:Body>
        </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/getcctdetails',
        },
        body: soapBody,
      );

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("getcctdetailsResult").first;
        var resultString = resultNode.text.trim();
        print('SOAP Response: $resultString');

        setState(() {
          if (resultString == 'Not Found') {
            soapData.clear(); // Clear previous data
          } else {
            List<String> circuitDetails = resultString.split(';');
            soapData = circuitDetails.map((detail) {
              var parts = detail.split(':');
              return {
                parts[0].trim(): parts.sublist(1).join(':').trim(),
              };
            }).toList();
          }
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        // Handle error
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Order Details',
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
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConfig.bodyBackgroundImagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConfig.tablePagePadding),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40, // Adjust the height as needed
                        child: TextField(
                          controller: _circuitIdController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Type the circuit ID..',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical:
                                    8.0), // Vertical padding to center the text
                            // Left margin for the text
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        String circuitId = _circuitIdController.text.trim();
                        if (circuitId.isNotEmpty) {
                          setState(() {
                            _fetchDataFuture = fetchSoapData(circuitId);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4272D7), // BG color
                        foregroundColor: Colors.white, // Font color
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500, // Font weight
                          fontSize: 18, // Font size
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 1080
                              ? screenWidth * 0.04
                              : 30, // Adjust button width
                          vertical: 8.0, // Suitable padding
                        ),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: FutureBuilder<void>(
                    future: _fetchDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CustomLoadingIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading data: ${snapshot.error}'),
                        );
                      } else {
                        return soapData.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/NoData.png', // Replace 'no_data_found.png' with your image asset path
                                      width: 100, // Adjust the width as needed
                                      height:
                                          100, // Adjust the height as needed
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'No Data Found!!',
                                      style: TextStyle(
                                          fontSize: 0.045 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00305e)),
                                    ),
                                  ],
                                ),
                              )
                            : _buildDetails(soapData);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(List<Map<String, dynamic>> data) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // Split data into three sections
    List<Map<String, dynamic>> firstContainerData = [];
    List<Map<String, dynamic>> secondContainerData = [];
    List<Map<String, dynamic>> thirdContainerData = [];

    // Determine the split criteria
    int splitIndex1 = 1; // First container contains the first field
    int splitIndex2 = 5; // Second container contains the next four fields

    // Split the data
    if (data.length > splitIndex1) {
      firstContainerData.add(data[0]);
      if (data.length > splitIndex2) {
        secondContainerData.addAll(data.sublist(1, splitIndex2));
        thirdContainerData.addAll(data.sublist(splitIndex2));
      } else {
        secondContainerData.addAll(data.sublist(1));
      }
    } else {
      firstContainerData.addAll(data);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.tablePagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildContainer(firstContainerData),
            Text('AN',
                textAlign: AppConfig.NDTitleAlignment,
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildContainer(secondContainerData),
            Text('BN',
                textAlign: AppConfig.NDTitleAlignment,
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildContainer(thirdContainerData),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(List<Map<String, dynamic>> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig
                .cardBackgroundImagePath), // Replace 'card_bg_image.jpg' with your image path
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
          borderRadius: BorderRadius.circular(
              AppConfig.NDBorderRadius), // Match card's border radius
          border: Border.all(
              color: AppConfig.NDBorderColor, width: AppConfig.NDBorderWidth),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.NDCardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var item in data) ..._buildLabelValuePairs(item),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLabelValuePairs(Map<String, dynamic> data) {
    List<Widget> widgets = [];
    data.forEach((label, value) {
      widgets.add(_buildText(label, value));
      widgets.add(
          Divider(color: AppConfig.NDDivider)); // Add divider after each row
    });
    return widgets;
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
}

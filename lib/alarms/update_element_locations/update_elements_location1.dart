import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'update_elements_location2.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class UpdateElementsLocationPage extends StatefulWidget {
  const UpdateElementsLocationPage({Key? key}) : super(key: key);

  @override
  _UpdateElementsLocationPageState createState() =>
      _UpdateElementsLocationPageState();
}

class _UpdateElementsLocationPageState
    extends State<UpdateElementsLocationPage> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> elementlocations1 = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData(); // Fetch data when the widget initializes
  }

  Future<void> fetchData() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    const String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <fullenglist xmlns="http://tempuri.org/" />
        </soap:Body>
      </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/fullenglist',
        },
        body: soapBody,
      );

      // print('SOAP Response: ${response.body}');

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("fullenglistResult").first;
        var resultString = resultNode.text.trim();
        // print('Result String: $resultString');

        List<String> nameAndAlarmPairs = resultString.split('    :: -::-,');
        // print('Name and Alarm Pairs: $nameAndAlarmPairs');

        List<Map<String, String>> data = [];

        for (var pair in nameAndAlarmPairs) {
          List<String> parts = pair.split('::');
          if (parts.length >= 2) {
            String name = parts[0].trim();
            String alarmsValue =
                parts[1].trim(); // The value containing both parts
            // Extracting the parts of the value
            int startIndex = alarmsValue.indexOf('[');
            int endIndex = alarmsValue.indexOf(']');
            if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
              String alarmsCount = alarmsValue.substring(
                  0, startIndex); // Extracting the first part
              String additionalInfo = alarmsValue.substring(startIndex + 1,
                  endIndex); // Extracting the second part without the bracket
              data.add({
                "Name": name,
                "Open Alarms": alarmsCount,
                "Additional Info": additionalInfo
              });
            }
          }
        }
        // print('Data: $data');

        setState(() {
          elementlocations1 = data;
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Element Locations',
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
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.tablePagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // You can remove the Row widget here
              Expanded(
                child: FutureBuilder<void>(
                  future: _fetchDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display a loading indicator while waiting for the data to load
                      return CustomLoadingIndicator();
                    } else if (snapshot.hasError) {
                      // Display an error message if the data loading encountered an error
                      return Center(
                        child: Text('Error loading data: ${snapshot.error}'),
                      );
                    } else {
                      // Once data is loaded, display the DataTable
                      return styledDataTable();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget styledDataTable() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConfig.tableBorderRadius),
            border: Border.all(color: AppConfig.tableBorderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConfig.tableBorderRadius),
            child: DataTable(
              showCheckboxColumn: false,
              dataRowColor: WidgetStateColor.resolveWith(
                  (states) => AppConfig.tableRowColor),
              columnSpacing: AppConfig.columnSpacing,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => AppConfig.tableHeadingColor),
              columns: [
                DataColumn(
                  label: Text('Name',
                      style: TextStyle(
                          fontSize: 0.040 *
                              (MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? screenWidth
                                  : screenHeight),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900])),
                ),
                DataColumn(
                  label: Text('Elements',
                      style: TextStyle(
                          fontSize: 0.040 *
                              (MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? screenWidth
                                  : screenHeight),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900])),
                  numeric: true,
                ),
              ],
              rows: elementlocations1.map((count) {
                return DataRow(
                  onSelectChanged: (bool? selected) {
                    if (selected != null && selected) {
                      // Navigate to UpdateElementsLocationPage2 when the row is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateElementsLocationPage2(name: count['Name']),
                        ),
                      );
                    }
                  },
                  cells: [
                    DataCell(
                      Text(count['Name'],
                          style: TextStyle(
                              fontSize: 0.037 *
                                  (MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? screenWidth
                                      : screenHeight),
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF00305e))),
                    ),
                    DataCell(
                      Text(
                          '${count['Open Alarms']}[${count['Additional Info']}]',
                          textAlign: AppConfig.secondColumnDataAlignment,
                          style: TextStyle(
                              fontSize: 0.037 *
                                  (MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? screenWidth
                                      : screenHeight),
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF00305e))),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

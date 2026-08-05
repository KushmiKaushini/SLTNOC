import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'update_elements_location3.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class UpdateElementsLocationPage2 extends StatefulWidget {
  final String name; // Add the 'name' parameter

  const UpdateElementsLocationPage2({Key? key, required this.name})
      : super(key: key);

  @override
  _UpdateElementsLocationPage2State createState() =>
      _UpdateElementsLocationPage2State();
}

class _UpdateElementsLocationPage2State
    extends State<UpdateElementsLocationPage2> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> elementlocations2 = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData(); // Fetch data when the widget initializes
  }

  Future<void> fetchData() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <MSAN_under_eng xmlns="http://tempuri.org/">
          <nweng>${widget.name}</nweng>
        </MSAN_under_eng>
      </soap:Body>
    </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/MSAN_under_eng',
        },
        body: soapBody,
      );

      // print('SOAP Response: ${response.body}');

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("MSAN_under_engResult").first;
        var resultString = resultNode.text.trim();
        // print('Result String: $resultString');

        List<String> elements = resultString.split(',');
        List<Map<String, dynamic>> data = [];

        for (var element in elements) {
          List<String> parts = element.split('::');
          if (parts.length == 4) {
            String elementName = parts[0].trim();
            String geoLocations = parts[1].trim();
            String site = parts[2].trim();
            String additionalValue = parts[3].trim();
            data.add({
              "Element Name": elementName,
              "Geo Locations": geoLocations,
              "Site": site,
              "Additional Value": additionalValue,
            });
          }
        }

        // print('Data: $data');

        setState(() {
          elementlocations2 = data;
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
              // Display province information
              Container(
                padding: EdgeInsets.all(AppConfig.textBoxPadding),
                decoration: BoxDecoration(
                  color: AppConfig.bgColor1,
                  borderRadius:
                      BorderRadius.circular(AppConfig.textBoxBorderRadius),
                  boxShadow: [AppConfig.fixedTextBoxShadow],
                ),
                child: _buildText('NW Engineer:', widget.name),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.tablePagePadding),
                  child: FutureBuilder<void>(
                    future: _fetchDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CustomLoadingIndicator();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading data: ${snapshot.error}'),
                        );
                      } else {
                        return styledDataTable();
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
              dataRowColor: MaterialStateColor.resolveWith(
                  (states) => AppConfig.tableRowColor),
              columnSpacing: AppConfig.columnSpacing,
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => AppConfig.tableHeadingColor),
              columns: [
                DataColumn(
                  label: Text('Element Name',
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
                  label: Text('Location',
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
              rows: elementlocations2.map((count) {
                return DataRow(
                  onSelectChanged: (bool? selected) {
                    if (selected != null && selected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateElementsLocationPage3(
                              name: widget.name,
                              elementName: count['Element Name']),
                        ),
                      );
                    }
                  },
                  cells: [
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 200, // Set a maximum width for the cell
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            count['Element Name'],
                            style: TextStyle(
                                fontSize: 0.037 *
                                    (MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? screenWidth
                                        : screenHeight),
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF00305e)),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 50, // Set a maximum width for the cell
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            count['Geo Locations'],
                            style: TextStyle(
                              fontSize: 0.037 *
                                  (MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? screenWidth
                                      : screenHeight),
                              fontWeight: FontWeight.w500,
                              color: count['Geo Locations'] == '***'
                                  ? Colors.red
                                  : const Color(0xFF00305e),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildText(String label, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 0.037 *
                  (MediaQuery.of(context).orientation == Orientation.portrait
                      ? screenWidth
                      : screenHeight),
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        const SizedBox(width: AppConfig.SizedBoxWidth),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 0.037 *
                    (MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenWidth
                        : screenHeight),
                fontWeight: FontWeight.w500,
                color: Color(0xFF0056A2)),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

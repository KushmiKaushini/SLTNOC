import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class ClarityNwFaultsPage extends StatefulWidget {
  final String title;

  const ClarityNwFaultsPage({Key? key, required this.title}) : super(key: key);

  @override
  _ClarityNwFaultsPageState createState() => _ClarityNwFaultsPageState();
}

class _ClarityNwFaultsPageState extends State<ClarityNwFaultsPage> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> clarityNwFaults = [];
  String dropdownValue1 = 'Select an application';
  String dropdownValue2 = 'All';
  List<String> dropdownOptions1 = [];
  bool isLoadingOptions = true;
  bool _dataFetched =
      false; // Add this variable to track whether data has been fetched successfully

  @override
  void initState() {
    super.initState();
    _fetchDropdownOptions().then((_) {
      _fetchDataFuture = fetchData(dropdownValue1, dropdownValue2);
    });
  }

  Future<void> _fetchDropdownOptions() async {
    setState(() {
      isLoadingOptions = true;
    });
    final options = await fetchDropdownOptions();
    if (options.isNotEmpty) {
      setState(() {
        dropdownOptions1 = options;
        dropdownValue1 = options.first;
        isLoadingOptions = false;
      });
    } else {
      setState(() {
        isLoadingOptions = false;
      });
    }
  }

  Future<void> fetchData(String dropdownValue1, String dropdownValue2) async {
    clarityNwFaults.clear();

    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/getSelection3',
        },
        body: _buildSoapBody(dropdownValue1, dropdownValue2),
      );
      if (response.statusCode == 200) {
        final soapResponse = xml.XmlDocument.parse(response.body);
        final results = soapResponse.findAllElements('getSelection3Result');

        for (var result in results) {
          final data = result.text.trim();
          final records = data.split(',');

          for (var record in records) {
            final elements = record.split('::');

            Map<String, dynamic> recordMap = {
              'Clarity Ref No': elements[0].trim(),
              'Customer Type': elements[1].trim(),
              'Customer Name': elements[2].trim(),
              'Circuit Name': elements[3].trim(),
              'Circuit Type': elements[4].trim(),
              'Reported Time': elements[5].trim(),
              'Hours': elements[6].trim(),
              'SLA': elements[7].trim(),
              'Status': elements[8].trim(),
              'Enter By': elements[9].trim(),
              'Access Medium': elements[10].trim(),
              'WO Count': elements[11].trim(),
            };

            clarityNwFaults.add(recordMap);
          }
        }

        // Set _dataFetched to true after successfully fetching data
        setState(() {
          _dataFetched = true;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  String _buildSoapBody(String dropdownValue1, String dropdownValue2) {
    // Check if dropdownValue1 is 'CORPORATE-LARGE & VERY LARGE'
    final cusType = dropdownValue1 == 'CORPORATE-LARGE & VERY LARGE'
        ? 'CORPORATE-LARGE &amp; VERY LARGE'
        : dropdownValue1;

    return '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <getSelection3 xmlns="http://tempuri.org/">
          <cus_type>$cusType</cus_type>
          <work_group>$dropdownValue2</work_group>
        </getSelection3>
      </soap:Body>
    </soap:Envelope>''';
  }

  Future<List<String>> fetchDropdownOptions() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';

    try {
      // Make the HTTP POST request
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/cus_types',
        },
        body: _buildSoapBodyForDropdown(),
      );
      if (response.statusCode == 200) {
        final soapResponse = xml.XmlDocument.parse(response.body);
        final result =
            soapResponse.findAllElements('cus_typesResult').first.text;

        // Split the options by comma and trim each option
        final options =
            result.split(',').map((option) => option.trim()).toList();
        print(options);

        return options;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return []; // Return empty list on failure
      }
    } catch (error) {
      print('Error fetching dropdown options: $error');
      return []; // Return empty list on error
    }
  }

  String _buildSoapBodyForDropdown() {
    return '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <cus_types xmlns="http://tempuri.org/" />
          </soap:Body>
        </soap:Envelope>''';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
              fontSize: 0.045 *
                  (MediaQuery.of(context).orientation == Orientation.portrait
                      ? screenWidth
                      : screenHeight),
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppConfig.appBarBG,
        toolbarHeight: 0.13 *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? screenWidth
                : screenHeight),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [SettingsButton()],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig.bodyBackgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.tablePagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDropdown1(screenWidth),
              const SizedBox(height: 8),
              buildDropdown2(screenWidth),
              const SizedBox(height: 8),
              buildResultsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdown1(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue1,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey[600]),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.blueGrey[900], fontSize: 16),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                dropdownValue1 = newValue;
                _fetchDataFuture = fetchData(dropdownValue1, dropdownValue2);
              });
            }
          },
          items: dropdownOptions1.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildDropdown2(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue2,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey[600]),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.blueGrey[900], fontSize: 16),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                dropdownValue2 = newValue;
                _fetchDataFuture = fetchData(dropdownValue1, dropdownValue2);
              });
            }
          },
          items: <String>['All', 'CEN-CSC-NW', 'CEN-CSC-DATA', 'CEN-CSC-CC']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget buildSearchButton(double screenWidth) {
  //   return SizedBox(
  //     width: screenWidth,
  //     child: ElevatedButton(
  //       onPressed: () {
  //         setState(() {
  //           _fetchDataFuture = fetchData(dropdownValue1, dropdownValue2);
  //         });
  //       },
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: const Color(0xFF4272D7),
  //         foregroundColor: Colors.white,
  //         textStyle: TextStyle(
  //           fontWeight: FontWeight.w500,
  //           fontSize: 18,
  //         ),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         padding: EdgeInsets.symmetric(
  //           horizontal: screenWidth < 1080 ? screenWidth * 0.04 : 30,
  //           vertical: 8.0,
  //         ),
  //       ),
  //       child: const Text('Search'),
  //     ),
  //   );
  // }

  Widget buildResultsWidget() {
    return Expanded(
        child: _dataFetched ? styledDataTable() : CustomLoadingIndicator());
  }

  Widget styledDataTable() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: AppConfig.tableBorderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: DataTable(
              dataRowColor: MaterialStateColor.resolveWith(
                  (states) => AppConfig.tableRowColor),
              columnSpacing: 16.0,
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => AppConfig.tableHeadingColor),
              // dataRowHeight: 130, // Set the minimum height for the DataRow
              dataRowMaxHeight: double.infinity,
              columns: [
                DataColumn(
                  label: Text('Clarity NW Faults',
                      style: TextStyle(
                          fontSize: 0.040 *
                              (MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? screenWidth
                                  : screenHeight),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900])),
                ),
              ],
              rows: clarityNwFaults.map((index) {
                return DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0), // Add top and bottom margin
                        child: Container(
                          alignment: Alignment.centerLeft, // Align text left
                          // height: 150, // Increase the height to accommodate the description
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDataRowText(
                                  'Clarity Ref No:', index['Clarity Ref No']),
                              _buildDataRowText(
                                  'Customer Type:', index['Customer Type']),
                              _buildDataRowText(
                                  'Customer Name:', index['Customer Name']),
                              _buildDataRowText(
                                  'Circuit Name:', index['Circuit Name']),
                              _buildDataRowText(
                                  'Circuit Type:', index['Circuit Type']),
                              _buildDataRowText(
                                  'Reported Time:', index['Reported Time']),
                              _buildDataRowText('Hours:', index['Hours']),
                              _buildDataRowText('SLA:', index['SLA']),
                              _buildDataRowText('Status:', index['Status']),
                              _buildDataRowText('Enter By:', index['Enter By']),
                              _buildDataRowText(
                                  'Access Medium:', index['Access Medium']),
                              _buildDataRowText('WO Count:', index['WO Count']),
                            ],
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

  Widget _buildDataRowText(String label, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          children: [
            TextSpan(
                text: '$label ',
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    color: const Color(0xFF00305e),
                    fontWeight: FontWeight.bold)),
            TextSpan(
                text: value,
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

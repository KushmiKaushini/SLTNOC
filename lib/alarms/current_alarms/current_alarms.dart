// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:sltnoc/settings_button.dart';
//
// import 'current_alarms_expanded1.dart'; // Import the new page
//
// class CurrentAlarmsPage extends StatefulWidget {
//   final String province; // Define province as a parameter
//
//   const CurrentAlarmsPage({Key? key, required this.province}) : super(key: key);
//
//   @override
//   _CurrentAlarmsPageState createState() => _CurrentAlarmsPageState();
// }
//
// class _CurrentAlarmsPageState extends State<CurrentAlarmsPage> {
//   List<Map<String, dynamic>> alarms = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData(widget.province);
//     // fetchData('Central Province South'); // Default province
//   }
//
//   Future<void> fetchData(String province) async {
//     final response = await http.get(Uri.parse('http://192.168.1.11:3000/api/alarms1/data/${widget.province}'));
//
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       setState(() {
//         alarms = List<Map<String, dynamic>>.from(jsonData);
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Current Alarms', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
//             // Display province information
//             Row(
//               children: [
//                 const Text(
//                   'Province: ',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//                 ),
//                 Text(
//                   widget.province,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2)), // Adjust color as needed
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16), // Add some vertical spacing
//             SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: styledDataTable(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget styledDataTable() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(5.0),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(5.0),
//         child: DataTable(
//           columnSpacing: 16.0,
//           headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
//           columns: const [
//             DataColumn(
//               label: Text('Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//             ),
//             DataColumn(
//               label: Text('Open Alarms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//               numeric: true,
//             ),
//           ],
//           rows: alarms.map((alarm) {
//             Color openAlarmColor = int.parse(alarm['OpenAlarms'].toString()) > 500 ? Colors.red : const Color(0xFF00305e);
//
//             return DataRow(
//               cells: [
//                 DataCell(
//                   InkWell(
//                     onTap: () {
//                       // Navigate to the new page when the row is tapped
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => CurrentAlarmsExpandedPage1(name: alarm['NW_ENG'].toString(), province: widget.province), // Pass province
//                         ),
//                       );
//                     },
//                     child: Text(alarm['NW_ENG'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF00305e))),
//                   ),
//                 ),
//                 DataCell(
//                   InkWell(
//                     onTap: () {
//                       // Navigate to the new page when the row is tapped
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => CurrentAlarmsExpandedPage1(name: alarm['NW_ENG'].toString(), province: widget.province), // Pass province
//                         ),
//                       );
//                     },
//                     child: Text(alarm['OpenAlarms'].toString(),
//                         textAlign: TextAlign.right,
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: openAlarmColor)),
//                   ),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'current_alarms_expanded1.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';
import 'dart:convert';
import 'package:sltnoc/secure_storage_service.dart';

class CurrentAlarmsPage extends StatefulWidget {
  final String province;

  const CurrentAlarmsPage({Key? key, required this.province}) : super(key: key);

  @override
  _CurrentAlarmsPageState createState() => _CurrentAlarmsPageState();
}

class _CurrentAlarmsPageState extends State<CurrentAlarmsPage> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> alarms = [];
  Map<String, String> names = {};
  Map<String, dynamic> mapC = {};
  late List<Map<String, dynamic>> mapCList; // Define mapCList here

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData(); // Fetch data when the widget initializes
  }

  Future<void> fetchData() async {
    try {
      final storage = SecureStorageService();
      final useLocalServer = await storage.getUseLocalServer();
      final serverUrl =
          await storage.getServerUrl() ?? 'http://192.168.1.14:3000';

      if (useLocalServer) {
        final response = await http.get(
          Uri.parse('$serverUrl/api/alarms1/data/${widget.province}'),
          headers: {'X-API-Key': AppConfig.apiKey},
        );
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          List<Map<String, dynamic>> data = [];
          for (var item in jsonData) {
            data.add({
              "Name": (item['NW_ENG'] ?? '').toString(),
              "Open Alarms": (item['OpenAlarms'] ?? 0).toString(),
            });
          }
          setState(() {
            mapCList = data;
          });
          return;
        }
      }
    } catch (e) {
      print('Local fetch alarms failed, trying SOAP: $e');
    }

    // SOAP fallback
    await fetchAlarms(); // Call the method to fetch alarms from the first web service
    if (widget.province.toUpperCase() != "ALL") {
      // If province is not equal to "ALL", call the second web service
      await fetchNames(widget
          .province); // Call the method to fetch names from the second web service
    }
    createMapC();
  }

  Future<void> fetchAlarms() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    const String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <englist3 xmlns="http://tempuri.org/" />
        </soap:Body>
      </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/englist3',
        },
        body: soapBody,
      );

      print('SOAP Response: ${response.body}');

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("englist3Result").first;
        var resultString = resultNode.text.trim();
        print('Result String: $resultString');

        List<String> nameAndAlarmPairs = resultString.split(',');
        print('Name and Alarm Pairs: $nameAndAlarmPairs');

        List<Map<String, String>> data = [];

        for (var pair in nameAndAlarmPairs) {
          List<String> parts = pair.split('::');
          if (parts.length >= 2) {
            String name = parts[0].trim();
            String alarmsCount = parts[1].trim().split(' ')[0];
            data.add({"Name": name, "Open Alarms": alarmsCount});
          }
        }
        print(data);

        setState(() {
          alarms = data;
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchNames(String province) async {
    final soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final soapBody = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <get_nweng xmlns="http://tempuri.org/">
            <province>$province</province>
          </get_nweng>
        </soap:Body>
      </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/get_nweng',
        },
        body: soapBody,
      );

      print('SOAP Response (Names): ${response.body}');

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("name");

        for (var nameNode in resultNode) {
          String name = nameNode.text.trim();
          names[name] = ''; // Store the name in Map B
        }
        print('Names Map: $names');

        print('Names stored in Map B: $names');
      } else {
        print('Failed to fetch names: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching names: $error');
    }
  }

  void createMapC() {
    if (widget.province.toUpperCase() == "ALL") {
      mapCList = alarms;
      print('Map C (ALL): $mapCList');
    } else {
      // Iterate over names in Map B
      for (String name in names.keys) {
        // Check if the name exists in Map A
        if (alarms.any((alarm) => alarm['Name'] == name)) {
          // If the name exists in Map A, find the corresponding data pair
          Map<String, dynamic> relevantData =
              alarms.firstWhere((alarm) => alarm['Name'] == name);
          // Store the relevant data pair in Map C
          mapC[name] = relevantData;
        }
      }
      mapCList = mapC.values
          .toList()
          .cast<Map<String, dynamic>>(); // Assign values to mapCList
      print('Map C: $mapCList');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Alarms',
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
                child: _buildText('Province:', widget.province),
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
    if (mapCList.isEmpty) {
      // Display an image and text if no data is found
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/NoData.png', // Replace 'no_data_found.png' with your image asset path
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
            ),
            const SizedBox(height: 10),
            Text(
              'No Alarms Found!!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00305e)),
            ),
          ],
        ),
      );
    } else {
      // If mapCList is not empty, display the DataTable
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
                    label: Text('Open Alarms',
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
                rows: mapCList.map((data) {
                  Color openAlarmColor =
                      int.parse(data['Open Alarms'] ?? '0') > 500
                          ? Colors.red
                          : const Color(0xFF00305e);
                  return DataRow(
                    onSelectChanged: (bool? selected) {
                      if (selected != null && selected) {
                        // Navigate to the new page when the row is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CurrentAlarmsExpandedPage1(
                                name: data['Name'],
                                province: widget.province), // Pass province
                          ),
                        );
                      }
                    },
                    cells: [
                      DataCell(
                        Text(data['Name'],
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
                        Text(data['Open Alarms'].toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 0.037 *
                                    (MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? screenWidth
                                        : screenHeight),
                                fontWeight: FontWeight.w500,
                                color: openAlarmColor)),
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
//
// class CurrentAlarmsPage extends StatefulWidget {
//   const CurrentAlarmsPage({Key? key}) : super(key: key);
//
//   @override
//   _CurrentAlarmsPageState createState() => _CurrentAlarmsPageState();
// }
//
// class _CurrentAlarmsPageState extends State<CurrentAlarmsPage> {
//   List<Map<String, String>> alarms = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     final String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
//     final String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
//   <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
//     <soap:Body>
//       <fullenglist xmlns="http://tempuri.org/" />
//     </soap:Body>
//   </soap:Envelope>''';
//
//     try {
//       final response = await http.post(
//         Uri.parse(soapEndpoint),
//         headers: {
//           'Content-Type': 'text/xml; charset=utf-8',
//           'SOAPAction': 'http://tempuri.org/fullenglist',
//         },
//         body: soapBody,
//       );
//
//       print('SOAP Response: ${response.body}');
//
//       if (response.statusCode == 200) {
//         var xmlDoc = xml.XmlDocument.parse(response.body);
//         var resultNode = xmlDoc.findAllElements("fullenglistResult").first;
//         var resultString = resultNode.text.trim();
//         print('Result String: $resultString');
//
//         List<String> nameAndAlarmPairs = resultString.split('    :: -::-,');
//         print('Name and Alarm Pairs: $nameAndAlarmPairs');
//
//         List<Map<String, String>> data = [];
//
//         nameAndAlarmPairs.forEach((pair) {
//           List<String> parts = pair.split('::');
//           if (parts.length >= 2) {
//             String name = parts[0].trim();
//             String alarmsCount = parts[1].trim().split('[')[1].split(']')[0];
//             data.add({"Name": name, "Open Alarms": alarmsCount});
//           }
//         });
//
//         setState(() {
//           alarms = data;
//         });
//       } else {
//         print('Failed to fetch data: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching data: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Current Alarms', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         backgroundColor: const Color(0xFF00305e),
//         iconTheme: const IconThemeData(color: Colors.white),
//         toolbarHeight: 70,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: DataTable(
//           columnSpacing: 16.0,
//           headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
//           columns: const [
//             DataColumn(
//               label: Text('Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//             ),
//             DataColumn(
//               label: Text('Open Alarms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//               numeric: true,
//             ),
//           ],
//           rows: alarms.map((alarm) {
//             return DataRow(
//               cells: [
//                 DataCell(Text(alarm['Name'] ?? '')),
//                 DataCell(Text(alarm['Open Alarms'] ?? '')),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
// }

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
import 'node_type_selection.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class AlarmsByAlarmTypesPage extends StatefulWidget {
  const AlarmsByAlarmTypesPage({Key? key}) : super(key: key);

  @override
  _AlarmsByAlarmTypesPageState createState() => _AlarmsByAlarmTypesPageState();
}

class _AlarmsByAlarmTypesPageState extends State<AlarmsByAlarmTypesPage> {
  late Future<List<Map<String, dynamic>>> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <alarm_types_2 xmlns="http://tempuri.org/">
        <nw_eng>...ALL...</nw_eng>
      </alarm_types_2>
    </soap:Body>
  </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/alarm_types_2',
        },
        body: soapBody,
      );

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("alarm_types_2Result").first;
        var resultString = resultNode.text.trim();
        List<String> data = resultString.split(',');

        List<Map<String, dynamic>> types = [];

        for (var entry in data) {
          List<String> parts = entry.split('::');
          if (parts.length == 4) {
            String alarmType = parts[0].trim();
            String count = parts[1].trim();
            types.add({"AlarmType": alarmType, "Count": count});
          }
        }

        return types;
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching data: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarms Types',
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.tablePagePadding),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CustomLoadingIndicator();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading data: ${snapshot.error}'),
                        );
                      } else {
                        return styledDataTable(snapshot.data ?? []);
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

  Widget styledDataTable(List<Map<String, dynamic>> alarmDetails) {
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
                  label: Text('Alarm Type',
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
                  label: Text('Count',
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
              rows: alarmDetails.map((data) {
                Color openAlarmColor = int.parse(data['Count'] ?? '0') > 500
                    ? Colors.red
                    : const Color(0xFF00305e);
                return DataRow(
                  onSelectChanged: (bool? selected) {
                    if (selected != null && selected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NodeTypeSelectionPage(
                              alarmType: data['AlarmType'].toString(),
                              name: '...ALL...',
                              province: '...All...'),
                        ),
                      );
                    }
                  },
                  cells: [
                    DataCell(Text(data['AlarmType'].toString(),
                        style: TextStyle(
                            fontSize: 0.037 *
                                (MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? screenWidth
                                    : screenHeight),
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF00305e)))),
                    DataCell(
                      Text(data['Count'].toString(),
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

// import 'package:flutter/material.dart';
// import 'package:sltnoc/settings_button.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'alarm_type_details.dart';
//
// class CurrentAlarmsExpandedPage1 extends StatefulWidget {
//   final String name;
//   final String province; // Add province parameter
//
//   const CurrentAlarmsExpandedPage1({super.key, required this.name, required this.province}); // Modify constructor
//
//   @override
//   _CurrentAlarmsExpandedPage1State createState() => _CurrentAlarmsExpandedPage1State();
// }
//
//
// class _CurrentAlarmsExpandedPage1State extends State<CurrentAlarmsExpandedPage1> {
//   List<Map<String, dynamic>> apiData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     // final response = await http.get(Uri.parse('http://192.168.1.11:3000/api/alarms2/data/${widget.name}/${widget.province}')); // Pass province parameter
//     final response = await http.get(Uri.parse('http://192.168.1.100:3000/api/alarms2/data/${widget.name}/${widget.province}')); // Pass province parameter
//
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       setState(() {
//         apiData = List<Map<String, dynamic>>.from(jsonData);
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String firstName = widget.name.split(' ')[0];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Current Alarms for $firstName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
//             _buildFixedText(), // Add the fixed text for Province and Name
//             const SizedBox(height: 10), // Add some vertical spacing
//             Expanded(
//               child: SingleChildScrollView(
//                 child: styledDataTable(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFixedText() {
//     return Container(
//       // height: 100, // Fixed height to keep the text lines fixed
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildText('Province:', widget.province),
//           const SizedBox(height: 8), // Add line spacing
//           _buildText('Name:', widget.name),
//           const SizedBox(height: 8), // Add larger vertical spacing after Name
//         ],
//       ),
//     );
//   }
//
//   Widget _buildText(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//         const SizedBox(width: 8), // Add some spacing between label and value
//         Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2))),
//       ],
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
//               label: Text('Alarm Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//             ),
//             DataColumn(
//               label: Text('Open Alarms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//               numeric: true,
//             ),
//           ],
//           rows: apiData.map((data) {
//             Color openAlarmColor = int.parse(data['OpenAlarms'].toString()) > 500 ? Colors.red : Colors.black;
//             return DataRow(
//               cells: [
//                 DataCell(
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AlarmDetailsPage(
//                             alarmType: data['ALARM_TYPE'].toString(),
//                             name: widget.name,
//                             province: widget.province,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Text(data['ALARM_TYPE'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF00305e))),
//                   ),
//                 ),
//                 DataCell(
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AlarmDetailsPage(
//                             alarmType: data['ALARM_TYPE'].toString(),
//                             name: widget.name,
//                             province: widget.province,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Text(data['OpenAlarms'].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: openAlarmColor)),
//                   ),
//                 ),
//                 // DataCell(
//                 //   Text(data['OpenAlarms'].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: openAlarmColor)),
//                 // ),
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
import 'alarm_type_details.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentAlarmsExpandedPage1 extends StatefulWidget {
  final String name;
  final String province;

  const CurrentAlarmsExpandedPage1(
      {Key? key, required this.name, required this.province})
      : super(key: key);

  @override
  _CurrentAlarmsExpandedPage1State createState() =>
      _CurrentAlarmsExpandedPage1State();
}

class _CurrentAlarmsExpandedPage1State
    extends State<CurrentAlarmsExpandedPage1> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> soapData = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchSoapData();
  }

  Future<void> fetchSoapData() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <alarm_types_2 xmlns="http://tempuri.org/">
              <nw_eng>${widget.name}</nw_eng>
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
        print('SOAP Response: $resultString');

        List<String> alarmTypeData = resultString.split('    :: -::-,');
        print('Alarm Type Data: $alarmTypeData');

        List<Map<String, dynamic>> data = [];

        for (var type in alarmTypeData) {
          List<String> parts = type.split('::');
          if (parts.length >= 2) {
            String alarmType = parts[0].trim();
            String openAlarms = parts[1].trim().split(' ')[0];
            data.add({"ALARM_TYPE": alarmType, "OpenAlarms": openAlarms});
          }
        }

        setState(() {
          soapData = data;
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
    String firstName = widget.name.split(' ')[0];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Alarms for $firstName',
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
              _buildFixedText(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.tablePagePadding),
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
              rows: soapData.map((data) {
                Color openAlarmColor =
                    int.parse(data['OpenAlarms'].toString()) > 500
                        ? Colors.red
                        : const Color(0xFF00305e);
                return DataRow(
                  onSelectChanged: (bool? selected) {
                    if (selected != null && selected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlarmDetailsPage(
                              alarmType: data['ALARM_TYPE'].toString(),
                              name: widget.name,
                              province: widget.province),
                        ),
                      );
                    }
                  },
                  cells: [
                    DataCell(
                      Text(data['ALARM_TYPE'].toString(),
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
                      Text(data['OpenAlarms'].toString(),
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
          _buildText('Province:', widget.province),
          const SizedBox(height: 3),
          _buildText('NW Engineer:', widget.name),
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

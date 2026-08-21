// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:sltnoc/settings_button.dart';
// import 'node_details.dart';
//
// class AlarmDetailsPage extends StatefulWidget {
//   final String alarmType;
//   final String name;
//   final String province;
//
//   const AlarmDetailsPage({super.key, required this.alarmType, required this.name, required this.province});
//
//   @override
//   _AlarmDetailsPageState createState() => _AlarmDetailsPageState();
// }
//
// class _AlarmDetailsPageState extends State<AlarmDetailsPage> {
//   List<Map<String, dynamic>> alarmDetails = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     final response = await http.get(Uri.parse('http://192.168.1.100:3000/api/alarm-details/data/${widget.alarmType}/${widget.name}/${widget.province}'));
//     // final response = await http.get(Uri.parse('http://192.168.1.11:3000/api/alarm-details/data/${widget.alarmType}/${widget.name}/${widget.province}'));
//
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       setState(() {
//         alarmDetails = List<Map<String, dynamic>>.from(jsonData);
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
//         title: const Text('Alarm Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
//             _buildFixedText(),
//             const SizedBox(height: 20),
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
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildText('Province:', widget.province),
//         const SizedBox(height: 8), // Add line spacing
//         _buildText('Name:', widget.name),
//         const SizedBox(height: 8), // Add line spacing
//         _buildText('Alarm Type:', widget.alarmType),
//       ],
//     );
//   }
//
//   Widget _buildText(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//         const SizedBox(width: 8), // Add some spacing between label and value
//         Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0056A2))), // Change color as needed
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
//               label: Text('Node', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//             ),
//             DataColumn(
//               label: Text('Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//               numeric: true,
//             ),
//           ],
//           rows: alarmDetails.map((data) {
//             return DataRow(
//               cells: [
//                 DataCell(
//                   InkWell(
//                     onTap: () {
//                       // Navigate to NodeDetailsPage when node name is tapped
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => NodeDetailsPage(nodeName: data['NODE'].toString(), name: widget.name,province: widget.province,alarmType: widget.alarmType),
//                         ),
//                       );
//                     },
//                     child: Text(data['NODE'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF00305e))),
//                   ),
//                 ),
//                 DataCell(
//                   InkWell(
//                     onTap: () {
//                       // Navigate to NodeDetailsPage when node name is tapped
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => NodeDetailsPage(nodeName: data['NODE'].toString(), name: widget.name,province: widget.province,alarmType: widget.alarmType),
//                         ),
//                       );
//                     },
//                     child: Text(data['DURATION'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
//                   ),
//                 ),
//                 // DataCell(
//                 //   Text(data['DURATION'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
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
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/settings_button.dart';
import 'node_details.dart';
import 'cea_details.dart';
import 'fault_record_filter.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class AlarmDetailsPage extends StatefulWidget {
  final String alarmType;
  final String name;
  final String province;

  const AlarmDetailsPage(
      {super.key,
      required this.alarmType,
      required this.name,
      required this.province});

  @override
  _AlarmDetailsPageState createState() => _AlarmDetailsPageState();
}

class _AlarmDetailsPageState extends State<AlarmDetailsPage> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> alarmDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFuture =
        fetchData(); // Move this line to the end of the initState method
  }

  Future<void> fetchData() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <faults4 xmlns="http://tempuri.org/">
      <nweng>${widget.name}</nweng>
      <alarm_type>${widget.alarmType}</alarm_type>
    </faults4>
  </soap:Body>
</soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '"http://tempuri.org/faults4"',
        },
        body: soapBody,
      );

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("faults4Result").first;
        var resultString = resultNode.text.trim();

        List<String> data = resultString.split(',');

        List<Map<String, dynamic>> details = [];

        for (var entry in data) {
          List<String> parts = entry.split('::');
          if (parts.length >= 5) {
            if (isClosedFaultRecord(parts)) {
              continue;
            }

            String nodeName = parts[0].trim();
            String alarmType = parts[1].trim();
            String hours = parts[2].trim().split(' ')[0];
            String name = parts[3].trim();
            String platform = parts.length > 4 ? parts[4].trim() : '';
            String ip = parts.length > 5 ? parts[5].trim() : '';

            // For CEA platforms, capture additional details
            String ceaExtraDetails = '';
            if (platform.toUpperCase() == 'CEA' && parts.length > 6) {
              // Join all remaining parts as extra CEA details
              ceaExtraDetails = parts.sublist(6).join('::').trim();
            }

            details.add({
              "NODE": nodeName,
              "DURATION": hours,
              "ALARM_TYPE": alarmType,
              "NAME": name,
              "PLATFORM": platform,
              "IP": ip,
              "CEA_EXTRA_DETAILS": ceaExtraDetails
            });
          }
        }

        setState(() {
          alarmDetails = details;
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
        title: Text('Alarms Details',
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
              dataRowColor: WidgetStateColor.resolveWith(
                  (states) => AppConfig.tableRowColor),
              columnSpacing: AppConfig.columnSpacing,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => AppConfig.tableHeadingColor),
              // dataRowMaxHeight: 90,
              // dataRowMinHeight: 90,
              dataRowMaxHeight: double.infinity,
              columns: [
                DataColumn(
                  label: Text('Node',
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
                  label: Text('Duration',
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
                return DataRow(
                  onSelectChanged: (bool? selected) {
                    if (selected != null && selected) {
                      // Navigate based on platform type
                      if (data['PLATFORM'].toString().toUpperCase() == 'CEA') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CeaDetailsPage(
                              nodeName: data['NODE'].toString(),
                              name: data['NAME'].toString(),
                              province: widget.province,
                              alarmType: data['ALARM_TYPE'].toString(),
                              platform: data['PLATFORM'].toString(),
                              ip: data['IP'].toString(),
                              ceaExtraDetails:
                                  data['CEA_EXTRA_DETAILS'].toString(),
                              duration: data['DURATION'].toString(),
                            ),
                          ),
                        );
                      } else {
                        // Navigate to regular NodeDetailsPage for other platforms
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NodeDetailsPage(
                                nodeName: data['NODE'].toString(),
                                name: data['NAME'].toString(),
                                province: widget.province,
                                alarmType: data['ALARM_TYPE'].toString()),
                          ),
                        );
                      }
                    }
                  },
                  cells: [
                    DataCell(
                      // Text(data['NODE'].toString(), style: AppConfig.singleLineTableFistColumnTextStyle),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0), // Add top and bottom margin
                        child: Container(
                          alignment: Alignment.centerLeft, // Align text left
                          // height: 200, // Increase the height to accommodate the description
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: data['NODE'].toString(),
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF00305e))),
                                const TextSpan(text: '\n'),
                                const WidgetSpan(
                                    child: SizedBox(
                                        height: AppConfig.SizedBoxHeight)),
                                TextSpan(
                                    text: data['ALARM_TYPE'].toString(),
                                    style: TextStyle(
                                        fontSize: 0.035 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500)),
                                const TextSpan(text: '\n'),
                                const WidgetSpan(
                                    child: SizedBox(
                                        height: AppConfig.SizedBoxHeight)),
                                TextSpan(
                                    text: data['NAME'].toString(),
                                    style: TextStyle(
                                        fontSize: 0.035 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        color: Colors.green,
                                        height: 1.3,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                          '${_extractNumericValue(data['DURATION'].toString())} Hours',
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

  String _extractNumericValue(String duration) {
    // Extract numerical part of the duration string
    RegExp regex = RegExp(r'\b\d+\b');
    Match? match = regex.firstMatch(duration);
    return match?.group(0) ?? '';
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
          const SizedBox(height: 3), // Add line spacing
          _buildText('NW Engineer:', widget.name),
          const SizedBox(height: 3), // Add line spacing
          _buildText('Alarm Type:', widget.alarmType),
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
                fontSize: 0.035 *
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
                fontSize: 0.035 *
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

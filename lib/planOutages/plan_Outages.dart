import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class PlanOutagesPage extends StatefulWidget {
  final String name;
  final String title;
  // final bool isInNwengList;

  const PlanOutagesPage({Key? key, required this.title, required this.name})
      : super(key: key);

  @override
  _PlanOutagesPageState createState() => _PlanOutagesPageState();
}

class _PlanOutagesPageState extends State<PlanOutagesPage> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> plannedOutageDetailsMap = [];
  Map<String, bool> engNameList = {};
  String _selectedEngName = 'All';

  @override
  void initState() {
    super.initState();
    _fetchDataFuture =
        fetchPlannedOutageDetails(); // Fetch data when the widget initializes
  }

  Future<void> fetchEngNameList() async {
    final fullEngListResponse = await http.post(
      Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/fullenglist',
      },
      body: '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <fullenglist xmlns="http://tempuri.org/">
            </fullenglist>
          </soap:Body>
        </soap:Envelope>''',
    );

    // print('Faults 3 Response: ${fullEngListResponse.body}');

    if (fullEngListResponse.statusCode == 200) {
      // Parse the response and update engNameList map
      final fullEngListXml = xml.XmlDocument.parse(fullEngListResponse.body);
      final fullEngListResult =
          fullEngListXml.findAllElements('fullenglistResult').single.text;

      final names = fullEngListResult.split(',').map((record) {
        // Extract the name from each record
        final name = record.split('::')[0];
        return name.trim(); // Trim any leading/trailing spaces
      });

      // Add extracted names to the engNameList map
      for (final name in names) {
        engNameList[name] = true;
      }
    } else {
      // Handle error case
      print('Failed to fetch engNameList: ${fullEngListResponse.statusCode}');
    }
    // print(engNameList);
  }

  Future<void> fetchPlannedOutageDetails() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    String engName;

    try {
      // Fetch the eng list if not already fetched
      if (engNameList.isEmpty) {
        await fetchEngNameList();
      }

      engName = _selectedEngName;

      String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <get_Planned_Outage_Details xmlns="http://tempuri.org/">
              <engname>$engName</engname>
            </get_Planned_Outage_Details>
          </soap:Body>
        </soap:Envelope>''';

      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/get_Planned_Outage_Details',
        },
        body: soapBody,
      );

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNodes =
            xmlDoc.findAllElements("get_Planned_Outage_DetailsResult");
        // print('Result Node: $resultNodes');
        List<Map<String, dynamic>> plannedOutageDetails = [];

        for (var resultNode in resultNodes) {
          var tableNames = resultNode.findAllElements("TableName");
          for (var tableName in tableNames) {
            var acno = tableName.findElements("acno").first.text;
            var fd = tableName.findElements("fd").first.text;
            var ft = tableName.findElements("ft").first.text;
            var td = tableName.findElements("td").first.text;
            var tt = tableName.findElements("tt").first.text;
            var reason = tableName.findElements("reason").first.text;
            var elementCode = tableName.findElements("node").isNotEmpty
                ? tableName.findElements("node").first.text
                : null;
            var supplier = tableName.findElements("supplier").isNotEmpty
                ? tableName.findElements("supplier").first.text
                : null;
            var platform = tableName.findElements("platform").isNotEmpty
                ? tableName.findElements("platform").first.text
                : null;

            // print('acno: $acno, fd: $fd, ft: $ft, td: $td, tt: $tt, reason: $reason, element_code: $elementCode, supplier: $supplier, platform: $platform');

            plannedOutageDetails.add({
              "acno": acno,
              "fd": fd,
              "ft": ft,
              "td": td,
              "tt": tt,
              "reason": reason,
              "node": elementCode,
              "supplier": supplier,
              "platform": platform,
            });
          }
        }

        setState(() {
          // Update your state with the fetched data
          plannedOutageDetailsMap = plannedOutageDetails;
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
        title: Text(widget.title,
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
          padding: EdgeInsets.all(0.025 * MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildText('Work Group:', widget.title),
              // const SizedBox(height: 16),
              if (engNameList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: AppConfig.tableBorderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedEngName,
                      isExpanded: true,
                      items: ['All', ...engNameList.keys].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null && newValue != _selectedEngName) {
                          setState(() {
                            _selectedEngName = newValue;
                            _fetchDataFuture = fetchPlannedOutageDetails();
                          });
                        }
                      },
                    ),
                  ),
                ),
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
              // dataRowHeight: 190, // Set the minimum height for the DataRow
              dataRowMaxHeight: double.infinity,
              columns: [
                DataColumn(
                  label: Text('Planned Outages',
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
              rows: plannedOutageDetailsMap.map((index) {
                return DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0), // Add your desired margin here
                        child: Container(
                          alignment: Alignment.centerLeft, // Align text left
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6),
                              children: [
                                TextSpan(
                                    text: 'Account No: ',
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                TextSpan(
                                    text: index['acno'],
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF0056A2))),
                                const TextSpan(text: '\n'),
                                TextSpan(
                                    text: 'From: ',
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                TextSpan(
                                    text: '${index['fd']} ${index['ft']}',
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red)),
                                const TextSpan(text: '\n'),
                                TextSpan(
                                    text: 'To: ',
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                TextSpan(
                                    text: '${index['td']} ${index['tt']}',
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red)),
                                const TextSpan(text: '\n'),
                                TextSpan(
                                    text: 'Reason: ',
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                TextSpan(
                                    text: index['reason'],
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF0056A2))),
                                if (index['node'] != null) ...[
                                  const TextSpan(text: '\n'),
                                  TextSpan(
                                      text: 'Node: ',
                                      style: TextStyle(
                                          fontSize: 0.037 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  TextSpan(
                                      text: index['node'],
                                      style: TextStyle(
                                          fontSize: 0.037 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0056A2))),
                                ],
                                if (index['supplier'] != null) ...[
                                  const TextSpan(text: '\n'),
                                  TextSpan(
                                      text: 'Supplier: ',
                                      style: TextStyle(
                                          fontSize: 0.037 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  TextSpan(
                                      text: index['supplier'],
                                      style: TextStyle(
                                          fontSize: 0.037 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0056A2))),
                                ],
                                if (index['platform'] != null) ...[
                                  const TextSpan(text: '\n'),
                                  TextSpan(
                                      text: 'Platform: ',
                                      style: TextStyle(
                                          fontSize: 0.037 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  TextSpan(
                                      text: index['platform'],
                                      style: TextStyle(
                                          fontSize: 0.037 *
                                              (MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.portrait
                                                  ? screenWidth
                                                  : screenHeight),
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0056A2))),
                                ],
                              ],
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
}

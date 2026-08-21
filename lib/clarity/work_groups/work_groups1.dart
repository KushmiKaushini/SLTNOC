import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'work_groups2.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class WorkGroupsPage extends StatefulWidget {
  const WorkGroupsPage({Key? key}) : super(key: key);

  @override
  _WorkGroupsPageState createState() => _WorkGroupsPageState();
}

class _WorkGroupsPageState extends State<WorkGroupsPage> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> workgroups = [];

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
          <work_groups xmlns="http://tempuri.org/" />
        </soap:Body>
      </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/work_groups',
        },
        body: soapBody,
      );

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("work_groupsResult").first;
        var resultString = resultNode.text.trim();

        List<String> records = resultString.split(',');

        List<Map<String, dynamic>> data = [];

        for (var record in records) {
          List<String> parts = record.split('(');
          if (parts.length == 2) {
            String type = parts[0].trim();
            int count = int.parse(parts[1].replaceAll(')', '').trim());
            data.add({"Type": type, "Count": count});
          }
        }

        setState(() {
          workgroups = data;
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
        title: Text('Work Groups',
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
                  label: Text('Work Groups',
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
              rows: workgroups.map((workGroups) {
                return DataRow(
                  onSelectChanged: (bool? selected) {
                    if (selected != null && selected) {
                      // Navigate to WorkGroupsPage2 when the row is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkGroupsPage2(
                              workGrouptype: workGroups['Type']),
                        ),
                      );
                    }
                  },
                  cells: [
                    DataCell(
                      Text(workGroups['Type'],
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
                        workGroups['Count'].toString(),
                        textAlign: AppConfig.secondColumnDataAlignment,
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

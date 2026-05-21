import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class WorkGroupsPage2 extends StatefulWidget {
  final String workGrouptype;

  const WorkGroupsPage2({
    Key? key,
    required this.workGrouptype,
  }) : super(key: key);

  @override
  _WorkGroupsPage2State createState() => _WorkGroupsPage2State();
}

class _WorkGroupsPage2State extends State<WorkGroupsPage2> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> workgroups2 = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData(); // Fetch data when the widget initializes
  }

  Future<void> fetchData() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <dockets_in_work_groups xmlns="http://tempuri.org/">
            <selection>${widget.workGrouptype}</selection>
          </dockets_in_work_groups>
        </soap:Body>
      </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/dockets_in_work_groups',
        },
        body: soapBody,
      );

      // print('SOAP Response: ${response.body}');

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode =
            xmlDoc.findAllElements("dockets_in_work_groupsResult").first;
        var resultString = resultNode.text.trim();

        // print('Result String: ${resultString}');

        List<String> records = resultString.split(',');
        // print('records: ${records}');
        List<Map<String, dynamic>> data = [];

        for (var record in records) {
          List<String> parts = record.split('::');
          // print('parts: ${parts}');
          if (parts.length == 4) {
            String docket = parts[0].trim();
            String status = parts[1].trim();
            // String code = parts[2].trim();
            String description = parts[3].trim();
            String duration = parts[2].trim();

            data.add({
              "Docket": docket,
              "Status": status,
              // "Code": code,
              "Description": description,
              "Duration": duration,
            });
          }
        }
        // print('data: ${data}');
        setState(() {
          workgroups2 = data;
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
                child: _buildText('Work Groups:', widget.workGrouptype),
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
              dataRowColor: MaterialStateColor.resolveWith(
                  (states) => AppConfig.tableRowColor),
              columnSpacing: AppConfig.columnSpacing,
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => AppConfig.tableHeadingColor),
              // dataRowHeight: 140, // Set the minimum height for the DataRow
              dataRowMaxHeight: double.infinity,
              columns: [
                DataColumn(
                  label: Text('Fault',
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
                  label: Text('Hours',
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
              rows: workgroups2.map((workGroup) {
                return DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0), // Add top and bottom margin
                        child: Container(
                          alignment: Alignment.centerLeft, // Align text left
                          // height: 150, // Increase the height to accommodate the description
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: workGroup['Docket'],
                                    style: TextStyle(
                                        fontSize: 0.037 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00305e))),
                                const TextSpan(text: '\n'),
                                const WidgetSpan(
                                    child: SizedBox(
                                        height: AppConfig.SizedBoxHeight1)),
                                TextSpan(
                                    text: workGroup['Status'],
                                    style: TextStyle(
                                        fontSize: 0.035 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        color: Colors.red,
                                        fontWeight: FontWeight
                                            .w500)), // Adjust height as needed
                                const TextSpan(text: '\n'),
                                const WidgetSpan(
                                    child: SizedBox(
                                        height: AppConfig.SizedBoxHeight1)),
                                TextSpan(
                                    text: workGroup['Description'],
                                    style: TextStyle(
                                        fontSize: 0.035 *
                                            (MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? screenWidth
                                                : screenHeight),
                                        color: Colors.green,
                                        height: 1.3,
                                        fontWeight: FontWeight
                                            .w500)), // Adjust height as needed
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24.0), // Add top and bottom margin
                        child: Container(
                          alignment: Alignment.centerRight, // Align text right
                          child: InkWell(
                            child: Text(workGroup['Duration'].toString(),
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

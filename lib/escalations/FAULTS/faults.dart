import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class faultsPage extends StatefulWidget {
  final String title;

  const faultsPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _faultsPageState createState() => _faultsPageState();
}

class _faultsPageState extends State<faultsPage> {
  late Future<void> _fetchDataFuture;
  List<Map<String, dynamic>> faults = [];

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
            <getSelection2 xmlns="http://tempuri.org/">
              <selection>${widget.title}</selection>
              <serviceno></serviceno> <!-- Keep it empty -->
            </getSelection2>
          </soap:Body>
        </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/getSelection2',
        },
        body: soapBody,
      );

      // print('SOAP Response: ${response.body}');

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("getSelection2Result").first;
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
            String description = parts[3].trim();
            String duration = parts[2].trim();

            data.add({
              "Docket": docket,
              "Status": status,
              "Description": description,
              "Duration": duration,
            });
          }
        }
        // print('data: ${data}');
        setState(() {
          faults = data;
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
          padding: const EdgeInsets.all(AppConfig.tablePagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildText('Work Group:', widget.title),
              // const SizedBox(height: 16),
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
              // dataRowHeight: 150, // Set the minimum height for the DataRow
              dataRowMaxHeight: double.infinity,
              // dataRowMinHeight: 130,
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
              rows: faults.map((index) {
                return DataRow(
                  cells: [
                    DataCell(
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
                                    text: index['Docket'],
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
                                        height: AppConfig.SizedBoxHeight1)),
                                TextSpan(
                                    text: index['Status'],
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
                                    text: index['Description'],
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
                            child: Text(index['Duration'].toString(),
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
}

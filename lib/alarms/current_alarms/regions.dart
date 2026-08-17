import 'package:flutter/material.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/alarms/current_alarms/selected_metro_region.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/loading_indicator.dart';
import 'package:sltnoc/widgets/my_card.dart';

class RegionsPage extends StatefulWidget {
  const RegionsPage({Key? key}) : super(key: key);

  @override
  _RegionsPageState createState() => _RegionsPageState();
}

class _RegionsPageState extends State<RegionsPage> {
  List<String> regions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRegions();
  }

  Future<void> fetchRegions() async {
    final String url = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapXML = '''<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <get_regions xmlns="http://tempuri.org/" />
              </soap:Body>
            </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/get_regions',
        },
        body: soapXML,
      );

      final xmlDocument = xml.XmlDocument.parse(response.body);
      final regionsXml = xmlDocument.findAllElements('region');
      final List<String> fetchedRegions =
          regionsXml.map((node) => node.text).toList();

      setState(() {
        regions = fetchedRegions;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching regions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Metro & Regions',
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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConfig.bodyBackgroundImagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: Scrollbar(
              // Wrap ListView.builder with Scrollbar widget
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.tablePagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Generate cards for regions
                            ...regions.map((region) {
                              return MyCard.metro(
                                title: region,
                                borderColor: const Color(0xFF0056A2),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SelectedMetroRegionPage(
                                              title: region),
                                    ),
                                  );
                                },
                                height: 150,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) CustomLoadingIndicator(),
        ],
      ),
    );
  }
}

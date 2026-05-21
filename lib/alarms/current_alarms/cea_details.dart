import 'package:flutter/material.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/loading_indicator.dart';

class CeaDetailsPage extends StatefulWidget {
  final String nodeName;
  final String name;
  final String province;
  final String alarmType;
  final String platform;
  final String ip;
  final String ceaExtraDetails;
  final String duration;

  const CeaDetailsPage({
    super.key,
    required this.nodeName,
    required this.name,
    required this.province,
    required this.alarmType,
    required this.platform,
    required this.ip,
    this.ceaExtraDetails = '',
    this.duration = '',
  });

  @override
  _CeaDetailsPageState createState() => _CeaDetailsPageState();
}

class _CeaDetailsPageState extends State<CeaDetailsPage> {
  List<Map<String, dynamic>> ceaDetails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch CEA details
      await fetchData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchData() async {
    const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    final String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <get_CEA_details xmlns="http://tempuri.org/">
      <ceaip>${widget.ip}</ceaip>
    </get_CEA_details>
  </soap:Body>
</soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '"http://tempuri.org/get_CEA_details"',
        },
        body: soapBody,
      );

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("get_CEA_detailsResult").first;
        var resultString = resultNode.innerText.trim();

        print('CEA API Response: $resultString'); // Debug log

        // Parse the main response string directly (not comma-separated)
        List<String> parts = resultString.split('::');
        print('Entry parts: $parts'); // Debug log

        // Store the raw parts for contact parsing
        setState(() {
          ceaDetails = []; // Clear previous data

          // Create a single entry with all the parsed data for contact extraction
          Map<String, dynamic> mainData = {
            "RAW_PARTS": parts,
            "RESPONSE": resultString
          };
          ceaDetails.add(mainData);
        });
      } else {
        print('Failed to fetch CEA data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching CEA data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('CEA Details',
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
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig.bodyBackgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? Center(child: CustomLoadingIndicator())
            : _buildCardLayout(),
      ),
    );
  }

  Widget _buildCardLayout() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Card(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'CEA Port Details',
                    style: TextStyle(
                        fontSize: 0.050 *
                            (MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? screenWidth
                                : screenHeight),
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildText('Node:', widget.nodeName),
                  _buildText('Platform:', widget.platform),
                  _buildText('IP Address:', widget.ip),
                  _buildText('Alarm Type:', widget.alarmType),
                  _buildText('NW Engineer:', widget.name),
                  _buildText('Province:', widget.province),
                  if (widget.ceaExtraDetails.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildCeaExtraDetailsSection(),
                  ],
                  const SizedBox(height: 24),
                  _buildContactDetailsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetailsSection() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Extract contact details from CEA API response using logic similar to node details
    Map<String, String> contactData = _parseContactDetails();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Contact Details',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 0.037 *
                  (MediaQuery.of(context).orientation == Orientation.portrait
                      ? screenWidth
                      : screenHeight),
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig.cardBackgroundImagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(AppConfig.NDBorderRadius),
            border: Border.all(
                color: AppConfig.NDBorderColor, width: AppConfig.NDBorderWidth),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.NDCardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildText('${contactData['contName1'] ?? 'Contact 1'}:',
                    contactData['num1'] ?? 'N/A'),
                Divider(color: AppConfig.NDDivider),
                _buildText('${contactData['contName2'] ?? 'Contact 2'}:',
                    contactData['num2'] ?? 'N/A'),
                Divider(color: AppConfig.NDDivider),
                _buildText('${contactData['contName3'] ?? 'Contact 3'}:',
                    contactData['num3'] ?? 'N/A'),
                Divider(color: AppConfig.NDDivider),
                _buildText('${contactData['contName4'] ?? 'Contact 4'}:',
                    contactData['num4'] ?? 'N/A'),
                Divider(color: AppConfig.NDDivider),
                _buildText('${contactData['contName5'] ?? 'Contact 5'}:',
                    contactData['num5'] ?? 'N/A'),
                Divider(color: AppConfig.NDDivider),
                _buildText('${contactData['contName6'] ?? 'Contact 6'}:',
                    contactData['num6'] ?? 'N/A'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCeaExtraDetailsSection() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Parse the extra CEA details
    Map<String, String> extraDetails = _parseCeaExtraDetails();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'CEA Technical Details',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 0.037 *
                  (MediaQuery.of(context).orientation == Orientation.portrait
                      ? screenWidth
                      : screenHeight),
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig.cardBackgroundImagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(AppConfig.NDBorderRadius),
            border: Border.all(
                color: AppConfig.NDBorderColor, width: AppConfig.NDBorderWidth),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.NDCardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.duration.isNotEmpty)
                  _buildText('Duration:', widget.duration),
                if (extraDetails['port'] != null) ...[
                  if (widget.duration.isNotEmpty)
                    Divider(color: AppConfig.NDDivider),
                  _buildText('Port:', extraDetails['port']!),
                ],
                if (extraDetails['circuit'] != null) ...[
                  Divider(color: AppConfig.NDDivider),
                  _buildText('Circuit:', extraDetails['circuit']!),
                ],
                if (extraDetails['rxPower'] != null) ...[
                  Divider(color: AppConfig.NDDivider),
                  _buildText('Rx Power:', extraDetails['rxPower']!),
                ],
                if (extraDetails['reason'] != null) ...[
                  Divider(color: AppConfig.NDDivider),
                  _buildText('Reason:', extraDetails['reason']!),
                ],
                if (widget.ceaExtraDetails.contains('Reason=') ||
                    widget.ceaExtraDetails.contains('location=')) ...[
                  Divider(color: AppConfig.NDDivider),
                  _buildText('Fault Description:', widget.ceaExtraDetails),
                ] else if (extraDetails.isEmpty && widget.duration.isEmpty)
                  _buildText('Raw Details:', widget.ceaExtraDetails),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<String, String> _parseCeaExtraDetails() {
    Map<String, String> details = {};

    if (widget.ceaExtraDetails.isEmpty) return details;

    String rawDetails = widget.ceaExtraDetails;
    print('Parsing CEA extra details: $rawDetails'); // Debug log

    // Extract Port
    RegExp portRegex = RegExp(r'Port:\s*([^:]+?)(?=\s+Circuit:|$)');
    Match? portMatch = portRegex.firstMatch(rawDetails);
    if (portMatch != null) {
      details['port'] = portMatch.group(1)!.trim();
    } else {
      RegExp altPortRegex = RegExp(r'PhysicalName=([^\s:]+)');
      Match? altPortMatch = altPortRegex.firstMatch(rawDetails);
      if (altPortMatch != null) {
        details['port'] = altPortMatch.group(1)!.trim();
      }
    }

    // Extract Circuit
    RegExp circuitRegex = RegExp(r'Circuit:\s*([^:]+?)(?=\s+Rx Power:|$)');
    Match? circuitMatch = circuitRegex.firstMatch(rawDetails);
    if (circuitMatch != null) {
      details['circuit'] = circuitMatch.group(1)!.trim();
    } else {
      RegExp altCircuitRegex = RegExp(r'If Alias=(.+?)(?=\s+If Memo|:|$)');
      Match? altCircuitMatch = altCircuitRegex.firstMatch(rawDetails);
      if (altCircuitMatch != null) {
        details['circuit'] =
            altCircuitMatch.group(1)!.replaceAll('##', '').trim();
      }
    }

    // Extract Rx Power
    RegExp rxPowerRegex = RegExp(r'Rx Power:\s*(.+?)$');
    Match? rxPowerMatch = rxPowerRegex.firstMatch(rawDetails);

    RegExp altRxPowerRegex = RegExp(
        r'current Rx power is\s*([-\d.]+\s*(?:dBm|dBM|dbm|dB))',
        caseSensitive: false);
    Match? altRxPowerMatch = altRxPowerRegex.firstMatch(rawDetails);

    if (altRxPowerMatch != null) {
      details['rxPower'] = altRxPowerMatch.group(1)!.trim();
    } else if (rxPowerMatch != null) {
      details['rxPower'] = rxPowerMatch.group(1)!.trim();
    }

    // Extract Fault Description / Reason
    RegExp reasonRegex = RegExp(r'Reason=(.*?)(?=The detail information|$)',
        caseSensitive: false);
    Match? reasonMatch = reasonRegex.firstMatch(rawDetails);
    if (reasonMatch != null) {
      details['reason'] = reasonMatch.group(1)!.trim();
    }

    print('Parsed CEA extra details: $details'); // Debug log
    return details;
  }

  Map<String, String> _parseContactDetails() {
    Map<String, String> contactData = {};

    if (ceaDetails.isEmpty) {
      print('No CEA details available for parsing');
      return contactData;
    }

    // Get the raw parts from the API response
    List<String> parts = ceaDetails[0]['RAW_PARTS'] ?? [];
    print('Parsing contact details from ${parts.length} parts'); // Debug log

    List<String> contactNames = [];
    List<String> contactNumbers = [];

    // Based on the sample response, extract contact information
    // The pattern appears to be: name at odd positions, phone numbers at even positions
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();

      if (part.isEmpty) continue;

      // Check if this part looks like a phone number
      if (_isPhoneNumber(part)) {
        contactNumbers.add(part);
        print('Found phone number: $part'); // Debug log
      }
      // Check if this part looks like a person's name
      else if (_isPersonName(part)) {
        contactNames.add(part);
        print('Found contact name: $part'); // Debug log
      }
    }

    // Match contact names with numbers (similar to node details structure)
    for (int i = 0; i < 6; i++) {
      int contactIndex = i + 1;
      if (i < contactNames.length) {
        contactData['contName$contactIndex'] = contactNames[i];
      }
      if (i < contactNumbers.length) {
        contactData['num$contactIndex'] = contactNumbers[i];
      }
    }

    print('Parsed contact data: $contactData'); // Debug log
    return contactData;
  }

  bool _isPersonName(String value) {
    if (value.isEmpty) return false;

    // Skip technical terms and numbers
    if (_isPhoneNumber(value) ||
        value.toLowerCase().contains('node') ||
        value.toLowerCase().contains('meter') ||
        value.toLowerCase().contains('n/a') ||
        value.toLowerCase().contains('none') ||
        value.toLowerCase().contains('carrier') ||
        value.toLowerCase().contains('ethernet') ||
        value.toLowerCase().contains('aggregation') ||
        value.toLowerCase().contains('cea') ||
        RegExp(r'^\d+$').hasMatch(value.trim())) {
      return false;
    }

    // Look for patterns that suggest a person's name
    // Names typically have multiple words and contain letters
    if (value.length > 2 &&
        value.length < 50 &&
        RegExp(r'^[a-zA-Z\s\.]+$').hasMatch(value) &&
        value.split(' ').length >= 2) {
      return true;
    }

    return false;
  }

  bool _isPhoneNumber(String value) {
    // Check if the value looks like a phone number (contains digits and common phone patterns)
    if (value.length < 7) return false;

    // Remove common phone number characters
    String cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check if it contains mostly digits
    if (cleanValue.length >= 7 && RegExp(r'^\d{7,15}$').hasMatch(cleanValue)) {
      return true;
    }

    return false;
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
              dataRowMaxHeight: double.infinity,
              columns: [
                DataColumn(
                  label: Text('Parameter',
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
                  label: Text('Value',
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
                  label: Text('Status',
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
                  label: Text('Timestamp',
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
              rows: ceaDetails.map((data) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(data['PARAMETER'].toString(),
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
                      Text(data['VALUE'].toString(),
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
                      Text(data['STATUS'].toString(),
                          style: TextStyle(
                              fontSize: 0.037 *
                                  (MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? screenWidth
                                      : screenHeight),
                              fontWeight: FontWeight.w500,
                              color: data['STATUS'].toString().toLowerCase() ==
                                      'ok'
                                  ? Colors.green
                                  : Colors.red)),
                    ),
                    DataCell(
                      Text(data['TIMESTAMP'].toString(),
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

  Widget _buildText(String label, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 0.037 *
                      (MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenWidth
                          : screenHeight),
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 0.037 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight),
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0056A2)),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 80,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

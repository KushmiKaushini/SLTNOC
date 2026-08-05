import 'package:flutter/material.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:sltnoc/settings_button.dart';
import 'package:xml/xml.dart' as xml;
import 'fault_record_filter.dart';
import 'node_details.dart';

class NodeAlarmsPage extends StatefulWidget {
  final String alarmType;
  final String name;
  final String province;
  final String nodeType;

  const NodeAlarmsPage({
    super.key,
    required this.alarmType,
    required this.name,
    required this.province,
    required this.nodeType,
  });

  @override
  _NodeAlarmsPageState createState() => _NodeAlarmsPageState();
}

class _NodeAlarmsPageState extends State<NodeAlarmsPage> {
  List<Map<String, dynamic>> alarmDetails = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
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

      final response = await http.post(
        Uri.parse(soapEndpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '"http://tempuri.org/faults4"',
        },
        body: soapBody,
      );

      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.body);
        final resultNode = xmlDoc.findAllElements("faults4Result").first;
        final resultString = resultNode.innerText.trim();
        final details = <Map<String, dynamic>>[];

        if (resultString.isNotEmpty && resultString != 'NO ALARMS') {
          for (final entry in resultString.split(',')) {
            final parts = entry.split('::');
            if (parts.length >= 5) {
              if (isClosedFaultRecord(parts)) {
                continue;
              }

              final nodeName = parts[0].trim();
              final alarmType = parts[1].trim();
              final duration = parts[2].trim().split(' ')[0];
              final name = parts[3].trim();
              final platform = parts[4].trim();
              final ip = parts.length > 5 ? parts[5].trim() : '';
              final nodeType = _normalizeNodeType(platform, nodeName);

              if (nodeType == widget.nodeType.toUpperCase()) {
                details.add({
                  'NODE': nodeName,
                  'NW_ENG': name,
                  'PROVINCE': widget.province,
                  'FAULT': alarmType,
                  'DURATION': duration,
                  'PLATFORM': nodeType,
                  'IP': ip,
                });
              }
            }
          }
        }

        setState(() {
          alarmDetails = details;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load alarm details';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error: $error';
        isLoading = false;
      });
    }
  }

  String _normalizeNodeType(String platform, String nodeName) {
    final value = platform.trim().toUpperCase();
    final node = nodeName.trim().toUpperCase();

    if (value.contains('MSAN')) return 'MSAN';
    if (value.contains('OLT')) return 'OLT';
    if (value.contains('RNC')) return 'RNC';
    if (value.contains('BTS')) return 'BTS';
    if (value.contains('ENODEB')) return 'ENODEB';
    if (value.contains('NODEB')) return 'NODEB';
    if (value.contains('CEA')) return 'CEA';
    if (node.contains('MSAN')) return 'MSAN';
    if (node.contains('OLT')) return 'OLT';
    if (node.contains('RNC')) return 'RNC';
    if (node.contains('BTS')) return 'BTS';
    if (node.contains('ENODEB')) return 'ENODEB';
    if (node.contains('NODEB')) return 'NODEB';
    if (node.contains('CEA')) return 'CEA';
    if (value.isNotEmpty && value != 'N/A') {
      return value;
    }
    return 'OTHER';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.nodeType} Alarms',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00305e),
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70,
        actions: const [
          SettingsButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFixedText(),
            const SizedBox(height: 20),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              )
            else if (alarmDetails.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No alarms found for this node type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: styledDataTable(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Province:', widget.province),
        const SizedBox(height: 8),
        _buildText('Network:', widget.name),
        const SizedBox(height: 8),
        _buildText('Alarm Type:', widget.alarmType),
        const SizedBox(height: 8),
        _buildText('Node Type:', widget.nodeType),
      ],
    );
  }

  Widget _buildText(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0056A2)),
          ),
        ),
      ],
    );
  }

  Widget styledDataTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 16.0,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
            columns: const [
              DataColumn(
                  label: Text('Node',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
              DataColumn(
                  label: Text('Network',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
              DataColumn(
                  label: Text('Fault',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
              DataColumn(
                  label: Text('Duration',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
              DataColumn(
                  label: Text('IP',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
            ],
            rows: alarmDetails.map((alarm) {
              return DataRow(
                onSelectChanged: (bool? selected) {
                  if (selected != true) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NodeDetailsPage(
                        alarmType: widget.alarmType,
                        name: alarm['NW_ENG']?.toString() ?? widget.name,
                        province:
                            alarm['PROVINCE']?.toString() ?? widget.province,
                        nodeName: alarm['NODE']?.toString() ?? '',
                      ),
                    ),
                  );
                },
                cells: [
                  DataCell(Text(alarm['NODE']?.toString() ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF00305e)))),
                  DataCell(Text(alarm['NW_ENG']?.toString() ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF00305e)))),
                  DataCell(Text(alarm['FAULT']?.toString() ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF00305e)))),
                  DataCell(Text(
                      '${alarm['DURATION']?.toString() ?? 'N/A'} Hours',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF00305e)))),
                  DataCell(Text(alarm['IP']?.toString() ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF00305e)))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

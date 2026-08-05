import 'package:flutter/material.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:sltnoc/settings_button.dart';
import 'package:xml/xml.dart' as xml;
import 'fault_record_filter.dart';
import 'node_alarms.dart';

class NodeTypeSelectionPage extends StatefulWidget {
  final String alarmType;
  final String name;
  final String province;

  const NodeTypeSelectionPage({
    super.key,
    required this.alarmType,
    required this.name,
    required this.province,
  });

  @override
  _NodeTypeSelectionPageState createState() => _NodeTypeSelectionPageState();
}

class _NodeTypeSelectionPageState extends State<NodeTypeSelectionPage> {
  List<NodeTypeCount> nodeTypes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchNodeTypes();
  }

  Future<void> fetchNodeTypes() async {
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
        final counts = <String, int>{};

        if (resultString.isNotEmpty && resultString != 'NO ALARMS') {
          for (final entry in resultString.split(',')) {
            final parts = entry.split('::');
            if (parts.length >= 5) {
              if (isClosedFaultRecord(parts)) {
                continue;
              }

              final nodeName = parts[0].trim();
              final platform = parts[4].trim();
              final nodeType = _normalizeNodeType(platform, nodeName);
              if (nodeType.isNotEmpty) {
                counts[nodeType] = (counts[nodeType] ?? 0) + 1;
              }
            }
          }
        }

        setState(() {
          nodeTypes = _sortNodeTypes(counts);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load node types: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
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

  List<NodeTypeCount> _sortNodeTypes(Map<String, int> counts) {
    const preferredOrder = [
      'MSAN',
      'OLT',
      'RNC',
      'BTS',
      'NODEB',
      'ENODEB',
      'CEA',
      'OTHER',
    ];

    final sorted = counts.entries
        .map((entry) => NodeTypeCount(type: entry.key, count: entry.value))
        .toList()
      ..sort((a, b) {
        final aIndex = preferredOrder.indexOf(a.type);
        final bIndex = preferredOrder.indexOf(b.type);
        if (aIndex != -1 || bIndex != -1) {
          return (aIndex == -1 ? 999 : aIndex)
              .compareTo(bIndex == -1 ? 999 : bIndex);
        }
        return a.type.compareTo(b.type);
      });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Node Type',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
            else if (nodeTypes.isEmpty)
              const Center(
                child: Text(
                  'No node types available',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: nodeTypes.length,
                  itemBuilder: (context, index) {
                    return _buildNodeTypeButton(nodeTypes[index]);
                  },
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

  Widget _buildNodeTypeButton(NodeTypeCount nodeType) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NodeAlarmsPage(
              alarmType: widget.alarmType,
              name: widget.name,
              province: widget.province,
              nodeType: nodeType.type,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0056A2),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.router_sharp,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  nodeType.type,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nodeType.count.toString(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NodeTypeCount {
  final String type;
  final int count;

  const NodeTypeCount({
    required this.type,
    required this.count,
  });
}

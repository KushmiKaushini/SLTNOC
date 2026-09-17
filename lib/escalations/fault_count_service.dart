import 'package:flutter/foundation.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:sltnoc/escalations/manual_escalation_service.dart';
import 'package:sltnoc/service/notification_service.dart';

class FaultCountService {
  static String get _soapEndpoint => AppConfig.soapEndpoint;
  static final _manualEscalationService = const ManualEscalationService();

  static int _lastFaultCount = 0;
  static bool _isFirstCheck = true;

  /// Fetches the total count of faults (automatic + manual)
  static Future<int> fetchFaultCount() async {
    try {
      int automaticFaults = await _fetchAutomaticFaultCount();
      int manualFaults = await _fetchManualFaultCount();

      int totalFaults = automaticFaults + manualFaults;

      if (totalFaults == 0) {
        await NotificationService.cancelNotification();
        _lastFaultCount = 0;
        _isFirstCheck = false;
      } else if (_isFirstCheck) {
        await NotificationService.showFaultNotification(totalFaults,
            isSilent: false);
        _lastFaultCount = totalFaults;
        _isFirstCheck = false;
      } else if (totalFaults != _lastFaultCount) {
        if (totalFaults > _lastFaultCount) {
          await NotificationService.showFaultNotification(totalFaults,
              isSilent: false);
        } else {
          await NotificationService.showFaultNotification(totalFaults,
              isSilent: true);
        }
        _lastFaultCount = totalFaults;
      }

      return totalFaults;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching fault count: $e');
      }
      return 0;
    }
  }

  /// Fetches count of automatic faults from SOAP API
  static Future<int> _fetchAutomaticFaultCount() async {
    try {
      String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <getSelection2 xmlns="http://tempuri.org/">
              <selection>FAULTS</selection>
              <serviceno></serviceno>
            </getSelection2>
          </soap:Body>
        </soap:Envelope>''';

      final response = await http
          .post(
            Uri.parse(_soapEndpoint),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': 'http://tempuri.org/getSelection2',
            },
            body: soapBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var xmlDoc = xml.XmlDocument.parse(response.body);
        var resultNode = xmlDoc.findAllElements("getSelection2Result").first;
        var resultString = resultNode.innerText.trim();

        if (resultString.isEmpty) {
          return 0;
        }

        List<String> records = resultString.split(',');
        return records.where((r) => r.trim().isNotEmpty).length;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching automatic fault count: $e');
      }
      return 0;
    }
  }

  /// Fetches count of manual faults
  static Future<int> _fetchManualFaultCount() async {
    try {
      final manualItems = await _manualEscalationService.fetchActive();
      return manualItems
          .where((item) => item.escalationType == 'FAULTS')
          .length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching manual fault count: $e');
      }
      return 0;
    }
  }
}

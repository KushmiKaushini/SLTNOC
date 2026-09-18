import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sltnoc/escalations/manual_escalation_service.dart';
import 'package:sltnoc/escalations/manual_escalation_queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ManualEscalation Model & Queue Tests', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('ManualEscalation JSON serialization and deserialization', () {
      final escalation = ManualEscalation(
        id: 'esc-12345',
        escalationType: 'FAULTS',
        node: 'SLT-CORE-R01',
        platform: 'IP-RAN',
        severity: 'CRITICAL',
        tag: 'FIBER_CUT',
        description: 'Primary link severed at station A',
        startAt: DateTime(2026, 9, 18, 8, 30),
        reportingBy: 'NOC-OPERATOR-1',
        responsibleOfficer: 'ENGINEER-A',
        status: 'OPEN',
      );

      final json = escalation.toJson();
      expect(json['escalationType'], 'FAULTS');
      expect(json['node'], 'SLT-CORE-R01');
      expect(json['severity'], 'CRITICAL');
      expect(json['startAt'], '2026-09-18T08:30:00.000');

      final fromJson = ManualEscalation.fromJson({
        ...json,
        'id': 'esc-12345',
        'status': 'OPEN',
      });

      expect(fromJson.id, 'esc-12345');
      expect(fromJson.escalationType, 'FAULTS');
      expect(fromJson.node, 'SLT-CORE-R01');
      expect(fromJson.platform, 'IP-RAN');
      expect(fromJson.severity, 'CRITICAL');
      expect(fromJson.tag, 'FIBER_CUT');
      expect(fromJson.description, 'Primary link severed at station A');
      expect(fromJson.reportingBy, 'NOC-OPERATOR-1');
      expect(fromJson.responsibleOfficer, 'ENGINEER-A');
      expect(fromJson.status, 'OPEN');
    });

    test('ManualEscalationQueue saves and retrieves queued items from secure storage', () async {
      final queue = ManualEscalationQueue();

      // Initially empty
      final initialItems = await queue.loadQueue();
      expect(initialItems, isEmpty);

      final item1 = ManualEscalation(
        id: 'item-1',
        escalationType: 'FAULTS',
        node: 'NODE-01',
        platform: 'DWDM',
        severity: 'MAJOR',
        tag: 'POWER',
        description: 'Power fluctuation detected',
        startAt: DateTime.now(),
        reportingBy: 'USER-1',
        responsibleOfficer: 'OFFICER-1',
        status: 'OPEN',
      );

      await queue.addToQueue(item1);

      final updatedQueue = await queue.loadQueue();
      expect(updatedQueue.length, 1);
      expect(updatedQueue.first.node, 'NODE-01');
      expect(updatedQueue.first.severity, 'MAJOR');

      // Add a second item
      final item2 = ManualEscalation(
        id: 'item-2',
        escalationType: 'PROBLEMS',
        node: 'NODE-02',
        platform: 'IP',
        severity: 'MINOR',
        tag: 'INTERFACE',
        description: 'Interface packet drop',
        startAt: DateTime.now(),
        reportingBy: 'USER-2',
        responsibleOfficer: 'OFFICER-2',
        status: 'OPEN',
      );

      await queue.addToQueue(item2);

      final finalQueue = await queue.loadQueue();
      expect(finalQueue.length, 2);
      expect(finalQueue[0].node, 'NODE-01');
      expect(finalQueue[1].node, 'NODE-02');
    });
  });
}

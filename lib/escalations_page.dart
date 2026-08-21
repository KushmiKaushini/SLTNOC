// escalations_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/settings_button.dart';
import 'package:sltnoc/escalations/FAULTS/faults.dart';
import 'package:sltnoc/escalations/Planned Events/planned_events.dart';
import 'package:sltnoc/escalations/Problems/problems.dart';
import 'package:sltnoc/escalations/Common Issues/common_issues.dart';
import 'package:sltnoc/escalations/manual_escalation_service.dart';
import 'package:sltnoc/escalations/fault_count_service.dart';
import 'package:sltnoc/widgets/my_card.dart';

class EscalationsPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String newSubtitle;

  const EscalationsPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.newSubtitle,
  }) : super(key: key);

  @override
  State<EscalationsPage> createState() => _EscalationsPageState();
}

class _EscalationsPageState extends State<EscalationsPage> {
  int _faultCount = 0;
  late Future<int> _faultCountFuture;
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _faultCountFuture = FaultCountService.fetchFaultCount();
    // Refresh fault count every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateFaultCount();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _updateFaultCount() async {
    try {
      final count = await FaultCountService.fetchFaultCount();
      if (mounted) {
        setState(() {
          _faultCount = count;
        });
      }
    } catch (e) {
      print('Error updating fault count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: AppConfig.appBarTextStyle),
        centerTitle: true,
        backgroundColor: AppConfig.appBarBG,
        toolbarHeight: AppConfig.toolbarHeight,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          SettingsButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConfig.appBarBG,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('NEW ESCALATION'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManualEscalationFormPage(),
            ),
          );
        },
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FutureBuilder<int>(
                        future: _faultCountFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && !snapshot.hasError) {
                            _faultCount = snapshot.data ?? 0;
                          }
                          return MyCard.list(
                            title: 'FAULTS',
                            subtitle: 'Fault Escalation',
                            newSubtitle: 'Source: SLT NOC',
                            borderColor: Color(0xFF0056A2),
                            badgeCount: _faultCount,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const faultsPage(
                                            title: 'FAULTS',
                                          ))).then((_) {
                                // Refresh fault count when returning from faults page
                                _updateFaultCount();
                              });
                            },
                          );
                        },
                      ),
                      MyCard.list(
                        title: 'PLANNED EVENTS',
                        subtitle: 'Network Maintenance Activities',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const plannedEventsPage(
                                        title: 'PLANNED EVENTS',
                                      )));
                        },
                      ),
                      MyCard.list(
                        title: 'PROBLEMS',
                        subtitle: 'Network Related Problems',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const problemsPage(
                                        title: 'PROBLEMS',
                                      )));
                        },
                      ),
                      MyCard.list(
                        title: 'COMMON ISSUES',
                        subtitle: 'Common Issues',
                        newSubtitle: 'Source: SLT NOC',
                        borderColor: Color(0xFF0056A2),
                        badgeCount: 0,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const commonIssuesPage(
                                        title: 'COMMON ISSUES',
                                      )));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManualEscalationFormPage extends StatefulWidget {
  const ManualEscalationFormPage({Key? key}) : super(key: key);

  @override
  State<ManualEscalationFormPage> createState() =>
      _ManualEscalationFormPageState();
}

class _ManualEscalationFormPageState extends State<ManualEscalationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = const ManualEscalationService();
  final _nodeController = TextEditingController();
  final _platformController = TextEditingController();
  final _tagController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reportingByController = TextEditingController();
  final _responsibleOfficerController = TextEditingController();
  DateTime _startAt = DateTime.now();
  String _escalationType = 'FAULTS';
  String _severity = 'MAJOR';
  bool _isSaving = false;

  @override
  void dispose() {
    _nodeController.dispose();
    _platformController.dispose();
    _tagController.dispose();
    _descriptionController.dispose();
    _reportingByController.dispose();
    _responsibleOfficerController.dispose();
    super.dispose();
  }

  Future<void> _pickStartAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (time == null) return;

    setState(() {
      _startAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final escalation = ManualEscalation(
      id: '',
      escalationType: _escalationType,
      node: _nodeController.text.trim(),
      platform: _platformController.text.trim(),
      severity: _severity,
      tag: _tagController.text.trim(),
      description: _descriptionController.text.trim(),
      startAt: _startAt,
      reportingBy: _reportingByController.text.trim(),
      responsibleOfficer: _responsibleOfficerController.text.trim(),
      status: 'OPEN',
    );

    try {
      await _service.create(escalation);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manual escalation added')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatStartAt() {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${_startAt.year}-${two(_startAt.month)}-${two(_startAt.day)} '
        '${two(_startAt.hour)}:${two(_startAt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Escalation', style: AppConfig.appBarTextStyle),
        centerTitle: true,
        backgroundColor: AppConfig.appBarBG,
        toolbarHeight: AppConfig.toolbarHeight,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [SettingsButton()],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig.bodyBackgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConfig.tablePagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dropdownField(
                    label: 'Escalation Type',
                    value: _escalationType,
                    items: const [
                      'FAULTS',
                      'PLANNED EVENTS',
                      'PROBLEMS',
                      'COMMON ISSUES'
                    ],
                    onChanged: (value) =>
                        setState(() => _escalationType = value!),
                  ),
                  _textField('Node', _nodeController),
                  _textField('Platform', _platformController),
                  _dropdownField(
                    label: 'Severity',
                    value: _severity,
                    items: const [
                      'CRITICAL',
                      'MAJOR',
                      'MINOR',
                      'POWER',
                      'SECURITY'
                    ],
                    onChanged: (value) => setState(() => _severity = value!),
                  ),
                  _textField('Tag', _tagController, required: false),
                  _textField('Description', _descriptionController,
                      maxLines: 4),
                  _dateTimeField(),
                  _textField('Reporting By', _reportingByController),
                  _textField(
                      'Responsible Officer', _responsibleOfficerController),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.appBarBG,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'SUBMIT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: _inputDecoration(label),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _dateTimeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _pickStartAt,
        child: InputDecorator(
          decoration: _inputDecoration('Start At'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatStartAt(), style: const TextStyle(fontSize: 15)),
              const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF0056A2),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF475569),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.95),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0056A2), width: 2),
      ),
    );
  }
}

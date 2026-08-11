import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/services/credential_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _useLocalServer = true;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useLocalServer = prefs.getBool('useLocalServer') ?? true;
      _urlController.text = prefs.getString('serverUrl') ?? 'http://192.168.1.8:3000';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useLocalServer', _useLocalServer);
    await prefs.setString('serverUrl', _urlController.text.trim());

    Fluttertoast.showToast(
      msg: "Settings saved successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppConfig.appBarTextStyle),
        backgroundColor: AppConfig.appBarBG,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: AppConfig.toolbarHeight,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConfig.bodyBackgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.tablePagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Server Settings Card
              Card(
                elevation: AppConfig.elevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Connection Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00305e),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text(
                          'Use Local Dev Server (REST)',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Connects to the local Express backend'),
                        value: _useLocalServer,
                        activeColor: const Color(0xFF0056a2),
                        onChanged: (bool value) {
                          setState(() {
                            _useLocalServer = value;
                          });
                        },
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _urlController,
                        enabled: _useLocalServer,
                        decoration: InputDecoration(
                          labelText: 'Local Server URL',
                          hintText: 'http://192.168.1.x:3000',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Settings'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0056a2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Home Card
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade500),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home, size: 24, color: Colors.black),
                        const SizedBox(width: 20),
                        const Text(
                          'Home',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 20, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout Card
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('username');
                    await prefs.remove('password');
                    await prefs.remove('displayName');

                    Fluttertoast.showToast(
                      msg: "Logged out successfully!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 24, color: Colors.red),
                        const SizedBox(width: 20),
                        const Text(
                          'Logout',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 20, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Image.asset(
                  'assets/Logo2.png',
                  width: 100,
                ),
                const SizedBox(height: 32),
                Center(
                  child: Image.asset(
                    'assets/Logo2.png',
                    width: 100,
                  ),
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

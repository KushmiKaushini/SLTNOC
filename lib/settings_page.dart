import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:sltnoc/app_config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Settings', style: AppConfig.appBarTextStyle),
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
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.tablePagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        Icon(Icons.home, size: 24, color: Colors.black), // Home icon
                        const SizedBox(width: 20), // Add some spacing between the icon and the text
                        Text(
                          'Home',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.black), // Forward arrow icon
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                      MaterialPageRoute(builder: (context) => LoginPage()),
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
                        Icon(Icons.logout, size: 24, color: Colors.red), // Logout icon
                        const SizedBox(width: 20), // Add some spacing between the icon and the text
                        Text(
                          'Logout',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.red), // Forward arrow icon
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/Logo2.png',
                  width: 100,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '© 2024 SLT Mobitel | All Rights Reserved',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
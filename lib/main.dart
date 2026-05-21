import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';

const String loginPageRoute = '/login';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _requestLocationPermission(); // Request location permission when app starts

    // Set the status bar color to match your app's theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'My App',
      initialRoute: '/', // Set the initial route to '/'
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          primary: Colors.blueAccent, //<-- SEE HERE
        ),
      ),
      debugShowCheckedModeBanner: false,

      // Define the home page route and the login page route
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _checkLoginStatus(),
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while checking login status
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  // Navigate to LoginPage if not logged in, else navigate to HomePage
                  return snapshot.data == true
                      ? FutureBuilder<String?>(
                          future: _getDisplayName(), // Get the display name
                          builder: (context,
                              AsyncSnapshot<String?> displayNameSnapshot) {
                            if (displayNameSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Show a loading indicator while getting the display name
                              return Scaffold(
                                body: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else {
                              return MyHomePage(
                                  displayName: displayNameSnapshot.data ?? '');
                            }
                          },
                        )
                      : const LoginPage();
                }
              },
            ),
        loginPageRoute: (context) => const LoginPage(),
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    return username != null && password != null;
  }

  // Function to get the display name from shared preferences
  Future<String?> _getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('displayName');
  }

  static Future<void> _requestLocationPermission() async {
    // Request location permission
    final PermissionStatus status =
        await Permission.locationWhenInUse.request();
    if (status != PermissionStatus.granted) {
      // Handle denied or restricted permissions
      // You can show a dialog or message to inform the user about the importance of location permissions
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'home_page.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   bool isPasswordVisible = false;
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             width: screenWidth < 600 ? double.infinity : 400, // Set a maximum width
//             padding: const EdgeInsets.all(26.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Image
//                 Image.asset(
//                   'assets/Logo2.png', // Replace with the path to your Logo2 image
//                   width: screenWidth < 600 ? screenWidth * 0.5 : 200, // Adjust logo width
//                 ),
//                 const SizedBox(height: 10),
//                 // New Welcome message
//                 const Text(
//                   'Login to your account',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 25,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 // Login form
//                 _buildTextField('Username', 'Enter your 6 Digit SLT Service Number'),
//                 const SizedBox(height: 20),
//                 _buildTextField('Password', 'Enter your password', isPassword: true),
//                 const SizedBox(height: 40),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Navigate to the home page after successful login
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => const MyHomePage()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF4272D7), // BG color
//                     foregroundColor: Colors.white, // Font color
//                     textStyle: const TextStyle(
//                       fontWeight: FontWeight.w500, // Font weight
//                       fontSize: 20.0, // Font size
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0), // Button border radius
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth < 600 ? screenWidth * 0.2 : 60, // Adjust button width
//                       vertical: 12.0, // Suitable padding
//                     ),
//                   ),
//                   child: const Text('Login'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(String label, String placeholder, {bool isPassword = false}) {
//     TextEditingController controller = isPassword ? passwordController : usernameController;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           obscureText: isPassword && !isPasswordVisible,
//           controller: controller,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             hintText: placeholder,
//             suffixIcon: isPassword
//                 ? IconButton(
//               icon: Icon(
//                 isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                 color: Colors.grey,
//               ),
//               onPressed: () {
//                 // Toggle password visibility
//                 setState(() {
//                   isPasswordVisible = !isPasswordVisible;
//                 });
//               },
//             )
//                 : null,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sltnoc/services/credential_store.dart';

// Dev-mode quick-login button is only ever shown in debug builds (kDebugMode
// is a compile-time constant baked in by Flutter's build tooling, so this is
// structurally impossible to enable in a release build -- unlike the old
// manually-toggled boolean it replaced).
const String _DEV_USERNAME = 'testuser';
const String _DEV_PASSWORD = 'dev-password';
const String _DEV_DISPLAY_NAME = 'Test User';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool _showErrorMessage = false;
  bool _loading = false;
  bool _loginChecked =
      false; // Add this variable to track if login status has been checked

  @override
  void initState() {
    super.initState();
    if (!_loginChecked) {
      // Only check login status if it hasn't been checked before
      _checkLoginStatus();
      _loginChecked = true;
    }
  }

  Future<void> _checkLoginStatus() async {
    final username = await CredentialStore.getUsername();
    final password = await CredentialStore.getPassword();
    if (username != null && password != null) {
      await _login(username, password);
    }
  }

  // Dev mode login - bypasses SOAP validation. Only reachable when kDebugMode
  // is true (see the build() method below), so this can never run in a
  // release build regardless of any runtime state.
  Future<void> _devLogin() async {
    print('🔓 DEV LOGIN: Initiating dev login bypass...');
    setState(() {
      _loading = true;
      _showErrorMessage = false;
    });

    await CredentialStore.saveCredentials(
      username: _DEV_USERNAME,
      password: _DEV_PASSWORD,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', _DEV_DISPLAY_NAME);

    print('✅ DEV LOGIN: Credentials stored');
    print('   Username: $_DEV_USERNAME');
    print('   Display Name: $_DEV_DISPLAY_NAME');

    if (!mounted) return;

    print('🚀 DEV LOGIN: Navigating to home page...');
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  Future<void> _login(String username, String password) async {
    setState(() {
      _loading = true;
    });

    // Construct the SOAP request body for login validation
    const String loginUrl = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
    String loginRequestBody = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <login2 xmlns="http://tempuri.org/">
        <username>$username</username>
        <password>$password</password>
      </login2>
    </soap:Body>
  </soap:Envelope>''';

    // Make the HTTP POST request for login validation
    http.Response loginResponse = await http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/login2',
      },
      body: loginRequestBody,
    );

    // Parse the login response
    String loginResponseBody = loginResponse.body;
    if (loginResponseBody.contains('TRUE')) {
      print('Login successful: Default User');
      await CredentialStore.saveCredentials(
        username: username,
        password: password,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Extract user name using the second SOAP request
      const String displayNameUrl = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
      String displayNameRequestBody = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <GetDisplayname xmlns="http://tempuri.org/">
          <svcno>$username</svcno>
          <password>$password</password>
        </GetDisplayname>
      </soap:Body>
    </soap:Envelope>''';

      // Make the HTTP POST request for getting display name
      http.Response displayNameResponse = await http.post(
        Uri.parse(displayNameUrl),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://tempuri.org/GetDisplayname',
        },
        body: displayNameRequestBody,
      );

      // Parse the display name response
      String displayNameResponseBody = displayNameResponse.body;
      String displayName = '';
      if (displayNameResponseBody.contains('<GetDisplaynameResult>')) {
        displayName = displayNameResponseBody
            .split('<GetDisplaynameResult>')[1]
            .split('</GetDisplaynameResult>')[0];
      }

      // Check if the display name response indicates incorrect username or password
      if (displayNameResponseBody
          .contains('The user name or password is incorrect.')) {
        displayName = 'Default User';
      }
      prefs.setString('displayName', displayName);
      // Navigate to the home page after successful login
      // Navigator.pushReplacementNamed(context, '/');

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false, // Removes all routes in the stack
      );
    } else if (loginResponseBody.contains('FALSE')) {
      print('Invalid credentials');
      setState(() {
        _showErrorMessage = true;
      });
      // Handle invalid credentials here
    } else {
      print('Unexpected response: $loginResponseBody');
      // Handle unexpected response here
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _handleLogin() async {
    String username = usernameController.text;
    String password = passwordController.text;
    await _login(username, password);
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth < 600
                ? double.infinity
                : 400, // Set a maximum width
            padding: const EdgeInsets.all(26.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image
                Image.asset(
                  'assets/Logo2.png', // Replace with the path to your Logo2 image
                  width: screenWidth < 600
                      ? screenWidth * 0.5
                      : 200, // Adjust logo width
                ),
                const SizedBox(height: 10),
                // New Welcome message
                const Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 10),
                if (_showErrorMessage)
                  Text(
                    'Invalid Credentials',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                const SizedBox(height: 20),
                // Login form
                _buildTextField(
                    'Username', 'Enter your 6 Digit SLT Service Number'),
                const SizedBox(height: 20),
                _buildTextField('Password', 'Enter your password',
                    isPassword: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4272D7), // BG color
                    foregroundColor: Colors.white, // Font color
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500, // Font weight
                      fontSize: 20.0, // Font size
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Button border radius
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 600
                          ? screenWidth * 0.2
                          : 60, // Adjust button width
                      vertical: 12.0, // Suitable padding
                    ),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(
                    height:
                        20), // Add space between button and loading indicator
                if (_loading) // Show loading indicator only if loading is true
                  CircularProgressIndicator(),
                if (kDebugMode) ...[
                  const SizedBox(height: 30),
                  Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Dev Mode',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loading ? null : _devLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 600 ? screenWidth * 0.2 : 50,
                        vertical: 10.0,
                      ),
                    ),
                    child: const Text('Quick Dev Login'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder,
      {bool isPassword = false}) {
    TextEditingController controller =
        isPassword ? passwordController : usernameController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: isPassword && !isPasswordVisible,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: placeholder,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // Toggle password visibility
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

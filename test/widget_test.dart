import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sltnoc/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LoginPage renders input fields and submit button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    // Initial pump and settle
    await tester.pumpAndSettle();

    // Verify title/welcome text
    expect(find.text('Login to your account'), findsOneWidget);

    // Verify presence of Username and Password text fields
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify login button
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}

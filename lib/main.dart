import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sltnoc/secure_storage_service.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'service/notification_service.dart';
import 'draggable_chat_button.dart';
import 'shared_state.dart';
import 'package:sltnoc/escalations/manual_escalation_queue.dart';

const String loginPageRoute = '/login';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Migrate any legacy plaintext credentials from SharedPreferences to SecureStorage
  await SecureStorageService().migrateFromSharedPreferences();

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // Global navigator key so the floating button can navigate from any context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Route observer so overlays can react to navigation events
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _queueProcessorTimer;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    WidgetsBinding.instance.addObserver(this);
    _startQueueProcessorTimer();
    // Process any queued escalations on app start
    _processQueueOnResume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _queueProcessorTimer?.cancel();
    super.dispose();
  }

  void _startQueueProcessorTimer() {
    // Process queue every 30 seconds while app is active
    _queueProcessorTimer ??= Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final int sent = await ManualEscalationQueue().processQueue();
        if (kDebugMode && sent > 0) {
          print('Processed $sent queued escalations');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error processing queue: $e');
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App resumed, process queue immediately
      _processQueueOnResume();
    }
    // Optionally, you could pause/resume timer based on state, but we keep timer running.
  }

  Future<void> _processQueueOnResume() async {
    try {
      final int sent = await ManualEscalationQueue().processQueue();
      if (kDebugMode && sent > 0) {
        print('Processed $sent queued escalations on resume');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing queue on resume: $e');
      }
    }
  }

  Future<bool> _checkLoginStatus() async {
    final storage = SecureStorageService();
    return await storage.hasValidCredentials();
  }

  // Function to get the display name from secure storage
  Future<String?> _getDisplayName() async {
    final storage = SecureStorageService();
    return await storage.getDisplayName();
  }

  static Future<void> _requestLocationPermission() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    // Request location permission
    final PermissionStatus status =
        await Permission.locationWhenInUse.request();
    if (status != PermissionStatus.granted) {
      // Handle denied or restricted permissions
    }
  }

  @override
  Widget build(BuildContext context) {
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
      navigatorKey: MyApp.navigatorKey,
      navigatorObservers: [MyApp.routeObserver],
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          primary: Colors.blueAccent,
        ),
      ),
      debugShowCheckedModeBanner: false,

      // Wrap the entire app with an overlay for the draggable chat button
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Draggable floating chatbot button — visible on all screens
            const _ChatButtonOverlay(),
          ],
        );
      },

      // Define the home page route and the login page route
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _checkLoginStatus(),
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while checking login status
                  return const Scaffold(
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
                              return const Scaffold(
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
}

class _ChatButtonOverlay extends StatefulWidget {
  const _ChatButtonOverlay({Key? key}) : super(key: key);

  @override
  State<_ChatButtonOverlay> createState() => _ChatButtonOverlayState();
}

class _ChatButtonOverlayState extends State<_ChatButtonOverlay>
    with RouteAware {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes so we re-check login whenever user navigates
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void>) {
      MyApp.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when a new route is pushed on top of this one
  @override
  void didPushNext() => _checkLogin();

  // Called when the route on top is popped (e.g. user returns from login)
  @override
  void didPopNext() => _checkLogin();

  Future<void> _checkLogin() async {
    final storage = SecureStorageService();
    final isValid = await storage.hasValidCredentials();
    if (mounted) {
      setState(() {
        _isLoggedIn = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) return const SizedBox.shrink();

    // Also listen to the global chat screen flag to hide button when chat is open
    return ValueListenableBuilder<bool>(
      valueListenable: isChatScreenOpen,
      builder: (context, isChatOpen, child) {
        if (isChatOpen) return const SizedBox.shrink();
        return const DraggableChatButton();
      },
    );
  }
}
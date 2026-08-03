import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showFaultNotification(int faultCount,
      {required bool isSilent}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      isSilent ? 'slt_noc_silent_channel' : 'slt_noc_loud_channel',
      isSilent ? 'Silent Updates' : 'Fault Escalations',
      channelDescription: 'Notifications for SLT NOC faults',
      importance: isSilent ? Importance.low : Importance.max,
      priority: isSilent ? Priority.low : Priority.high,
      playSound: !isSilent,
      silent: isSilent,
      number: faultCount,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin.show(
      0,
      'SLT NOC Update',
      'You have $faultCount active faults.',
      notificationDetails,
    );
  }

  static Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }
}

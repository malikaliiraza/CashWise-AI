// CashWise AI — local notifications (v4.8).
//
// Budget alerts (80% warning, 100% overspend) are shown as an
// in-app banner AND as a mobile notification, when the app runs on
// a phone. On the web build there is no mobile notification
// channel, so init() simply does nothing there and only the banner
// shows. Everything is guarded: if notifications cannot start, the
// app keeps working without them.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      const android =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        const InitializationSettings(android: android),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Loan Ledger due reminder: an overdue payment, or one due
  /// tomorrow. Same channel as the budget alerts; on the web
  /// build there is no channel, so this simply does nothing and
  /// only the in-app banner shows.
  static Future<void> showDueReminder(String body) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        2,
        'Hisaab Kitaab',
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'cashwise_alerts',
            'Budget alerts',
            channelDescription:
                'Payment due reminders for the Loan Ledger.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (_) {
      // Notifications are a bonus, never a crash.
    }
  }

  static Future<void> showBudgetAlert(String body) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        1,
        'Hisaab Kitaab',
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'cashwise_alerts',
            'Budget alerts',
            channelDescription:
                'Alerts when your budget is almost finished or overspent.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (_) {
      // Notifications are a bonus, never a crash.
    }
  }
}

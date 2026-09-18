import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reminder {
  int id;
  String title;
  String body;
  String repeat;
  int weekday;
  int hour;
  int minute;
  bool on;
  bool vibrate;
  bool useAlarmSound;

  Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.repeat,
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.on,
    this.vibrate = true,
    this.useAlarmSound = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'repeat': repeat,
        'weekday': weekday,
        'hour': hour,
        'minute': minute,
        'on': on,
        'vibrate': vibrate,
        'useAlarmSound': useAlarmSound,
      };

  static Reminder fromJson(Map<String, dynamic> m) => Reminder(
        id: m['id'] ?? 0,
        title: m['title'] ?? '',
        body: m['body'] ?? '',
        repeat: m['repeat'] ?? 'daily',
        weekday: m['weekday'] ?? 1,
        hour: m['hour'] ?? 9,
        minute: m['minute'] ?? 0,
        on: m['on'] ?? true,
        vibrate: m['vibrate'] ?? true,
        useAlarmSound: m['useAlarmSound'] ?? true,
      );
}

class NotificationService {
  static bool _initialized = false;

  // Called once at app start
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await AwesomeNotifications().initialize(
        // small icon (optional, system uses app icon by default)
        'resource://mipmap/ic_launcher',
        [
          NotificationChannel(
            channelKey: 'khetha_alarm',
            channelName: 'Khetha Alarms',
            channelDescription: 'Career reminders with alarm sound',
            defaultColor: const Color(0xFF00695C),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            defaultRingtoneType: DefaultRingtoneType.Alarm,
            enableVibration: true,
            enableLights: true,
            criticalAlerts: true,
          ),
          NotificationChannel(
            channelKey: 'khetha_default',
            channelName: 'Khetha Notifications',
            channelDescription: 'General Khetha notifications',
            defaultColor: const Color(0xFF00695C),
            importance: NotificationImportance.High,
          ),
        ],
      );

      // Listen to actions (dismiss / snooze / tap)
            AwesomeNotifications().setListeners(
        onActionReceivedMethod: _onActionReceived,
        onDismissActionReceivedMethod: _onDismissed,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  // Ask permissions (Android 13+)
  static Future<bool> requestPermission() async {
    await init();
    final allowed =
        await AwesomeNotifications().requestPermissionToSendNotifications();
    return allowed ?? false;
  }

  static Future<void> showNow({
    required String title,
    required String body,
  }) async {
    await init();
    await requestPermission();
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'khetha_alarm',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          payload: {'type': 'test'},
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            actionType: ActionType.DismissAction,
            isDangerousOption: true,
          ),
        ],
      );
    } catch (e) {
      debugPrint('Show now failed: $e');
    }
  }

  static Future<void> schedule(Reminder r) async {
    await init();
    await requestPermission();
    try {
      await AwesomeNotifications().cancel(r.id);
      if (!r.on) return;

      final now = DateTime.now();
      var target = DateTime(
          now.year, now.month, now.day, r.hour, r.minute, 0, 0, 0);

      if (r.repeat == 'weekly') {
        while (target.weekday != r.weekday || target.isBefore(now)) {
          target = target.add(const Duration(days: 1));
        }
      } else {
        if (target.isBefore(now)) {
          target = target.add(const Duration(days: 1));
        }
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: r.id,
          channelKey: 'khetha_alarm',
          title: r.title,
          body: r.body,
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          payload: {
            'type': 'reminder',
            'id': r.id.toString(),
            'repeat': r.repeat,
            'hour': r.hour.toString(),
            'minute': r.minute.toString(),
          },
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            actionType: ActionType.DismissAction,
            isDangerousOption: true,
          ),
          NotificationActionButton(
            key: 'SNOOZE_5',
            label: 'Snooze 5 min',
            actionType: ActionType.SilentAction,
            autoDismissible: true,
          ),
        ],
        schedule: NotificationCalendar(
          year: target.year,
          month: target.month,
          day: target.day,
          hour: target.hour,
          minute: target.minute,
          second: 0,
          repeats: true,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
    } catch (e) {
      debugPrint('Schedule failed: $e');
    }
  }

  static Future<void> cancel(int id) async {
    await init();
    try {
      await AwesomeNotifications().cancel(id);
    } catch (_) {}
  }

  // ---------- ACTION LISTENERS ----------
  static Future<void> _onActionReceived(ReceivedAction action) async {
    if (action.buttonKeyPressed == 'SNOOZE_5') {
      final now = DateTime.now().add(const Duration(minutes: 5));
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: action.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'khetha_alarm',
          title: action.title ?? 'Snoozed reminder',
          body: action.body ?? '',
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
        ),
        schedule: NotificationCalendar(
          hour: now.hour,
          minute: now.minute,
          second: 0,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
    }
    // DISMISS just closes the notification.
  }

  

 

  static Future<void> _onDismissed(ReceivedAction action) async {
    debugPrint('Notification dismissed: ${action.id}');
  }

  // ---------- PERSISTENCE ----------
  static const _key = 'khetha_reminders';

  static Future<List<Reminder>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      final defaults = _seedDefaults();
      await saveAll(defaults);
      return defaults;
    }
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Reminder.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return _seedDefaults();
    }
  }

  static Future<void> saveAll(List<Reminder> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(list.map((r) => r.toJson()).toList()));
  }

  static List<Reminder> _seedDefaults() => [
        Reminder(
          id: 1001,
          title: 'Career quiz reminder',
          body: "Have you completed your career quiz yet? Tap to continue.",
          repeat: 'daily',
          weekday: 1,
          hour: 9,
          minute: 0,
          on: false,
        ),
        Reminder(
          id: 1002,
          title: 'Explore a new career',
          body: 'Discover a career you have not seen yet.',
          repeat: 'weekly',
          weekday: 7,
          hour: 10,
          minute: 0,
          on: false,
        ),
        Reminder(
          id: 1003,
          title: 'Important deadlines',
          body: 'Check university and NSFAS application dates.',
          repeat: 'daily',
          weekday: 1,
          hour: 12,
          minute: 0,
          on: false,
        ),
      ];
}
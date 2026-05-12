import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../models/items.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();



  Future<void> init() async {
    tz.initializeTimeZones();
    final String deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTimeZone));

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // طلب إذن iOS
    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }



  Future<({Duration duration, String label})> _getNotifyConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final unit  = prefs.getString('notify_unit')  ?? 'days';
    final value = prefs.getInt('notify_value')    ?? 3;

    final Duration duration =
    unit == 'months' ? Duration(days: value * 30) : Duration(days: value);

    final String label = unit == 'months'
        ? (value == 1 ? '1 month' : '$value months')
        : (value == 1 ? '1 day'   : '$value days');

    return (duration: duration, label: label);
  }



  Future<void> scheduleItemNotification(Item item) async {
    final prefs   = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    if (!enabled) return;

    if (item.daysLeft < 0) {
      debugPrint('⏭ Skipping "${item.name}" — already expired');
      return;
    }

    await _cancelSingle(item.id);

    final config = await _getNotifyConfig();
    final now    = tz.TZDateTime.now(tz.local);

    await _scheduleOne(item, config.duration, config.label, now);
  }

  Future<void> rescheduleAll(List<Item> items) async {
    final prefs   = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;

    await _plugin.cancelAll();

    if (!enabled) {
      debugPrint('🔕 Notifications disabled — skipping reschedule');
      return;
    }

    final config = await _getNotifyConfig();
    final now    = tz.TZDateTime.now(tz.local);

    int scheduled = 0;
    for (final item in items) {
      if (item.daysLeft < 0) continue;
      await _scheduleOne(item, config.duration, config.label, now);
      scheduled++;
    }

    debugPrint(
      '🔄 Rescheduled $scheduled / ${items.length} items '
          '(${items.where((i) => i.daysLeft < 0).length} expired skipped)',
    );
  }

  Future<void> setNotificationsEnabled(bool enabled, List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      await rescheduleAll(items);
    } else {
      await _plugin.cancelAll();
      debugPrint('🔕 All notifications cancelled');
    }
  }

  Future<void> cancelItemNotification(int itemId) async {
    await _cancelSingle(itemId);
  }

  /// إلغاء كل الـ notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> sendTestNotification() async {
    debugPrint('🧪 sendTestNotification called');

    try {
      await _plugin.show(
        999999,
        '✅🫡 Expiro — Instant Test',
        'لو شفت الرسالة دي، الـ plugin شغال تمام!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'expiry_channel',
            'Expiry Notifications',
            channelDescription: 'Notifications for items expiring soon',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
      debugPrint('✅ _plugin.show() succeeded');
    } catch (e) {
      debugPrint('❌ _plugin.show() FAILED: $e');
    }

    try {
      final pending = await _plugin.pendingNotificationRequests();
      debugPrint('📋 Pending notifications count: ${pending.length}');
      for (final n in pending) {
        debugPrint('   → id=${n.id} title="${n.title}"');
      }
    } catch (e) {
      debugPrint('❌ pendingNotificationRequests FAILED: $e');
    }

    debugPrint('🕐 tz.local = ${tz.local.name}');
    debugPrint('🕐 now = ${tz.TZDateTime.now(tz.local)}');
  }

  Future<void> sendScheduledTestNotification() async {
    final tz.TZDateTime tenSecondsLater =
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    debugPrint('🧪 Scheduling test for: $tenSecondsLater');

    try {
      await _plugin.zonedSchedule(
        999998,
        '⏰ Expiro — Scheduled Test',
        'الـ scheduled notifications شغالة تمام!',
        tenSecondsLater,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'expiry_channel',
            'Expiry Notifications',
            channelDescription: 'Notifications for items expiring soon',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ zonedSchedule() succeeded → check in 10 seconds');

      final pending = await _plugin.pendingNotificationRequests();
      debugPrint('📋 Pending after schedule: ${pending.length}');
    } catch (e) {
      debugPrint('❌ zonedSchedule() FAILED: $e');
    }
  }



  Future<void> _cancelSingle(int itemId) async {
    await _plugin.cancel(itemId);           // reminder
    await _plugin.cancel(itemId + 10000);   // expiry-day
  }

  Future<void> _scheduleOne(
      Item item,
      Duration notifyDuration,
      String notifyLabel,
      tz.TZDateTime now,
      ) async {
    final DateTime reminderDateTime = DateTime(
      item.expiryDate.year,
      item.expiryDate.month,
      item.expiryDate.day,
      9, 0, 0,
    ).subtract(notifyDuration);

    final tz.TZDateTime reminderTZ =
    tz.TZDateTime.from(reminderDateTime, tz.local);

    if (reminderTZ.isAfter(now)) {
      await _plugin.zonedSchedule(
        item.id,
        '⏰  ${item.name}',
        'Expiring in $notifyLabel  •  ${item.type.label}',
        reminderTZ,
        _buildDetails(
          item:      item,
          isUrgent:  false,
          body:      'Expiring in $notifyLabel  •  ${item.type.label}',
          summary:   'Tap to review before it\'s too late.',
          ticker:    '${item.name} expiring in $notifyLabel',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ Reminder scheduled → ${reminderTZ.toLocal()}');

    } else if (item.daysLeft >= 0) {
      final int    days   = item.daysLeft;
      final String when   = days == 0 ? 'TODAY' : days == 1 ? 'TOMORROW' : 'in $days days';
      final String body   = 'Expires $when  •  ${item.type.label}';

      await _plugin.show(
        item.id,
        days == 0 ? '🚨  ${item.name}' : '⚠️  ${item.name}',
        body,
        _buildDetails(
          item:     item,
          isUrgent: days <= 1,
          body:     body,
          summary:  days == 0
              ? 'Last chance — act now before it expires!'
              : 'Don\'t wait — check it before it\'s too late.',
          ticker:   '${item.name} expires $when',
        ),
      );
      debugPrint('🔔 Immediate notification → expires $when');
    }

    final tz.TZDateTime expiryDayTZ = tz.TZDateTime.from(
      DateTime(
        item.expiryDate.year,
        item.expiryDate.month,
        item.expiryDate.day,
        9, 0, 0,
      ),
      tz.local,
    );

    if (expiryDayTZ.isAfter(now)) {
      await _plugin.zonedSchedule(
        item.id + 10000,
        '🚨  ${item.name}',
        'Expires TODAY  •  ${item.type.label}',
        expiryDayTZ,
        _buildDetails(
          item:     item,
          isUrgent: true,
          body:     'Expires TODAY  •  ${item.type.label}',
          summary:  'Last chance — open Expiro and take action now.',
          ticker:   '${item.name} expires TODAY',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ Expiry-day scheduled → ${expiryDayTZ.toLocal()}');
    }
  }



  NotificationDetails _buildDetails({
    required Item   item,
    required bool   isUrgent,
    required String body,
    required String summary,
    required String ticker,
  }) {

    const int _teal   = 0xFF3ECFCF; // AppColors.teal
    const int _red    = 0xFFE53935; // AppColors.red
    const int _orange = 0xFFFF7043; // AppColors.orange

    final int accentColor = isUrgent
        ? _red
        : item.daysLeft <= 3
        ? _orange
        : _teal;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        isUrgent ? 'expiry_urgent' : 'expiry_channel',
        isUrgent ? 'Urgent Expiry Alerts' : 'Expiry Notifications',
        channelDescription: isUrgent
            ? 'Critical alerts for items expiring today'
            : 'Reminders for items expiring soon',

        importance: isUrgent ? Importance.max    : Importance.high,
        priority:   isUrgent ? Priority.max      : Priority.high,

        icon:  '@mipmap/ic_launcher',
        color: Color(accentColor),

        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),

        styleInformation: BigTextStyleInformation(
          '${item.type.label}  |  ${_formatExpiry(item)}\n\n$summary',
          contentTitle: isUrgent
              ? '<b>${item.name}</b> — Act Now!'
              : '<b>${item.name}</b> — Coming Up',
          summaryText: 'Expiro  •  Expiry Tracker',
          htmlFormatContentTitle: true,
        ),

        subText: isUrgent ? '🚨 Urgent Alert' : '⏰ Expiry Reminder',

        ticker: ticker,


        enableLights:  true,
        ledColor:      Color(accentColor),
        ledOnMs:       500,
        ledOffMs:      1000,

        playSound:         true,
        enableVibration:   true,
        vibrationPattern:  isUrgent
            ? Int64List.fromList([0, 300, 200, 300, 200, 600])
            : Int64List.fromList([0, 200, 100, 200]),

        channelShowBadge:    true,
        visibility:          NotificationVisibility.public,


        actions: [
          AndroidNotificationAction(
            'open_app',
            'Open Expiro',
            showsUserInterface: true,
          ),
        ],
      ),

      iOS: DarwinNotificationDetails(
        presentAlert:  true,
        presentBadge:  true,
        presentSound:  true,
        subtitle:      item.type.label,
        threadIdentifier: 'expiro_expiry',
      ),
    );
  }

  String _formatExpiry(Item item) {
    final d = item.expiryDate;
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
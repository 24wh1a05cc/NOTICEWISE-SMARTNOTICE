import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noticewise/core/utils/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton wrapper around [FlutterLocalNotificationsPlugin].
///
/// - Call [init] once in main() before [runApp].
/// - Call [scheduleNotice] to schedule a notice reminder.
/// - Call [cancelNotice] to cancel a scheduled notice reminder.
/// - Notification permission is requested during [init]; denied permission
///   is handled gracefully — the app remains fully functional without it.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialised = false;

  static const _channelId = 'noticewise_reminders';
  static const _channelName = 'Notice Reminders';
  static const _channelDesc = 'Scheduled reminders for notices';

  /// Initialises the notifications plugin and timezone data.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> init() async {
    if (_initialised) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request Android 13+ notification permission.
    try {
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      logger.i('[Notifications] Permission granted: $granted');
    } catch (e) {
      logger.w('[Notifications] Permission request failed: $e');
    }

    _initialised = true;
    logger.i('[Notifications] Initialised.');
  }

  void _onNotificationTap(NotificationResponse response) {
    // Deep-link handling can be added here in a future spec.
    logger.i('[Notifications] Tapped: ${response.payload}');
  }

  /// Schedules a notification for [noticeId] at [remindAt].
  ///
  /// If [remindAt] is in the past, the notification fires immediately.
  /// If permission was denied, this is a no-op and logs a warning.
  Future<void> scheduleNotice({
    required String noticeId,
    required String title,
    required String body,
    required DateTime remindAt,
  }) async {
    if (!_initialised) await init();

    final id = noticeId.hashCode.abs() % 100000;
    final scheduled = tz.TZDateTime.from(remindAt, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: noticeId,
      );
      logger.i('[Notifications] Scheduled notice $noticeId at $remindAt');
    } catch (e) {
      logger.w('[Notifications] Failed to schedule notice $noticeId: $e');
    }
  }

  /// Cancels any scheduled notification for [noticeId].
  Future<void> cancelNotice(String noticeId) async {
    final id = noticeId.hashCode.abs() % 100000;
    await _plugin.cancel(id);
    logger.i('[Notifications] Cancelled notice $noticeId');
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

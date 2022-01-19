import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import 'utils.dart';

class NotificationController {
  static final _notification = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future notificationDetails() async {
    final largeIconPath = await Utils.downloadImage(
        'https://images.unsplash.com/photo-1642518196560-b1feadbce7b9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1171&q=80',
        'largeIcon');
    final bigIconPath = await Utils.downloadImage(
        'https://images.unsplash.com/photo-1642518196560-b1feadbce7b9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1171&q=80',
        'smallIcon');
    final styleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigIconPath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
    );

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: styleInformation,
      ),
      iOS: const IOSNotificationDetails(),
    );
  }

  static Future init({bool initSchedule = false}) async {
    tz.initializeTimeZones();
    const settingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settingsIOS = IOSInitializationSettings();

    const initializationSettings = InitializationSettings(android: settingsAndroid, iOS: settingsIOS);

    await _notification.initialize(
      initializationSettings,
      onSelectNotification: (payload) async => onNotification.add(payload),
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notification.show(
        id,
        title,
        body,
        await notificationDetails(),
        payload: payload,
      );

  static Future showScheduleNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async =>
      _notification.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        await notificationDetails(),
        payload: payload,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
}

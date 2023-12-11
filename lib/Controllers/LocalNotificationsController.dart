import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/standalone.dart' as tz;

class LocalNotificationsController {
  static FlutterLocalNotificationsPlugin fLNP =
      FlutterLocalNotificationsPlugin();

  static init() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_onesignal_default');
    DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    await fLNP.initialize(initializationSettings);

    tzl.initializeTimeZones();
  }

  static NotificationDetails notificationDetails() {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Reminders',
      'Reminders',
      groupKey: 'com.northstar.fitness.reminders',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      autoCancel: true,
    );

    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      threadIdentifier: "Reminders",
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }



  static Future showLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final platformChannelSpecifics = notificationDetails();
    /*await fLNP.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: '',
    );*/

    await fLNP.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
          scheduledDate,
          tz.getLocation('Asia/Colombo')
      ),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  static Future cancelNotification(int id) async {
    await fLNP.cancel(id);
  }

  static Future getActive() async {
    List<ActiveNotification> active = await fLNP.getActiveNotifications();
    print(active);
  }

  static Future<void> showNonRemovableNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'ongoing_call_channel_id',
      'Ongoing Call',
      channelDescription: 'Notification for ongoing call',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: false,
      color: Colors.green,
      colorized:true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await fLNP.show(
      0, // Notification ID
      'Your Notification Title',
      'Your Notification Body',
      platformChannelSpecifics,
      payload: 'Ongoing Call Payload',
    );
  }
}

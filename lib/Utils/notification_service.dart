import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/FirebaseMessageController.dart';
import 'package:uuid/uuid.dart';

import '../UI/Chats/ChatHome.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<String> getDeviceToken()async{
    String? token = await messaging.getToken();
    return token!;
  }

  void isRefreshToken() async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print("Token refreshed");
      saveToken();
    });
  }

  void requestNotificationPermisions()async{
    if(Platform.isIOS){
      await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true
      );
    }

    NotificationSettings notificationSettings = await messaging.requestPermission( 
      alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true
    );

    if(notificationSettings.authorizationStatus == AuthorizationStatus.authorized){
       print("Permission granted");
    }else if(notificationSettings.authorizationStatus == AuthorizationStatus.provisional){
       print("User already granted Permissions");
    }else{
      print("User denied permission"); 
    }
  }

  Future foregroundMessage()async{
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge:true,
      sound:true
    );
  }


  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) { 
      print("====== FCM Message Recieved =========");
      firebaseMessagingHandler(message, Uuid().v4());
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      print("Notification title: ${notification!.title}");
      print("Notification body ${notification!.body}");
      print("Data: ${message.data.toString()}");

      if(Platform.isIOS){
        foregroundMessage();
      }

      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }

  void initLocalNotifications(BuildContext context,RemoteMessage message) async{
    var androidInitSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitSettings = const DarwinInitializationSettings();

    var initSettings =  InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveBackgroundNotificationResponse: (payload){
      handleMessage(context,message);
    },
    onDidReceiveNotificationResponse: (payload){
      handleMessage(context,message);
    });
  }

  void handleMessage(BuildContext context,RemoteMessage message){
    print("In handle message function");
    print(message.data);
    if (message.data['notification_type'] == 'chat-notify') {
      Get.to(()=>ChatHome(selectedChatId: message.data['chat_id']));
    }
  }

  Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(), 
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      androidNotificationChannel.id.toString(), 
      androidNotificationChannel.name.toString(),
      channelDescription: "Flutter Fcm",
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      sound: androidNotificationChannel.sound
      );
    
    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero,(){
      _flutterLocalNotificationsPlugin.show(0,
      message.notification!.title.toString(), message.notification!.body.toString(), notificationDetails);
    });

  }
}
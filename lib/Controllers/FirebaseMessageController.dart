import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:north_star/Auth/AuthHome.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:uuid/uuid.dart';

import '../Auth/CommonAuthUtils.dart';
import '../Models/Enums.dart';
import '../UI/Layout.dart';

late final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().i("Incoming message firebase");
  firebaseMessagingHandler(message, Uuid().v4());
}

Future<void> firebaseMessagingHandler(
    RemoteMessage message, String? uuid) async {
  print(
      'channel---> ${MessageChannel.Logout} ${MessageChannel.Logout == message.data['channel']}');
  if (MessageChannel.Logout.index.toString() ==
      message.data['channel']) {
    await CommonAuthUtils.signOut(redirect: false);
    showLogoutDialog();
  } else if ("PRO_ACTIVATED" == message.data['channel']) {
    print("Pro checking");
    verifyAndGoHome();
  }
}

Future<void> initFirebase(Uuid uuid) async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  print("=================== Firebase initializing =======================");
  FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
    print(
        'Message title: ${msg.notification?.title}, body: ${msg.notification?.body}, data: ${msg.data}');
    firebaseMessagingHandler(msg, uuid.v4());
  });
  _firebaseMessaging.getToken().then((token) async {
    String currentToken = (await FirebaseFirestore.instance
            .collection("UserTokens")
            .doc(authUser.id.toString())
            .get())['token'] ??
        "";
    if (token != currentToken) {
      await CommonAuthUtils.signOut();
    }
  });
}

Future<void> saveToken() async {
  dynamic currentToken = await FirebaseFirestore.instance
      .collection("UserTokens")
      .doc(authUser.id.toString())
      .get();
  print("token $currentToken");
  if (currentToken.exists) {
    currentToken = currentToken.data()['token'];
  } else {
    currentToken = "";
  }
  _firebaseMessaging.getToken().then((token) {
    print('Device Token FCM: $currentToken');
    if (currentToken != "" && token != currentToken) {
      print("trying to send Logout");
      dynamic data = {"channel": MessageChannel.Logout.index.toString()};
      sendFCMMessage(currentToken, data);
    }
    httpClient.updateDeviceToken(token!);
    FirebaseFirestore.instance
        .collection("UserTokens")
        .doc(authUser.id.toString())
        .set({"token": token});
  });
}

void sendFCMMessage(String deviceToken, dynamic data) async {
  print('$deviceToken <---Token Data---> $data');

  final httpData = {
    'data': data,
    'to': deviceToken
  };
  Map res = await httpClient.sendFcmMessage(httpData);
  if (res == 200) {
    print('FCM message sent successfully');
  } else {
    print('Error sending FCM message: ${res}');
  }
}

void verifyAndGoHome() async {
  Map res = await httpClient.getMyProfile();
  if (res['code'] == 200) {
    print(res['data']['subscription']);

    if (authUser.role == 'client') {
      authUser.saveUser(res['data']['user']);
    } else {
      authUser.saveUser(res['data']);
    }
    if (res['data']['subscription'] != null) {
      DateTime expDate =
          DateTime.parse(res['data']['subscription']['valid_till']);
      if (expDate.isBefore(DateTime.now())) {
        print('Subscription expired');
        showSnack('No Subscription Found or Payment Not Verified Yet!',
            'If you just purchased the Pro Version please await for the Bank to Verify the Payment!');
      } else {
        print('Subscription valid');
        Get.offAll(() => Layout());
        showSnack('Pro Version Unlocked!',
            'You have successfully subscribed to the Pro version.');
        Get.defaultDialog(
            radius: 8,
            title: 'Pro Version Unlocked!',
            content:
                Text('You have successfully subscribed to the Pro version.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('OK')),
            ]);
      }
    } else {
      showSnack('No Subscription Found or Not Verified Yet!',
          'If you just purchased the Pro Version please await for the Bank to Verify the Payment!');
    }
  } else {
    print(res);
    showSnack('Something went wrong!', 'Please contact support.');
  }
}

void showLogoutDialog() {
  Get.defaultDialog(
    radius: 5,
    onWillPop: () async {
      return false;
    },
    barrierDismissible: false,
    title: 'Security Alert!',
    titleStyle: TextStyle(
      fontSize: 20,
      color: Colors.red[400],
    ),
    titlePadding: EdgeInsets.only(top: 20),
    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Another device has logged into your account. If you don't recognize this activity, change your password for enhanced account security.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    ),
    actions: [
      Buttons.outlineTextIconButton(
          icon: Icons.power_settings_new_rounded,
          onPressed: () {
            Get.offAll(() => AuthHome());
          },
          label: "Login Again"),
    ],
  );
}

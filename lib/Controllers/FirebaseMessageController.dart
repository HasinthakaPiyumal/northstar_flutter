import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:north_star/Controllers/CallConrtoller.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:uuid/uuid.dart';

import '../Auth/CommonAuthUtils.dart';
import '../Models/Enums.dart';

late final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().i("Incoming message firebase");
  firebaseMessagingHandler(message, Uuid().v4());
}

Future<void> firebaseMessagingHandler(
    RemoteMessage message, String? uuid) async {
  print(
      'channel---> ${MessageChannel.Logout} ${MessageChannel.Logout == message.data['channel']}');
  if (MessageChannel.Call.index.toString() == message.data['channel']) {
    processCall(message.data, uuid!);
  } else if (MessageChannel.Logout.index.toString() ==
      message.data['channel']) {
    await CommonAuthUtils.signOut();
  }
}

Future<void> initFirebase(Uuid uuid) async {
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
    FirebaseFirestore.instance
        .collection("UserTokens")
        .doc(authUser.id.toString())
        .set({"token": token});
  });
}

void sendFCMMessage(String deviceToken, dynamic data) async {
  print('$deviceToken <---Token Data---> $data');
  final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'key=AAAAhwkb0SM:APA91bFru4x8CeD_OoiMfufybQ2Qfmk0bddGZmE634G0CFHYci0VNy34KLVJdac8ZP7cu76aX_Z4R-5Snpqq2vv3UDps6_yhOmKi99fqFtFzjAdCgsXBswCo7xUrE8L4RVglUEi4hP43',
    // Replace with your FCM server key
  };

  final message = {
    'data': data,
    'priority': 'high',
    'to': deviceToken, // Replace with the recipient device token
  };
  print('Sending FCM message------------------\n$message');
  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(message),
  );

  if (response.statusCode == 200) {
    print('FCM message sent successfully');
  } else {
    print('Error sending FCM message: ${response.statusCode}');
    print(response.body);
  }
}

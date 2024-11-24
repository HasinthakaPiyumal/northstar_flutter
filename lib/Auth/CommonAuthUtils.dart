import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/OneSignalClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../Controllers/FirebaseMessageController.dart';
import '../Plugins/HttpClient.dart';
import 'AuthHome.dart';

class CommonAuthUtils {
  static void signIn(Map res) {
    Map<String, dynamic> userData = res['data']['user'];
    if (res['data']['user']['subscription'] != null) {
      DateTime expDate =
          DateTime.parse(res['data']['user']['subscription']['valid_till']);
      if (expDate.isBefore(DateTime.now())) {
        print('Subscription expired');
        userData.remove('subscription');
      } else {
        print('Subscription valid');
      }
    }
    authUser.saveUser(userData);
    httpClient.setToken(res['data']['token']);
    client.changeToken(res['data']['token']);
    // OneSignalClient.changeExternalUser(
    //     res['data']['user']['id'], res['data']['user']['role']);
    FirebaseCrashlytics.instance.setCustomKey('user_id', authUser.id);
    FirebaseCrashlytics.instance.setCustomKey('user_email', authUser.email);
    FirebaseCrashlytics.instance.setUserIdentifier(authUser.id.toString());
    saveToken();
    Get.offAll(() => Layout());
  }

  static Future<bool> signOut({bool redirect=true}) async {
    // OneSignalClient.changeExternalUser(null, null);
    print('Signing Out');
    FirebaseMessaging.instance.getToken().then((token) async {
      print('Device Token FCM: $token');
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
      if (token == currentToken) {
        FirebaseFirestore.instance
            .collection("UserTokens")
            .doc(authUser.id.toString())
            .set({"token": ""});
      }
    });
    authUser.clearUser();
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.clear();
      if(redirect){
        Get.offAll(() => AuthHome());
      }
    });
    return true;
  }

  static void showWelcomeDialog() {
    Get.defaultDialog(
      title: 'Welcome!',
      middleText: 'Welcome to North Star. We are glad to have you on board',
      barrierDismissible: false,
      confirm: ElevatedButton(
        style: ButtonStyles.flatButton(),
        child: Text('OK'),
        onPressed: () {
          Get.close(1);
        },
      ),
    );
  }
}

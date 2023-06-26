import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/OneSignalClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../Plugins/HttpClient.dart';
import 'AuthHome.dart';

class CommonAuthUtils{

  static void signIn(Map res){

    Map<String,dynamic> userData = res['data']['user'];
    if(res['data']['user']['subscription'] != null){
      DateTime expDate = DateTime.parse(res['data']['user']['subscription']['valid_till']);
      if(expDate.isBefore(DateTime.now())){
        print('Subscription expired');
        userData.remove('subscription');
      } else {
        print('Subscription valid');
      }
    }
    authUser.saveUser(userData);
    httpClient.setToken(res['data']['token']);
    client.changeToken(res['data']['token']);
    OneSignalClient.changeExternalUser(res['data']['user']['id'], res['data']['user']['role']);
    FirebaseCrashlytics.instance.setCustomKey('user_id', authUser.id);
    FirebaseCrashlytics.instance.setCustomKey('user_email', authUser.email);
    FirebaseCrashlytics.instance.setUserIdentifier(authUser.id.toString());
    Get.offAll(()=>Layout());
  }

  static Future<bool> signOut() async {
    OneSignalClient.changeExternalUser(null, null);
    print('Signing Out');
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.clear();
      Get.offAll(() => AuthHome());
    });
    return true;
  }

  static void showWelcomeDialog(){
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

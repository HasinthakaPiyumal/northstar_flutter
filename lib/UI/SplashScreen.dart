import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/Auth/AuthHome.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/UI/WelcomeScreens/welcome_v2.dart';
import 'package:north_star/Utils/notification_service.dart';
import 'package:uuid/uuid.dart';

import '../Controllers/FirebaseMessageController.dart';
import 'Chats/ChatHome.dart';

class SplashScreen extends StatefulWidget {

  final bool isLoggedIn;

  const SplashScreen( {Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late final Uuid _uuid;
  NotificationServices notificationServices = NotificationServices();

  Future<void>? runSplash() {
    // initFirebase(_uuid);
    notificationServices.requestNotificationPermisions();
    notificationServices.foregroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.isRefreshToken();
    notificationServices.getDeviceToken().then((value) {
      print("Device token found - ${value}");
    });
    if(widget.isLoggedIn){
      saveToken();
      Timer(Duration(seconds: 1), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>Layout())));
    }else{
      Timer(Duration(seconds: 1), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>AuthHome())));
    }
    return null;
  }


  @override
  void initState() {
    super.initState();
    _uuid = const Uuid();

    runSplash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 100,
              child: Lottie.asset('assets/lotties/floatingArrow.json'),
            ),
          ),
          SizedBox(height: 20,),
          Center(
            child: Container(
              height: 30,
              child: Image.asset('assets/appicons/Northstar.png'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/UI/WelcomeScreens/welcome_v2.dart';
import 'package:uuid/uuid.dart';

import '../Controllers/FirebaseMessageController.dart';

class SplashScreen extends StatefulWidget {

  final bool isLoggedIn;

  const SplashScreen( {Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late final Uuid _uuid;

  Future<void>? runSplash() {
    if(widget.isLoggedIn){
      initFirebase(_uuid);
      Timer(Duration(seconds: 1), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>Layout())));
    }else{
      Timer(Duration(seconds: 1), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>WelcomeOne())));
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

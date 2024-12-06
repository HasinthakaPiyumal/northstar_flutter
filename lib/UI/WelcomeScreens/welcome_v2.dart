import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/AuthHome_v2.dart';
import 'package:north_star/UI/SharedWidgets/ExitWidget.dart';

class WelcomeOne extends StatelessWidget {
  const WelcomeOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool shouldPop = false;

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => ExitWidget(),
        );
        return shouldPop;
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/backgrounds/welcome.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [
                  Colors.black.withOpacity(0.5399999856948853),
                  Colors.black
                ],
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [],
            ),
            bottomNavigationBar: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage("assets/appicons/logo_black_white.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 121,
                    height: 53,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/appicons/mini_logo_text_white.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Get.height / 100 * 14,
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'SHAPE YOUR FUTURE\nBEGIN WITH OUR FITNESS APP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontFamily: 'Bebas Neue',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: Get.height/100*7),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 40.0),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        'Ignite your fitness journey with Northstar Your ultimate companion for personalized workouts, expert guidance, and a thriving fitness community.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Get.height/100*6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 264,
                        height: 64,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthHome(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFB700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'get started'.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1B1F24),
                                  fontSize: 22,
                                  fontFamily: 'Bebas Neue',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.height / 100 * 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

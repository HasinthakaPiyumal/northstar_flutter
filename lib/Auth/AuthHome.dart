import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/SignIn.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpStart.dart';
import 'package:north_star/Styles/Themes.dart';

class AuthHome extends StatelessWidget {
  const AuthHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            child: Image.asset(
              'assets/images/front.png',
              fit: BoxFit.fitHeight,
            ),
          ),
          Positioned(
            bottom: 0,
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: Get.width * 0.75,
                  child: Image.asset(
                    'assets/allwhite.png',
                    fit: BoxFit.fitHeight,
                  ),
                )
              ],
            ),
          ),

          Obx(()=> !ready.value ? Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ): Container()),

          Obx(()=> ready.value ? Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: Container(
              child: Column(
                children: [
                  Container(
                    width: Get.width * 0.8,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        shape: Themes().roundedBorder(12),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFFC987),
                                  Color(0xFFF1AB56),
                                ]),
                            borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          alignment: Alignment.center,
                          width: Get.width * 0.8,
                          height: 58,
                          child: Text(
                            'Create an Account',
                            style: TextStyle(

                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => SignUpStart());
                      },
                    ),
                  )
                ],
              ),
            ),
          ): Container()),
          Obx(()=> ready.value ? Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?',
                      style: TextStyle(color: Colors.white)),
                  TextButton(
                    child: Text('Sign In',
                        style: TextStyle(color: Color(0xFFF3AF5D))),
                    onPressed: () {
                      Get.to(() => SignIn());
                    },
                  )
                ],
              ),
            ),
          ): Container())
        ],
      ),
    );
  }
}

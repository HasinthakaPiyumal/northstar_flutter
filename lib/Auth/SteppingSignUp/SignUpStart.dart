import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpUserType.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SignUpStart extends StatelessWidget {
  const SignUpStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset('assets/images/signUp.png',
                      height: Get.height*0.6,
                      fit: BoxFit.fitHeight,
                      alignment: Alignment.center,
                    ),
                  ),
                  SizedBox(height: Get.height*0.01, width: double.infinity,),
                  Text('Hi There! 👋', style: TypographyStyles.title(28)),
                  SizedBox(height: 10,),
                  Flexible(
                    child: Text('Glad to see you\'re on your way to\na healthier life.',
                      style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),).copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
            Container(
              width: Get.width,
              height: 60,
              child: ElevatedButton(
                style: ButtonStyles.bigBlackButton(),
                child: Text('Get Started',
                  style: TypographyStyles.boldText(16, Themes.mainThemeColorAccent.shade100),
                ),
                onPressed: () {
                  Get.to(()=> SignUpUserType());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

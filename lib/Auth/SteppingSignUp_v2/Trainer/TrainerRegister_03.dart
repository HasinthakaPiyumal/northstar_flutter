import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Radios.dart';

import '../../../Models/HttpClient.dart';
import '../../../components/Buttons.dart';
import '../../CommonAuthUtils.dart';
import '../../SteppingSignUp/SignUpData.dart';

class TrainerRegisterThree extends StatefulWidget {
  @override
  State<TrainerRegisterThree> createState() => _TrainerRegisterThreeState();
}

class _TrainerRegisterThreeState extends State<TrainerRegisterThree> {
  RxBool isLoading = false.obs;

  int genderType = 1;
  bool showPass1 = false;
  bool showPass2 = false;

  TextEditingController _aboutController = TextEditingController();
  bool isInsured = false;
  RxString trainerType = "1".obs;

  String emergencyContact = "";

  void next() async {
    if (_aboutController.text.isEmpty) {
      showSnack('Incomplete information', 'Please enter correct information',status: PopupNotificationStatus.warning);
    } else {
      signUpData.about = _aboutController.text;
      signUpData.isInsured = isInsured;
      signUpData.trainerType = trainerType.value;

      isLoading.value = true;
      Map res = await httpClient.signUp(signUpData.toTrainerJson());
      isLoading.value = false;
      if (res['code'] == 200) {
        CommonAuthUtils.signIn(res);
        showSnack(
            'Welcome to NorthStar!', 'Your personal fitness Application!',status: PopupNotificationStatus.success);
        CommonAuthUtils.showWelcomeDialog();
      } else {
        showSnack('Something went wrong!', res['data']['message'],status: PopupNotificationStatus.warning);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double contentHeight = 25.0;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/appicons/logo_black_white.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      width: 66,
                      height: 29,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(isDark
                              ? "assets/appicons/mini_logo_text_white.png"
                              : "assets/appicons/mini_logo_text_black.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Container(
                  width: 85,
                  height: 50,
                  padding: const EdgeInsets.all(3.0),
                  decoration: ShapeDecoration(
                    color: isDark ? Colors.white : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              padding: const EdgeInsets.all(2),
                              decoration: ShapeDecoration(
                                color: Color(0xFFFFB700),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '03',
                                    style: TextStyle(
                                      color: Color(0xFF1B1F24),
                                      fontSize: 20,
                                      fontFamily: 'Bebas Neue',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '/ 03',
                              style: TextStyle(
                                color: Color(0xFF1B1F24),
                                fontSize: 20,
                                fontFamily: 'Bebas Neue',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Are You Insured Trainer',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: contentHeight),
                Row(
                  children: [
                    InkWell(
                      onTap: () => {setState(() => isInsured = false)},
                      child: Container(
                        width: 120,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: !isInsured
                            ? ShapeDecoration(
                                color: Color(0xFFFFB700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              )
                            : ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.25,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: Color(0xFFFFB700),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'yes'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isInsured
                                    ? isDark?Colors.white70:Colors.black54
                                    : Color(0xFF1B1F24),
                                fontSize: 24,
                                fontFamily: 'Bebas Neue',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    InkWell(
                      onTap: () => {setState(() => isInsured = true)},
                      child: Container(
                        width: 120,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: !isInsured
                            ? ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.25,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: Color(0xFFFFB700),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              )
                            : ShapeDecoration(
                                color: Color(0xFFFFB700),
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
                              'No'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isInsured
                                    ? isDark?Colors.white70:Colors.black54
                                    : Color(0xFF1B1F24),
                                fontSize: 24,
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

                SizedBox(height: 30),
                Obx(()=> Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Trainer Type',style: TypographyStyles.textWithWeight(
                              16, FontWeight.w400)),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                trainerType.value = '1';
                              },
                              child: Row(
                                children: [
                                  trainerType.value == '1'
                                      ? Radios.radioChecked()
                                      : Radios.radio(),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Trainer",
                                      style: TypographyStyles.textWithWeight(
                                          16, FontWeight.w500))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40,
                            ),
                            GestureDetector(
                              onTap: () {
                                trainerType.value = '2';
                              },
                              child: Row(
                                children: [
                                  trainerType.value == '2'
                                      ? Radios.radioChecked()
                                      : Radios.radio(),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Dietitian",
                                      style: TypographyStyles.textWithWeight(
                                          16, FontWeight.w500))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40,
                            ),
                            GestureDetector(
                              onTap: () {
                                trainerType.value = '3';
                              },
                              child: Row(
                                children: [
                                  trainerType.value == '3'
                                      ? Radios.radioChecked()
                                      : Radios.radio(),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Both",
                                      style: TypographyStyles.textWithWeight(
                                          16, FontWeight.w500))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: contentHeight * 2),
                TextFormField(
                  controller: _aboutController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text(
                      "About",
                      style:  TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),),
                      Text(" *",style: TextStyle(color: Colors.red),)
                    ],),
                    contentPadding: EdgeInsets.all(10),
                  ),
                  style: TextStyle(color: isDark? Colors.white:Colors.black),
                ),
                SizedBox(height: contentHeight),
                Obx(()=> Center(
                  child: Buttons.yellowFlatButton(
                    label: "Signup",
                    isLoading: isLoading.value,
                    width: Get.width - 40,
                    onPressed: () {
                      next();
                    },
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

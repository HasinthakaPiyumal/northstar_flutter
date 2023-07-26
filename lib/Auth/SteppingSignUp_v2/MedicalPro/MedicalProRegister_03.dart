import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../Models/HttpClient.dart';
import '../../../Styles/ButtonStyles.dart';
import '../../CommonAuthUtils.dart';
import '../../SteppingSignUp/SignUpData.dart';

class MedicalProRegisterThree extends StatefulWidget {
  @override
  State<MedicalProRegisterThree> createState() =>
      _MedicalProRegisterThreeState();
}

class _MedicalProRegisterThreeState extends State<MedicalProRegisterThree> {
  RxBool isLoading = false.obs;

  int genderType = 1;
  bool showPass1 = false;
  bool showPass2 = false;

  TextEditingController _specialtyController = TextEditingController();
  TextEditingController _hourlyRatetyController = TextEditingController();
  bool canPrescribe = false;
  String title = "Dr";

  String emergencyContact = "";

  void next() async {
    isLoading.value = true;

    if (_specialtyController.text.isEmpty) {
      showSnack('Incomplete information', 'Please enter correct information');
    } else {
      signUpData.speciality = _specialtyController.text;
      signUpData.canPrescribe = canPrescribe;
      signUpData.hourlyRate = _hourlyRatetyController.text;

      Map res = await httpClient.signUp(signUpData.toDoctorJson());
      print(res);
      if (res['code'] == 200) {
        CommonAuthUtils.signIn(res);
        showSnack(
            'Welcome to NorthStar!', 'Your personal fitness Application!');
        Get.defaultDialog(
          title: 'Notice!',
          middleText:
              'You must be verified by an admin before you can use the app. Please wait for an email from us.',
          barrierDismissible: false,
          confirm: ElevatedButton(
            style: ButtonStyles.flatButton(),
            child: Text('OK'),
            onPressed: () {
              Get.close(1);
            },
          ),
        );
      } else {
        showSnackResponse('Something went wrong!', res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double contentHeight = 18.0;
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _specialtyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDark ? Colors.white : Colors.black),
                    ),
                    labelText: 'specialty',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.all(10),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                SizedBox(height: contentHeight),
                TextFormField(
                  controller: _hourlyRatetyController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.attach_money_rounded,
                        color: isDark ? Colors.white : Colors.black, size: 18),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: isDark ? Colors.white : Colors.black),
                    ),
                    labelText: 'Hourly Rate (${signUpData.currency})',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.only(bottom: 0),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                SizedBox(height: 30),
                Text(
                  'Are You Authorized To Prescribe?',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      onTap: () => {setState(() => canPrescribe = false)},
                      child: Container(
                        width: 100,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: !canPrescribe
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
                                color: canPrescribe
                                    ? (isDark ? Colors.white70 : Colors.black54)
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
                      onTap: () => {setState(() => canPrescribe = true)},
                      child: Container(
                        width: 100,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: !canPrescribe
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
                                color: !canPrescribe
                                    ? (isDark ? Colors.white70 : Colors.black54)
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
                SizedBox(height: contentHeight),
                Text(
                  'Title',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      onTap: () => {setState(() => title = 'Dr')},
                      child: Container(
                        width: 70,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: title == 'Dr'
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
                              'dr'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: title == 'Dr'
                                    ? Color(0xFF1B1F24)
                                    : isDark
                                        ? Colors.white70
                                        : Colors.black54,
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
                      onTap: () => {setState(() => title = 'Mr')},
                      child: Container(
                        width: 70,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: title == 'Mr'
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
                              'mr'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: title == 'Mr'
                                    ? Color(0xFF1B1F24)
                                    : isDark
                                        ? Colors.white70
                                        : Colors.black54,
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
                      onTap: () => {setState(() => title = 'Ms')},
                      child: Container(
                        width: 70,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: title == 'Ms'
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
                              'ms'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: title == 'Ms'
                                    ? Color(0xFF1B1F24)
                                    : isDark
                                        ? Colors.white70
                                        : Colors.black54,
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
                      onTap: () => {setState(() => title = 'Mrs')},
                      child: Container(
                        width: 70,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: title == 'Mrs'
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
                              'mrs'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: title == 'Mrs'
                                    ? Color(0xFF1B1F24)
                                    : isDark
                                        ? Colors.white70
                                        : Colors.black54,
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
                SizedBox(height: contentHeight * 2),
                Center(
                  child: Container(
                    width: 350,
                    height: 64,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        next();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFFFB700),
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
                            'Sign up'.toUpperCase(),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

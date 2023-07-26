import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_animations/im_animations.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetPro.dart';

bool enabledProWidgets(String text) {
  List proWidgets = [
    'Dashboard',
    'Workouts',
    'Todo',
    'Video Sessions',
    'Resources',
    'Doctors',
    'Calls',
    'Client Notes',
    'Health Services',
    'Calories',
    'Lab Reports',
    'Online Clinic'
  ];

  if (proWidgets.contains(text) && authUser.user['subscription'] == null) {
    return false;
  } else {
    return true;
  }
}

Widget homeWidgetButton(Function goTo, String icon, String text) {
  return Column(
    children: [
      Container(
        height: 128,
        width: Get.width / 3.2,
        padding: EdgeInsets.all(2),
        //margin: EdgeInsets.only(right: 7),
        child: ElevatedButton(
          style: enabledProWidgets(text)
              ? ButtonStyles.homeBtn()
              : ButtonStyles.homeBtn().copyWith(
                  side: MaterialStateProperty.resolveWith<BorderSide>(
                      (states) => BorderSide(
                            color: Themes.mainThemeColor.shade600,
                            width: 1,
                          ))),
          onPressed: enabledProWidgets(text)
              ? () {
                  goTo();
                }
              : () {
                  Get.to(() => HomeWidgetPro());
                },
          child: Padding(
              padding: EdgeInsets.all(4),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon == 'dashboard'
                          ? HeartBeat(
                              child: Container(
                                width: 58,
                                height: 28,
                                child: Card(
                                    color: Colors.redAccent,
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        Positioned(
                                          left: 5,
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 6.0),
                                          child: Text('LIVE'),
                                        ),
                                      ],
                                    )),
                              ),
                              beatsPerMinute: 40,
                            )
                          : Image.asset(
                              'assets/home/$icon.png',
                              color: Get.isDarkMode
                                  ? enabledProWidgets(text)
                                      ? null
                                      : Colors.grey[800]
                                  : enabledProWidgets(text)
                                      ? null
                                      : Colors.grey,
                            ),
                      Get.isDarkMode
                          ? Text(text,
                              textAlign: TextAlign.center,
                              style: TypographyStyles.boldText(
                                  10,
                                  enabledProWidgets(text)
                                      ? Colors.white
                                      : Colors.grey.shade800))
                          : Text(text,
                              textAlign: TextAlign.center,
                              style: TypographyStyles.boldText(
                                  10,
                                  enabledProWidgets(text)
                                      ? Colors.black
                                      : Colors.grey))
                    ],
                  ),
                  if (!enabledProWidgets(text))
                    Center(
                      child: Image.asset(
                        'assets/images/pro.png',
                        height: 50,
                        width: 50,
                      ),
                    ),
                ],
              )),
        ),
      ),
    ],
  );
}

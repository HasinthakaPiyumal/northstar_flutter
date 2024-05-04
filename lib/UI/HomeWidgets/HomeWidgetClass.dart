import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetVideoSessions.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import 'HomeWidgetClasses.dart';


class HomeWidgetClass extends StatelessWidget {
  const HomeWidgetClass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Classes', style: TypographyStyles.title(20))),
      body: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      height: 80,
                      child: ElevatedButton(
                        style: ButtonStyles.matButton(
                            Get.isDarkMode
                                ? AppColors.primary2Color
                                : Colors.white,
                            1),
                        onPressed: () {
                          Get.to(() => HomeWidgetVideoSessions());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 48,
                              child: Image.asset("assets/icons/video-session.png"),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Video Session',
                              style: TypographyStyles.text(16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 80,
                      child: ElevatedButton(
                        style: ButtonStyles.matButton(
                            Get.isDarkMode
                                ? AppColors.primary2Color
                                : Colors.white,
                            1),
                        onPressed: () {
                          Get.to(() => Classes());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 48,
                              child: Image.asset("assets/icons/gym-class.png"),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Gym Classes',
                              style: TypographyStyles.text(16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

bool shouldPop = false;

class ExitWidget extends StatelessWidget {
  const ExitWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG,
      title: Text(
        'Do you want to exit from Northstar ?',
        style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Yes',
            style: TypographyStyles.boldText(14, Themes.mainThemeColor.shade500),
          ),
          onPressed: () {
            shouldPop = true;
            SystemNavigator.pop();
          },
        ),
        TextButton(
          child: Text(
            'No',
            style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}


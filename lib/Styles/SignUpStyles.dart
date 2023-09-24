import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SignUpStyles{

  static ButtonStyle notSelectedButton(){
    return ElevatedButton.styleFrom(
      foregroundColor: Get.isDarkMode ? Colors.white: Colors.black,
      backgroundColor: Colors.transparent, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
      textStyle: TextStyle(
        fontSize: 20,
      ),
      side: BorderSide(
        //color: Get.isDarkMode ? colors.Colors().darkGrey(0.5) : Colors.black,
        color: colors.Colors().darkGrey(0.5),
        width: 1.0,
      ),
    );
  }

  static ButtonStyle selectedButton(){
    return ElevatedButton.styleFrom(
      foregroundColor: Get.isDarkMode ? Themes.mainThemeColor.shade600: colors.Colors().lightBlack(1), 
      backgroundColor: Get.isDarkMode ? Colors.transparent : colors.Colors().selectedCardBG, elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
      ),
      textStyle: TextStyle(
        fontSize: 20,
      ),
      side: BorderSide(
        color: AppColors.accentColor,
        width: 1,
      ),
    );
  }
}

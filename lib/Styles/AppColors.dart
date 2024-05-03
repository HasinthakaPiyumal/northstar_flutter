import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AppColors {
  static const Color primary1Color = Color(0xFF1B1F24);
  static const Color primary2Color = Color(0xFF1E2630);
  static const Color accentColor = Color(0xFFFFB700);
  static const Color baseColor = Color(0xFFF1F3F9);
  static const Color backgroundColor = Color(0xFFE5E5E5);
  static const Color primary1ColorLight = Color(0xFFF2F2F2);
  static const Color primary2ColorLight = Color(0xFFFFFFFF);

  static const Color textOnAccentColor = Color(0xFF1B1F24);

  static const Color textColorDark = Colors.white;
  static const Color textColorLight = Color(0xFF1B1F24);

  Color getPrimaryColor({bool reverse = false}){
    return reverse? Get.isDarkMode?primary1ColorLight:primary1Color: Get.isDarkMode?primary1Color:primary1ColorLight;
  }

  Color getSecondaryColor({bool reverse = false}){
    return reverse? Get.isDarkMode?primary2ColorLight:primary2Color: Get.isDarkMode?primary2Color:primary2ColorLight;
  }
// Add more color constants here
}
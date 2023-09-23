import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TypographyStyles {
  static TextStyle normalText(int size, Color color) {
    return TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: size.toDouble(),
      color: !color.isNull?color:Get.isDarkMode?Colors.white:Color(0xFF1B1F24),
      fontFamily: 'Poppins',
    );
  }
  static TextStyle textWithWeight(int size, FontWeight weight) {
    return TextStyle(
      fontWeight: weight,
      fontSize: size.toDouble(),
      color:Get.isDarkMode?Colors.white:Color(0xFF1B1F24),
      fontFamily: 'Poppins',
    );
  }
  static TextStyle textWithWeightUnderLine(int size, FontWeight weight) {
    return TextStyle(
      fontWeight: weight,
      fontSize: size.toDouble(),
      color:Get.isDarkMode?Colors.white:Color(0xFF1B1F24),
      fontFamily: 'Poppins',
      decoration: TextDecoration.underline
    );
  }

  static TextStyle boldText(int size, Color color) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: size.toDouble(),
      fontFamily: 'Poppins',
      color: color,
    );
  }
  static TextStyle smallBoldTitle(int size) {
    return TextStyle(
      fontSize: size.toDouble(),
      color:Get.isDarkMode?Colors.white:Color(0xFF1B1F24),
      fontFamily: 'Bebas Neue',
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle title(int size) {
    return TextStyle(
      color: Get.isDarkMode?Colors.white:Color(0xFF1B1F24),
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: size.toDouble(),
    );
  }

  static TextStyle text(int size) {
    return TextStyle(fontSize: size.toDouble(), fontWeight: FontWeight.normal,fontFamily: 'Poppins',);
  }

  static TextStyle walletTransactions(int size, String type) {
    return TextStyle(
        fontSize: size.toDouble(),
        fontWeight: FontWeight.bold,
        color: type == 'Credit' ? Color(0xff02B88D) : Color(0xffDB1E00));
  }
}

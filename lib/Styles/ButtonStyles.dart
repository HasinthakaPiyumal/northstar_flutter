import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class ButtonStyles {
  static ButtonStyle superRound() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)));
  }

  static ButtonStyle homeBtn() {
    return ElevatedButton.styleFrom(
      foregroundColor: Themes.mainThemeColor,
      backgroundColor: Get.isDarkMode ? Color(0xFF1E2630) : Colors.white,
      // shadowColor: Colors.black.withOpacity(0.6),
      elevation: 6,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 0.50, color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  static ButtonStyle flatButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Color(0xFFF3F4F6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)));
  }

  static ButtonStyle healthServiceButton(Color color) {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)));
  }

  static ButtonStyle bigBlackButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        // backgroundColor: Colors.black,
        backgroundColor: AppColors.accentColor,
        textStyle: TextStyle(
          color: Color(0xFF1B1F24),
          fontSize: 20,
          fontFamily: 'Bebas Neue',
          fontWeight: FontWeight.w400,
          height: 0,
        ),
        // elevation: 6,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));
  }
  static ButtonStyle bigPrimaryButton() {
    return ElevatedButton.styleFrom(
        backgroundColor: Get.isDarkMode ? AppColors.primary2Color:Colors.white,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));
  }

  static ButtonStyle bigGreyButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));
  }

  static ButtonStyle bigWhiteButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));
  }

  static ButtonStyle bigFlatBlackButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
  }

  static ButtonStyle bigFlatGreyButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Color(0xffE2E2E2),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
  }
  static ButtonStyle bigFlatYellowButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: AppColors.accentColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));
  }

  static ButtonStyle bigFlatSearchBlackButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(12))));
  }

  static ButtonStyle bigFlatFilterBlackButton() {
    return ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xffF3AF5D),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12))));
  }

  static ButtonStyle flatFilterButton() {
    return OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  static ButtonStyle matButton(Color color, double? elevation) {
    return ElevatedButton.styleFrom(
        foregroundColor: Get.isDarkMode ? Colors.white : Colors.black,
        backgroundColor: color,
        elevation: elevation,
        // maximumSize: Get.size,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));
  }

  static ButtonStyle matRadButton(
      Color color, double? elevation, double radius) {
    return ElevatedButton.styleFrom(
        foregroundColor: Get.isDarkMode ? Colors.white : Colors.black,
        backgroundColor: color,
        elevation: elevation,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius)));
  }

  static ButtonStyle notSelectedBookingButton(double bRadius) {
    return ElevatedButton.styleFrom(
      foregroundColor: Get.isDarkMode ? Colors.white : Colors.black,
      backgroundColor: colors.Colors().lightBlack(1),
      elevation: 0,
      disabledForegroundColor: Colors.black.withOpacity(0.38),
      disabledBackgroundColor: Colors.black.withOpacity(0.12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(bRadius)),
      textStyle: TextStyle(
        fontSize: 20,
      ),
    );
  }

  static ButtonStyle notSelectedBookingButtonLightTheme(double bRadius) {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: colors.Colors().selectedCardBG,
      elevation: 0,
      disabledForegroundColor: Colors.grey[700]?.withOpacity(0.38),
      disabledBackgroundColor: Colors.grey[700]?.withOpacity(0.12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(bRadius)),
      textStyle: TextStyle(
        fontSize: 20,
      ),
    );
  }

  static ButtonStyle selectedBookingButton(double bRadius) {
    return ElevatedButton.styleFrom(
      foregroundColor: Themes.mainThemeColorAccent.shade100,
      backgroundColor: Themes.mainThemeColor.shade500,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(bRadius),
      ),
      textStyle: TextStyle(
        fontSize: 20,
      ),
    );
  }

  static ButtonStyle selectedButton() {
    return ElevatedButton.styleFrom(
      foregroundColor: Get.isDarkMode ? Colors.white : Colors.black,
      backgroundColor: Get.isDarkMode
          ? colors.Colors().deepGrey(1)
          : colors.Colors().selectedCardBG,
      padding: const EdgeInsets.symmetric(vertical: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      textStyle: TextStyle(
        fontSize: 20,
      ),
      side: BorderSide(
        color: Get.isDarkMode
            ? Themes.mainThemeColor.shade600
            : colors.Colors().lightBlack(1),
        width: 1.5,
      ),
    );
  }

  static ButtonStyle selectedButtonNoPadding() {
    return ElevatedButton.styleFrom(
      foregroundColor: Get.isDarkMode ? Colors.white : Colors.black,
      backgroundColor: Get.isDarkMode
          ? AppColors.primary2Color
          : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      textStyle: TextStyle(
        fontSize: 20,
      ),
      side: BorderSide(
        color: Themes.mainThemeColor.shade600,
        width: 1.5,
      ),
    );
  }

  static ButtonStyle notSelectedButton() {
    return ElevatedButton.styleFrom(
      foregroundColor: Get.isDarkMode ? Colors.white : Colors.black,
      backgroundColor: Get.isDarkMode
          ? AppColors.primary2Color
          : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      textStyle: TextStyle(
        fontSize: 20,
      ),
    );
  }

  static ButtonStyle notSelectedButtonNoPadding() {
    return ElevatedButton.styleFrom(
      foregroundColor: Get.isDarkMode ? Colors.white : Colors.black,
      backgroundColor: Get.isDarkMode
          ? AppColors.primary2Color
          : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      textStyle: TextStyle(
        fontSize: 20,
      ),
    );
  }
}

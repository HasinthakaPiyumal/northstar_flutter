import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/CommonAuthUtils.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';

enum PopupNotificationStatus {
  success,  // Notification displayed successfully
  info,     // Informational notification
  warning,  // Warning about a potential issue
  error,    // Indicates a critical error
}

double approximateHeight(String text, double fontSize, double width) {
  // Very rough estimate
  double avgCharHeight = fontSize; // Adjust 1.2 as needed
  int lines = (text.length * fontSize / width).ceil();
  print('line count');
  print(lines);
  return lines * avgCharHeight;
}

void showSnack(String title, String message, {PopupNotificationStatus status = PopupNotificationStatus.info}) {
  double calculatedTopMargin = (Get.height/2)-approximateHeight(message,14,Get.width)-60;
  Get.snackbar(
    title,
    message,
    isDismissible: true,
    margin: EdgeInsets.only(top:calculatedTopMargin,left:32,right: 32),
    backgroundColor: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
    colorText: Get.isDarkMode ? Colors.white:Colors.black,
    overlayBlur: 4,
    overlayColor: Color(0x22000000),
    dismissDirection: DismissDirection.down,
    animationDuration: Duration(milliseconds: 400),
    titleText: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: PopupNotificationStatus.error==status || PopupNotificationStatus.success==status,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SvgPicture.asset(
              PopupNotificationStatus.error==status?"assets/svgs/error-outline.svg":"assets/svgs/circle-solid.svg",
            width: 24,
            height: 24,
            color: status==PopupNotificationStatus.error?Color(0xFFFB0000):Color(0xFF00E417),
                    ),
          ),),
        Text(title,textAlign: TextAlign.center,style:  TextStyle(
          color: status==PopupNotificationStatus.error?Color(0xFFFB0000):status==PopupNotificationStatus.success?Color(0xFF00E417):Get.isDarkMode?Colors.white:AppColors.textOnAccentColor,
          fontSize: 20,
          fontFamily: 'Bebas Neue',
          fontWeight: FontWeight.w400,
          height: 0,
        )),
      ],
    ),
    messageText: Text(message,textAlign: TextAlign.center,style:  TextStyle(
      fontSize: 14,
    ),),
    borderRadius: 5,
  );
}

void showSnackResponse(String title, dynamic data) {
  data = data["data"];
  String firstErrorMessage = "";

  if (data != null) {
    data.forEach((key, value) {
      print(value);
      if (value is List && value.isNotEmpty) {
        firstErrorMessage = value.first;
        Get.snackbar(
          title,
          firstErrorMessage,
          margin: const EdgeInsets.all(16),
          backgroundColor: Get.isDarkMode ? Colors.white : Colors.black,
          colorText: Get.isDarkMode ? Colors.black : Colors.white,
        );
      } else if (value is String) {
        firstErrorMessage = value;
        Get.snackbar(
          title,
          firstErrorMessage,
          margin: const EdgeInsets.all(16),
          backgroundColor: Get.isDarkMode ? Colors.white : Colors.black,
          colorText: Get.isDarkMode ? Colors.black : Colors.white,
        );
      }
    });
  }
}

void showSignOutDialog() {
  CommonConfirmDialog.confirm('Logout').then((value) async {
    if (value) {
      await CommonAuthUtils.signOut();
      /*SharedPreferences.getInstance().then((prefs) async {
        await prefs.clear();

        Get.offAll(() => AuthHome());
      });*/
    }
  });
}

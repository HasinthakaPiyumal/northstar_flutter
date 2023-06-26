import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/CommonAuthUtils.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';


void showSnack(String title, String message) {
  Get.snackbar(title, message,
      margin: const EdgeInsets.all(16),
      backgroundColor: Get.isDarkMode ? Colors.white : Colors.black,
      colorText: Get.isDarkMode ? Colors.black : Colors.white,
  );
}

void showSignOutDialog(){
  CommonConfirmDialog.confirm('Logout').then((value) async{
    if(value) {

      await CommonAuthUtils.signOut();
      /*SharedPreferences.getInstance().then((prefs) async {
        await prefs.clear();

        Get.offAll(() => AuthHome());
      });*/
    }
  });
}

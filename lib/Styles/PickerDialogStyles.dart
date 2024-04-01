import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:north_star/Styles/AppColors.dart';

class PickerDialogStyles{
  static PickerDialogStyle main(){
    return PickerDialogStyle(
      backgroundColor: Get.isDarkMode?AppColors.primary2Color:Colors.white,
      listTileDivider: Container(),
    );
  }
}
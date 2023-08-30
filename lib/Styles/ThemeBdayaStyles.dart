import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

class ThemeBdayaStyles{
  static DatePickerThemeBdaya main(){
    return DatePickerThemeBdaya(
      backgroundColor: Get.isDarkMode?AppColors.primary2Color:Colors.white,
      cancelStyle: TypographyStyles.textWithWeight(16,FontWeight.w400),
      doneStyle: TextStyle(
        color: Color(0xFFFFB700),
        fontSize: 16,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      itemStyle: TypographyStyles.textWithWeight(16,FontWeight.w400),
      // headerColor: Colors.black,
      containerHeight: Get.height / 3,
    );
  }
}
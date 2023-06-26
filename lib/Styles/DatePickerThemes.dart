import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:north_star/Plugins/Utils.dart';

class DatePickerThemes {
  static DatePickerThemeBdaya mainTheme() {
    return DatePickerThemeBdaya(
      backgroundColor: Utils.isDarkMode() ? Color(0xFF232323) : Colors.white,
      containerHeight: Get.height / 3,
      cancelStyle: TextStyle(color: Colors.redAccent),
      itemStyle: TextStyle(
          color: Utils.isDarkMode() ? Colors.white : Color(0xFF232323)),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Utils {

  static String dateFormat(String date) {
    return date.split('T')[0] + ' ' + date.split('T')[1].split('.')[0];
  }

  static List colorBMI(String category) {
    if (category == 'Normal' || category == 'Good') {
      return [
        Color(0xffB6FF92),
        Color(0xff469513)
      ];
    } else {
      return [
        Color(0xffFFD9BF),
        Color(0xffAE552C)
      ];
    }
  }

  static bool isDarkMode() {
    return Get.isDarkMode;
  }

  static final NumberFormat formatCurrency = NumberFormat.currency(locale: 'en_US', name: 'MVR', symbol: "MVR ");
  static final NumberFormat currencyFmt = NumberFormat("###,###,##0.00");

}

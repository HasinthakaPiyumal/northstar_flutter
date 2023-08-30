import 'package:flutter/material.dart';

class Radios {
  static Container radio() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(width: 2, color: Color(0xFFECF035))),
    );
  } static Container radioChecked() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(width: 6, color: Color(0xFFECF035))),
    );
  }

  static Container radioChecked2() {
    return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(width: 2, color: Color(0xFFECF035))),
        child: Center(
            child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(0xFFECF035),
                  borderRadius: BorderRadius.circular(100),
                ))));
  }
}

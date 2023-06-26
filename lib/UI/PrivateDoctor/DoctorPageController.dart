import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DoctorPageController {
  static Rx<PageController> doctorPageController = PageController(initialPage: 0).obs;
}

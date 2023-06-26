import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/WatchDataController.dart';

Widget watchDataWidget(int userId) {
  WatchDataController controller = WatchDataController(userId);
  controller.init();



  return controller.enabled ? Container(
    child: Column(
      children: [
        Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Card(
            elevation: 6,
            color: Get.isDarkMode ? Color(0xff1C1C1C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 110,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Color(0xff1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Heart'),
                      SizedBox(
                        height: 16,
                        child: Image.asset(
                          "assets/icons/heart.png",
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(controller.lastHeartRate.string + ' bpm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            elevation: 6,
            color: Get.isDarkMode ? Color(0xff1C1C1C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 110,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Color(0xff1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Temp'),
                      SizedBox(
                        height: 16,
                        child: Image.asset(
                          "assets/icons/temp.png",
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(controller.lastBodyTemp.string + '°C', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            elevation: 6,
            color: Get.isDarkMode ? Color(0xff1C1C1C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 110,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Color(0xff1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Steps'),
                      SizedBox(
                        height: 16,
                        child: Image.asset(
                          "assets/icons/steps.png",
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(controller.lastSteps.string, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    )
      ],
    ),
  ): Card(
    child: Container(
      margin: EdgeInsets.all(20),
      child: Center(
        child: Text('Live Health Data Sync is Not Enabled. Please enable it in the settings.'),
      ),
    ),
  );
}

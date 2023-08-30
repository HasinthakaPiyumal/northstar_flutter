import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/WatchDataController.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            elevation: 0,
            color: Get.isDarkMode ? Color(0xff1C1C1C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              height: 106,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? AppColors.primary1Color : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Heart',style: TypographyStyles.textWithWeight(14, FontWeight.w400),),
                      SizedBox(
                        height: 24,
                        child: SvgPicture.asset(
                          "assets/svgs/heart.svg",
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(controller.lastHeartRate.string + ' bpm', style: TypographyStyles.title(20)),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            elevation: 0,
            color: Get.isDarkMode ? AppColors.primary1Color : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              height: 106,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? AppColors.primary1Color : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Temp',style: TypographyStyles.textWithWeight(14, FontWeight.w400),),
                      SizedBox(
                        height: 24,
                        child: SvgPicture.asset(
                          "assets/svgs/temp.svg",
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(controller.lastBodyTemp.string + '°C', style: TypographyStyles.title(20)),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            elevation: 0,
            color: Get.isDarkMode ? AppColors.primary1Color : AppColors.baseColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 106,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? AppColors.primary1Color : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Steps',style: TypographyStyles.textWithWeight(14, FontWeight.w400),),
                      SizedBox(
                        height: 24,
                        child: SvgPicture.asset(
                          "assets/svgs/steps.svg",
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(controller.lastSteps.string, style: TypographyStyles.title(20)),
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
    color: Get.isDarkMode?AppColors.primary2Color:Colors.white,
    child: Container(
      margin: EdgeInsets.all(20),
      child: Center(
        child: Text('Live Health Data Sync is Not Enabled. Please enable it in the settings.'),
      ),
    ),
  );
}

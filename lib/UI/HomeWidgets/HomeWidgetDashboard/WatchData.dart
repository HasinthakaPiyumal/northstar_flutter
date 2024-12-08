import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HealthDataModels.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Controllers/WatchDataController.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:im_animations/im_animations.dart';


class WatchData extends StatelessWidget {
  const WatchData({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  Widget build(BuildContext context) {
    WatchDataController controller = WatchDataController(userId);
    controller.init();

    return Scaffold(
      appBar: AppBar(
        title: Text('Watch Data'),
        actions: [
          IconButton(
            onPressed: () {
              controller.init();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(()=> controller.ready.value ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: controller.enabled ? SingleChildScrollView(
          child: Column(
            children: [
              Text('Cloud data from your smart device may take approximately 2 minutes to sync, depending on the network and access conditions.',style: TypographyStyles.text(10),textAlign: TextAlign.center,),
              Obx(() =>
                  Text(controller.statusText.value, style: TextStyle(color: Colors.grey))),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: 190,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Heart Rate'),
                                SizedBox(
                                  height: 20,
                                  child: HeartBeat(
                                    child: Image.asset("assets/icons/heart.png"),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Obx(
                                          () => Text(controller.lastHeartRate.toString(),
                                              style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(' bpm'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                                  child: Container(
                                    height: 80,
                                    child: Obx(
                                      () => SfCartesianChart(
                                        plotAreaBorderWidth: 0,
                                        legend: Legend(isVisible: false),
                                        primaryXAxis:
                                            CategoryAxis(isVisible: false),
                                        primaryYAxis:
                                            NumericAxis(isVisible: false, labelStyle: TextStyle(color: Colors.grey.withOpacity(0.75))),
                                        borderWidth: 1,
                                        tooltipBehavior:
                                            TooltipBehavior(
                                              borderWidth: 0,
                                              enable: true,
                                              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                                                return Card(
                                                  elevation: 4,
                                                  child: Container(
                                                    margin: EdgeInsets.all(0),
                                                    width: 180,
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text('${data.heart} bpm', style: TypographyStyles.boldText(
                                                          12, Colors.black
                                                        )),
                                                        Text('${data.dateTime.toString().split('.')[0]}', style: TypographyStyles.boldText(
                                                          11, Colors.grey
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              ),
                                        series: [
                                          LineSeries<HeartData, String>(
                                            color: Colors.red,
                                            name: 'Heart Rate',
                                            width: 3,
                                            dataSource: controller.heartData.value,
                                            xValueMapper:
                                                (HeartData data, _) =>
                                                    data.index.toString(),
                                            yValueMapper:
                                                (HeartData data, _) =>
                                                    data.heart,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(()=>Text(controller.heartDataStatus.value),)
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: 190,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Body Temperature'),
                                SizedBox(
                                  height: 20,
                                  child: Image.asset("assets/icons/temp.png"),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Obx(
                                          () => Text(controller.lastBodyTemp.toString(),
                                              style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(' °C'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                                  child: Container(
                                    height: 80,
                                    child: Obx(
                                      () => SfCartesianChart(
                                        plotAreaBorderWidth: 0,
                                        legend: Legend(isVisible: false),
                                        primaryXAxis:
                                            CategoryAxis(isVisible: false),
                                        primaryYAxis:
                                            NumericAxis(isVisible: false, labelStyle: TextStyle(color: Colors.grey.withOpacity(0.75))),
                                        borderWidth: 1,
                                        tooltipBehavior:
                                            TooltipBehavior(
                                              borderWidth: 0,
                                              enable: true,
                                              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                                                return Card(
                                                  elevation: 4,
                                                  child: Container(
                                                    margin: EdgeInsets.all(0),
                                                    width: 180,
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(data.temp.toStringAsFixed(2) +'°C', style: TypographyStyles.boldText(
                                                          12, Colors.black
                                                        )),
                                                        Text('${data.dateTime.toString().split('.')[0]}', style: TypographyStyles.boldText(
                                                          11, Colors.grey
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              ),
                                        series: [
                                          LineSeries<TempData, String>(
                                            color: Colors.orange,
                                            name: 'Body Temperature',
                                            width: 3,
                                            dataSource: controller.tempData.value,
                                            xValueMapper:
                                                (TempData data, _) =>
                                                    data.index.toString(),
                                            yValueMapper:
                                                (TempData data, _) =>
                                                    data.temp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(()=>Text(controller.tempDataStatus.value),)
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: 190,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Steps within 24 hours'),
                                SizedBox(
                                  height: 20,
                                  child: Image.asset("assets/icons/steps.png"),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Obx(
                                          () => Text(controller.lastSteps.toString()  + ' (~${((controller.lastSteps)/20).round()}kcal)',
                                              style: TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                                  child: Container(
                                    height: 80,
                                    child: Obx(
                                      () => SfCartesianChart(
                                        plotAreaBorderWidth: 0,
                                        legend: Legend(isVisible: false),
                                        primaryXAxis:
                                            CategoryAxis(isVisible: false),
                                        primaryYAxis:
                                            NumericAxis(isVisible: false, labelStyle: TextStyle(color: Colors.grey.withOpacity(0.75))),
                                        borderWidth: 1,
                                        tooltipBehavior:
                                            TooltipBehavior(
                                              borderWidth: 0,
                                              enable: true,
                                              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                                                return Card(
                                                  elevation: 4,
                                                  child: Container(
                                                    margin: EdgeInsets.all(0),
                                                    width: 180,
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(data.steps.toStringAsFixed(0), style: TypographyStyles.boldText(
                                                          12, Colors.black
                                                        )),
                                                        Text('${data.dateTime.toString().split('.')[0]}', style: TypographyStyles.boldText(
                                                          11, Colors.grey
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              ),
                                        series: [
                                          LineSeries<StepsData, String>(
                                            color: Colors.green,
                                            name: 'Body Temperature',
                                            width: 3,
                                            dataSource: controller.stepsData.value,
                                            xValueMapper:
                                                (StepsData data, _) =>
                                                    data.index.toString(),
                                            yValueMapper:
                                                (StepsData data, _) =>
                                                    data.steps,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(()=>Text(controller.stepsDataStatus.value),)
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ): Center(
          child: Text('Live Health Data Sync is Not Enabled. Please enable it in the settings.'),
        ),
      ): Center(
        child: CircularProgressIndicator(),
      ) ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/PDFDownloadController.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:north_star/components/PdfDownloadButton.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class WeightData {
  WeightData(this.day, this.sales);

  final String day;
  final double sales;
}

class BMIPIData {
  BMIPIData(this.dateTime, this.bmi, this.pi, this.weight, this.height);

  final DateTime dateTime;
  final double bmi;
  final double pi;
  final double weight;
  final double height;
}

class MacroData {
  MacroData(this.dateTime, this.calories, this.carbs, this.protein, this.fat);

  final DateTime dateTime;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
}

class MiscData {
  MiscData(this.dateTime, this.bust, this.stomach, this.calves, this.hips,
      this.thighs, this.lArm, this.rArm);

  final DateTime dateTime;
  final double bust;
  final double stomach;
  final double calves;
  final double hips;
  final double thighs;
  final double lArm;
  final double rArm;
}

class BPData {
  BPData(this.systolic, this.diastolic, this.date);
  final DateTime date;
  final double systolic;
  final double diastolic;
}

class BSData {
  BSData(this.fasting, this.random, this.date);
  final DateTime date;
  final double fasting;
  final double random;
}

class CalorieData {
  CalorieData(this.day, this.calories);

  final String day;
  final double calories;
}

ButtonStyle rounded(int index, int selectedIndex) {
  return TextButton.styleFrom(
    backgroundColor: index == selectedIndex ? Colors.black : Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

TextStyle whiteBlack(int index, int selectedIndex) {
  return TextStyle(color: index == selectedIndex ? Colors.white : Colors.black);
}

class TrainerHealthProgress extends StatelessWidget {
  const TrainerHealthProgress({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  Widget build(BuildContext context) {
    RxInt selected = 0.obs;
    RxMap chartData = {}.obs;
    RxBool ready = false.obs;

    List<BMIPIData> dataBMIPI = [];
    List<MacroData> dataMacro = [];
    List<MiscData> dataMisc = [];
    List<BPData> dataBP = [];
    List<BSData> dataBS = [];

    void getChartData() async {
      Map res = await httpClient.getChartData(userId);
      if (res['code'] == 200) {
        chartData.value = res['data'];
        print(chartData);

        dataBMIPI = List.generate(
            chartData['BMIPIChartData'].length,
                (index) => new BMIPIData(
              DateTime.parse(chartData['BMIPIChartData'][index]['date']),
              double.parse(
                  chartData['BMIPIChartData'][index]['bmi'].toString()),
              double.parse(
                  chartData['BMIPIChartData'][index]['pi'].toString()),
              double.parse(
                  chartData['BMIPIChartData'][index]['weight'].toString()),
              double.parse(
                  chartData['BMIPIChartData'][index]['height'].toString()),
            ));

        dataMacro = List.generate(
            chartData['MacroChartData'].length,
                (index) => new MacroData(
              DateTime.parse(chartData['MacroChartData'][index]['date']),
              double.parse(chartData['MacroChartData'][index]['calories']
                  .toString()),
              double.parse(
                  chartData['MacroChartData'][index]['carbs'].toString()),
              double.parse(
                  chartData['MacroChartData'][index]['protein'].toString()),
              double.parse(
                  chartData['MacroChartData'][index]['fat'].toString()),
            ));

        dataMisc = List.generate(
          chartData['MiscChartData'].length,
              (index) => new MiscData(
            DateTime.parse(chartData['MiscChartData'][index]['date']),
            double.parse(chartData['MiscChartData'][index]['bust'].toString()),
            double.parse(
                chartData['MiscChartData'][index]['stomach'].toString()),
            double.parse(
                chartData['MiscChartData'][index]['calves'].toString()),
            double.parse(chartData['MiscChartData'][index]['hips'].toString()),
            double.parse(
              chartData['MiscChartData'][index]['thighs'].toString(),
            ),
            double.parse(chartData['MiscChartData'][index]['l_arm'].toString()),
            double.parse(chartData['MiscChartData'][index]['r_arm'].toString()),
          ),
        );

        dataBS = List.generate(
          chartData['BSChartData'].length,
              (index) => new BSData(
            double.parse(chartData['BSChartData'][index]['fasting'].toString()),
            double.parse(chartData['BSChartData'][index]['random'].toString()),
            DateTime.parse(chartData['BSChartData'][index]['date']),
          ),
        );
        dataBP = List.generate(
            chartData['BPChartData'].length,
                (index) => new BPData(
              double.parse(
                  chartData['BPChartData'][index]['systolic'].toString()),
              double.parse(
                  chartData['BPChartData'][index]['diastolic'].toString()),
              DateTime.parse(chartData['BPChartData'][index]['date']),
            ));

        ready.value = true;
      } else {
        print(res);
      }
    }

    getChartData();

    return Scaffold(
      body: SingleChildScrollView(
        child: Obx(() => ready.value
            ? Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Get.isDarkMode
                      ? AppColors.primary2Color
                      : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Height/Weight",
                              style: TypographyStyles.title(20),
                            ),
                            Text(
                              "Last 30 Days",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Get.height / 3.5,
                        child: SfCartesianChart(
                          legend: Legend(
                              isVisible: true,
                              position: LegendPosition.top),
                          primaryXAxis: CategoryAxis(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: [
                            LineSeries<BMIPIData, String>(
                              color: Colors.blue,
                              name: 'Height  (cm)',
                              width: 3,
                              dataSource: dataBMIPI,
                              xValueMapper: (BMIPIData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (BMIPIData data, _) =>
                              data.height,
                            ),
                            LineSeries<BMIPIData, String>(
                              color: Colors.red,
                              name: 'Weight (kg)',
                              width: 3,
                              dataSource: dataBMIPI,
                              xValueMapper: (BMIPIData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (BMIPIData data, _) =>
                              data.weight,
                            ),
                          ],
                        ),
                      ),
                      PdfDownloadButton(
                        tableName: "Height-Weight-${userId}",
                        tableData: List.generate(
                          dataBMIPI.length + 1,
                              (index) {
                            if (index == 0)
                              return [
                                "Date",
                                "Height (cm)",
                                "Weight (kg)"
                              ];
                            index -= 1;
                            return [
                              DateFormat("dd MMM").format(dataBMIPI[index].dateTime),
                              dataBMIPI[index].height.toString(),
                              dataBMIPI[index].weight.toString(),
                            ];
                          },
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Get.isDarkMode
                      ? AppColors.primary2Color
                      : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "BMI/PI",
                              style: TypographyStyles.title(20),
                            ),
                            Text(
                              "Last 30 Days",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Get.height / 3.5,
                        child: SfCartesianChart(
                          legend: Legend(
                              isVisible: true,
                              position: LegendPosition.top),
                          primaryXAxis: CategoryAxis(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: [
                            LineSeries<BMIPIData, String>(
                              color: Color(0xFF62e998),
                              name: 'BMI',
                              width: 3,
                              dataSource: dataBMIPI,
                              xValueMapper: (BMIPIData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (BMIPIData data, _) =>
                              data.bmi,
                            ),
                            LineSeries<BMIPIData, String>(
                              color: Color(0xffffbd20),
                              name: 'PI',
                              width: 3,
                              dataSource: dataBMIPI,
                              xValueMapper: (BMIPIData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (BMIPIData data, _) =>
                              data.pi,
                            )
                          ],
                        ),
                      ),
                      PdfDownloadButton(
                        tableName: "BMI-PI-${userId}",
                        tableData: List.generate(
                          dataBMIPI.length + 1,
                              (index) {
                            if (index == 0)
                              return [
                                "Date",
                                "BMI",
                                "PI"
                              ];
                            index -= 1;
                            return [
                              DateFormat("dd MMM").format(dataBMIPI[index].dateTime),
                              dataBMIPI[index].bmi.toString(),
                              dataBMIPI[index].pi.toString(),
                            ];
                          },
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Get.isDarkMode
                      ? AppColors.primary2Color
                      : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Calorie intake",
                              style: TypographyStyles.title(20),
                            ),
                            Text(
                              "Last 30 Days",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Get.height / 4,
                        child: SfCartesianChart(
                          legend: Legend(
                              isVisible: true,
                              position: LegendPosition.top),
                          primaryXAxis: CategoryAxis(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: [
                            LineSeries<MacroData, String>(
                              name: 'Calories (kcal)',
                              color: Color(0xFF5576E3),
                              width: 3,
                              dataSource: dataMacro,
                              xValueMapper: (MacroData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MacroData data, _) =>
                              data.calories,
                            ),
                          ],
                        ),
                      ),
                      PdfDownloadButton(
                        tableName: "Calorie intake-${userId}",
                        tableData: List.generate(
                          dataMacro.length + 1,
                              (index) {
                            if (index == 0)
                              return [
                                "Date",
                                "Calories (kcal)"
                              ];
                            index -= 1;
                            return [
                              DateFormat("dd MMM").format(dataMacro[index].dateTime),
                              dataMacro[index].calories.toString(),
                            ];
                          },
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Get.isDarkMode
                      ? AppColors.primary2Color
                      : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Macro Data",
                              style: TypographyStyles.title(20),
                            ),
                            Text(
                              "Last 30 Days",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Get.height / 3,
                        child: SfCartesianChart(
                          legend: Legend(
                              isVisible: true,
                              position: LegendPosition.top),
                          primaryXAxis: CategoryAxis(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: [
                            LineSeries<MacroData, String>(
                              name: 'Carbs (g)',
                              color: Color(0xFFF5BB1D),
                              width: 3,
                              dataSource: dataMacro,
                              xValueMapper: (MacroData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MacroData data, _) =>
                              data.carbs,
                            ),
                            LineSeries<MacroData, String>(
                              name: 'Proteins (g)',
                              color: Color(0xFFEC2F2F),
                              width: 3,
                              dataSource: dataMacro,
                              xValueMapper: (MacroData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MacroData data, _) =>
                              data.protein,
                            ),
                            LineSeries<MacroData, String>(
                              name: 'Fats (g)',
                              color: Color(0xFF1FC52A),
                              width: 3,
                              dataSource: dataMacro,
                              xValueMapper: (MacroData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MacroData data, _) =>
                              data.fat,
                            ),
                          ],
                        ),
                      ),
                      PdfDownloadButton(
                        tableName: "Macro data-${userId}",
                        tableData: List.generate(
                          dataMacro.length + 1,
                              (index) {
                            if (index == 0)
                              return [
                                "Date",
                                "Carbs (g)",
                                "Proteins (g)",
                                "Fats (g)"
                              ];
                            index -= 1;
                            return [
                              DateFormat("dd MMM").format(dataMacro[index].dateTime),
                              dataMacro[index].carbs.toString(),
                              dataMacro[index].protein.toString(),
                              dataMacro[index].fat.toString(),
                            ];
                          },
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Get.isDarkMode
                      ? AppColors.primary2Color
                      : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Misc data",
                              style: TypographyStyles.title(20),
                            ),
                            Text(
                              "Last 30 Days",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Get.height / 3,
                        child: SfCartesianChart(
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.top,
                            height: "50%",
                          ),
                          primaryXAxis: CategoryAxis(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: [
                            LineSeries<MiscData, String>(
                              color: Colors.green,
                              width: 3,
                              name: 'Bust (mm)',
                              dataSource: dataMisc,
                              xValueMapper: (MiscData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MiscData data, _) =>
                              data.bust,
                            ),
                            LineSeries<MiscData, String>(
                              color: Colors.white,
                              width: 3,
                              name: 'Stomach (mm)',
                              dataSource: dataMisc,
                              xValueMapper: (MiscData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MiscData data, _) =>
                              data.stomach,
                            ),
                            LineSeries<MiscData, String>(
                              color: Colors.deepPurple,
                              width: 3,
                              name: 'Calves (mm)',
                              dataSource: dataMisc,
                              xValueMapper: (MiscData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MiscData data, _) =>
                              data.calves,
                            ),
                            LineSeries<MiscData, String>(
                              color: Colors.pink,
                              width: 3,
                              name: 'Hips (mm)',
                              dataSource: dataMisc,
                              xValueMapper: (MiscData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MiscData data, _) =>
                              data.hips,
                            ),
                            LineSeries<MiscData, String>(
                              color: Colors.yellow,
                              width: 3,
                              name: 'Thighs (mm)',
                              dataSource: dataMisc,
                              xValueMapper: (MiscData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MiscData data, _) =>
                              data.thighs,
                            ),
                            LineSeries<MiscData, String>(
                              color: Colors.red,
                              width: 3,
                              name: 'Left Arm (mm)',
                              dataSource: dataMisc,
                              xValueMapper: (MiscData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MiscData data, _) =>
                              data.lArm,
                            ),
                            LineSeries<MiscData, String>(
                              color: Colors.blue,
                              width: 3,
                              name: 'Right Arm (mm)',
                              dataSource: dataMisc,
                              xValueMapper: (MiscData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.dateTime)
                                      .toString(),
                              yValueMapper: (MiscData data, _) =>
                              data.rArm,
                            ),
                          ],
                        ),
                      ),
                      PdfDownloadButton(
                        tableName: "Misc data-${userId}",
                        tableData: List.generate(
                          dataMisc.length + 1,
                              (index) {
                            if (index == 0)
                              return [
                                "Date",
                                "Bust (mm)",
                                "Stomach (mm)",
                                "Calves (mm)"
                              ];
                            index -= 1;
                            return [
                              DateFormat("dd MMM").format(dataMisc[index].dateTime),
                              dataMisc[index].bust.toString(),
                              dataMisc[index].stomach.toString(),
                              dataMisc[index].calves.toString(),
                            ];
                          },
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Get.isDarkMode
                      ? AppColors.primary2Color
                      : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Blood Pressure",
                              style: TypographyStyles.title(20),
                            ),
                            Text(
                              "Last 30 Days",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Get.height / 3,
                        child: SfCartesianChart(
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.top,
                            height: "50%",
                          ),
                          primaryXAxis: CategoryAxis(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: [
                            LineSeries<BPData, String>(
                              color: Colors.green,
                              width: 3,
                              name: 'Systolic (mmHg)',
                              dataSource: dataBP,
                              xValueMapper: (BPData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.date)
                                      .toString(),
                              yValueMapper: (BPData data, _) =>
                              data.systolic,
                            ),
                            LineSeries<BPData, String>(
                              color: Colors.red,
                              width: 3,
                              name: 'Diastolic (mmHg)',
                              dataSource: dataBP,
                              xValueMapper: (BPData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.date)
                                      .toString(),
                              yValueMapper: (BPData data, _) =>
                              data.diastolic,
                            ),
                          ],
                        ),
                      ),
                      PdfDownloadButton(
                        tableName: "Blood Pressure-${userId}",
                        tableData: List.generate(
                          dataBP.length + 1,
                              (index) {
                            if (index == 0)
                              return [
                                "Date",
                                "Systolic (mmHg)",
                                "Diastolic (mmHg)"
                              ];
                            index -= 1;
                            return [
                              DateFormat("dd MMM").format(dataBP[index].date),
                              dataBP[index].systolic.toString(),
                              dataBP[index].diastolic.toString(),
                            ];
                          },
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Get.isDarkMode
                      ? AppColors.primary2Color
                      : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Blood Sugar",
                              style: TypographyStyles.title(20),
                            ),
                            Text(
                              "Last 30 Days",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Get.height / 3,
                        child: SfCartesianChart(
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.top,
                            height: "50%",
                          ),
                          primaryXAxis: CategoryAxis(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: [
                            LineSeries<BSData, String>(
                              color: Colors.green,
                              width: 3,
                              name: 'Fasting Blood Sugar (mg/dl)',
                              dataSource: dataBS,
                              xValueMapper: (BSData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.date)
                                      .toString(),
                              yValueMapper: (BSData data, _) =>
                              data.fasting,
                            ),
                            LineSeries<BSData, String>(
                              color: Colors.white,
                              width: 3,
                              name: 'Post Blood Sugar (mg/dl)',
                              dataSource: dataBS,
                              xValueMapper: (BSData data, _) =>
                                  DateFormat("dd MMM")
                                      .format(data.date)
                                      .toString(),
                              yValueMapper: (BSData data, _) =>
                              data.random,
                            ),
                          ],
                        ),
                      ),
                      PdfDownloadButton(
                        tableName: "Blood Sugar-${userId}",
                        tableData: List.generate(
                          dataBS.length + 1,
                              (index) {
                            if (index == 0)
                              return [
                                "Date",
                                "Fasting Blood Sugar",
                                "Post Blood Sugar"
                              ];
                            index -= 1;
                            return [
                              dataBS[index].date.toIso8601String(),
                              dataBS[index].fasting.toString(),
                              dataBS[index].random.toString(),
                            ];
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        )
            : LoadingAndEmptyWidgets.loadingWidget()),
      ),
    );
  }
}

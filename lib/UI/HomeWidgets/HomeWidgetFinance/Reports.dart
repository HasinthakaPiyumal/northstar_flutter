import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Reports extends StatelessWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Rx<DateTime> selectedStartDate = DateTime(DateTime.now().year, 1, 1).obs;
    Rx<DateTime> selectedEndDate = DateTime(DateTime.now().year, 12, 31).obs;

    RxBool isReady = false.obs;

    RxInt totalIncome = 0.obs;
    RxInt totalExpense = 0.obs;

    RxList<IncomeData> incomeChartData = <IncomeData>[].obs;
    RxList<ExpensesData> expensesChartData = <ExpensesData>[].obs;
    List<TaxData> taxChartData = [
      TaxData(DateTime.parse("2023-03-01"), 30),
      TaxData(DateTime.parse("2023-04-01"), 100),
      TaxData(DateTime.parse("2023-05-01"), 120),
      TaxData(DateTime.parse("2023-06-01"), 200),
      TaxData(DateTime.parse("2023-07-01"), 370),
    ];

    void getFinanceReport()async{
      isReady.value = false;
      String formattedStartDate = DateFormat('yyyy/MM/dd').format(selectedStartDate.value);
      String formattedEndDate = DateFormat('yyyy/MM/dd').format(selectedEndDate.value);
      dynamic data = {'from':formattedStartDate,'to':formattedEndDate};
      Map res = await httpClient.getFinanceReport(data);
      print("====finance data report");
      print(data);
      if(res['code']==200){
        print(res['data']);
        totalIncome.value = res['data']['total_income'];
        totalExpense.value = res['data']['total_expense'];
        incomeChartData.clear();
        expensesChartData.clear();
        res['data']['report_data'].forEach((report){
          incomeChartData.add(IncomeData(DateTime.parse(report['start_date']), report['total_income'].toDouble()));
          expensesChartData.add(ExpensesData(DateTime.parse(report['start_date']), report['total_expense'].toDouble()));
        });
        isReady.value = true;
      }else{
        print(res);
      }
    }
    getFinanceReport();

    return Scaffold(
      appBar: AppBar(title: Text("Reports"),),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: (){

                final DateRangePickerController _controller = DateRangePickerController();

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    actionsPadding: EdgeInsets.zero,
                    titlePadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: SizedBox(
                      height: Get.height/2.5,
                      width: Get.width,
                      child: SfDateRangePicker(
                        controller: _controller,
                        onSelectionChanged: (DateRangePickerSelectionChangedArgs args){
                          if(args.value is PickerDateRange){
                            selectedStartDate.value = args.value.startDate ?? DateTime.now();
                            selectedEndDate.value = args.value.endDate ?? DateTime.now();
                          }
                        },
                        initialSelectedRange: PickerDateRange(selectedEndDate.value,selectedStartDate.value),
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          textStyle: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                          disabledDatesTextStyle: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1).withOpacity(0.5),),
                          todayTextStyle: TypographyStyles.normalText(16, Themes.mainThemeColor.shade500),
                        ),
                        selectionMode: DateRangePickerSelectionMode.extendableRange,
                        headerStyle: DateRangePickerHeaderStyle(
                          textStyle: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                        ),
                        showNavigationArrow: true,
                        monthViewSettings: DateRangePickerMonthViewSettings(
                          dayFormat: 'EEE',
                        ),
                      ),
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actionsOverflowButtonSpacing: 10,
                    actions: [
                      SizedBox(
                        width: Get.width,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: MaterialButton(
                            onPressed: (){
                              getFinanceReport();
                              Get.back();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: colors.Colors().lightBlack(1),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text("DONE",
                                style: TypographyStyles.boldText(16, Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                // color: colors.Colors().darkGrey(1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date Range",
                            style: TypographyStyles.normalText(14, Colors.white),
                          ),
                          SizedBox(height: 5,),
                          Obx(() => Text("${DateFormat("yyyy/MM/dd").format(selectedStartDate.value)}  to  ${DateFormat("yyyy/MM/dd").format(selectedEndDate.value)}",
                            style: TypographyStyles.boldText(16, Colors.white),
                          ),),
                        ],
                      ),
                      Icon(Icons.calendar_today_outlined)
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30,),

          Obx(()=> Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Profit Earned",
                    style: TypographyStyles.normalText(16, colors.Colors().lightWhite(0.5)),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "MVR ",
                      style: TypographyStyles.normalText(16, Get.isDarkMode ? Colors.white : Colors.black),
                      children: [
                        TextSpan(
                          text: Utils.currencyFmt.format(totalIncome.value-totalExpense.value),
                          style: TypographyStyles.title(24),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20,),
          Obx(()=> Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: 2,
                            child: Icon(Icons.arrow_upward, color: Colors.red, size: 18),
                          ),
                          SizedBox(width: 5,),
                          Text("Expenses",
                            style: TypographyStyles.normalText(14, Color(0xFF8D8D8D)),
                          )
                        ],
                      ),
                      SizedBox(height: 4,),
                      RichText(
                        text: TextSpan(
                            text: "MVR ",
                            style: TypographyStyles.normalText(14, Get.isDarkMode ? Colors.white : Colors.black),
                            children: [
                              TextSpan(
                                text: Utils.currencyFmt.format(totalExpense.value),
                                style: TypographyStyles.title(18),
                              ),
                            ]
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: 1,
                            child: Icon(Icons.arrow_upward, color: Colors.green, size: 18),
                          ),
                          SizedBox(width: 5,),
                          Text("Income",
                            style: TypographyStyles.normalText(14, Color(0xFF8D8D8D)),
                          )
                        ],
                      ),
                      SizedBox(height: 4,),
                      RichText(
                        text: TextSpan(
                            text: "MVR ",
                            style: TypographyStyles.normalText(14, Get.isDarkMode ? Colors.white : Colors.black),
                            children: [
                              TextSpan(
                                text: Utils.currencyFmt.format(totalIncome.value),
                                style: TypographyStyles.title(18),
                              ),
                            ]
                        ),
                      ),
                    ],
                  ),
                  // Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Transform.rotate(
                  //           angle: 2,
                  //           child: Icon(Icons.arrow_upward, color: Colors.yellow, size: 18),
                  //         ),
                  //         SizedBox(width: 5,),
                  //         Text("Tax",
                  //           style: TypographyStyles.normalText(14, Color(0xFF8D8D8D)),
                  //         )
                  //       ],
                  //     ),
                  //     SizedBox(height: 4,),
                  //     RichText(
                  //       text: TextSpan(
                  //           text: "MVR",
                  //           style: TypographyStyles.normalText(14, Get.isDarkMode ? Colors.white : Colors.black),
                  //           children: [
                  //             TextSpan(
                  //               text: Utils.currencyFmt.format(1275),
                  //               style: TypographyStyles.title(18),
                  //             ),
                  //           ]
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30,),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Obx(()=> Text("Income and Expenses",
                style: TypographyStyles.boldText(16, Get.isDarkMode ? colors.Colors().lightWhite(0.6) : Colors.black),
              ),
            ),
          ),

          SizedBox(height: 15,),

         Obx(()=> isReady.value?SizedBox(
                height: Get.height/100*40,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: Get.isDarkMode?AppColors.primary1Color:AppColors.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SfCartesianChart(
                        legend: Legend(
                          isVisible: true,
                          alignment: ChartAlignment.far,
                          orientation: LegendItemOrientation.horizontal,
                          position: LegendPosition.bottom,
                          toggleSeriesVisibility: true,
                          textStyle: TypographyStyles.text(10),
                        ),
                        tooltipBehavior: TooltipBehavior(
                          activationMode: ActivationMode.singleTap,
                          enable: true,
                          color: Get.isDarkMode?AppColors.primary2Color:AppColors.baseColor,
                          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Get.isDarkMode?AppColors.primary2Color:AppColors.baseColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Date : ${DateFormat("dd, MMM-yyyy").format(data.date)}",
                                      style: TypographyStyles.boldText(8, Colors.white),
                                    ),
                                    Text(
                                      "Value : ${data.value} MVR",
                                      style: TypographyStyles.boldText(8, Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        primaryXAxis: DateTimeAxis(
                          title: AxisTitle(
                            //text: "Date",
                            textStyle: TypographyStyles.boldText(10, Colors.white),
                            alignment: ChartAlignment.center,
                          ),
                          majorGridLines: const MajorGridLines(width: 0),
                          labelStyle: TypographyStyles.boldText(8, Colors.white),
                          isVisible: true,
                        ),
                        primaryYAxis: CategoryAxis(
                          title: AxisTitle(
                            //text: "Value - Rf",
                            textStyle: TypographyStyles.boldText(10, Colors.white),
                            alignment: ChartAlignment.center,
                          ),
                          labelStyle: TypographyStyles.boldText(8, Colors.white),
                          isVisible: true,
                          minimum: 3,
                        ),
                        palette: const [
                          Colors.green,
                          Colors.teal,
                        ],
                        series: [
                          SplineSeries<IncomeData, DateTime>(
                            dataSource: incomeChartData.value,
                            xValueMapper: (IncomeData data, _) => data.date,
                            yValueMapper: (IncomeData data, _) => data.value,
                            markerSettings: MarkerSettings(
                              isVisible: true,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            name: "Income",
                          ),
                          SplineSeries<ExpensesData, DateTime>(
                            dataSource: expensesChartData,
                            xValueMapper: (ExpensesData data, _) => data.date,
                            yValueMapper: (ExpensesData data, _) => data.value,
                            markerSettings: MarkerSettings(
                              isVisible: true,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            name: "Expenses",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ):Container(height:Get.height/100*40,child: Center(child: LoadingAndEmptyWidgets.loadingWidget())),
         ),


          SizedBox(height: 20,),

          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16),
          //   child: Text("Tax",
          //     style: TypographyStyles.boldText(16, Get.isDarkMode ? colors.Colors().lightWhite(0.6) : Colors.black),
          //   ),
          // ),

          SizedBox(height: 15,),

          // SizedBox(
          //   height: Get.height/100*30,
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 16),
          //     child: Card(
          //       margin: EdgeInsets.zero,
          //       color: colors.Colors().lightBlack(1),
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12)
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.all(16),
          //         child: SfCartesianChart(
          //           legend: Legend(
          //             isVisible: true,
          //             alignment: ChartAlignment.far,
          //             orientation: LegendItemOrientation.horizontal,
          //             position: LegendPosition.bottom,
          //             toggleSeriesVisibility: true,
          //             textStyle: TypographyStyles.text(10),
          //           ),
          //           tooltipBehavior: TooltipBehavior(
          //             activationMode: ActivationMode.singleTap,
          //             enable: true,
          //             color: colors.Colors().lightBlack(1),
          //             builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
          //               return Container(
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(12),
          //                   color: colors.Colors().lightBlack(1),
          //                 ),
          //                 child: Padding(
          //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //                   child: Column(
          //                     mainAxisSize: MainAxisSize.min,
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Text(
          //                         "Date : ${DateFormat("dd, MMM-yyyy").format(data.date)}",
          //                         style: TypographyStyles.boldText(8, Colors.white),
          //                       ),
          //                       Text(
          //                         "Value : ${data.value} Rf",
          //                         style: TypographyStyles.boldText(8, Colors.white),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               );
          //             },
          //           ),
          //           primaryXAxis: DateTimeAxis(
          //             title: AxisTitle(
          //               //text: "Date",
          //               textStyle: TypographyStyles.boldText(10, Colors.white),
          //               alignment: ChartAlignment.center,
          //             ),
          //             majorGridLines: const MajorGridLines(width: 0),
          //             labelStyle: TypographyStyles.boldText(8, Colors.white),
          //             isVisible: true,
          //           ),
          //           primaryYAxis: CategoryAxis(
          //             title: AxisTitle(
          //               //text: "Value - Rf",
          //               textStyle: TypographyStyles.boldText(10, Colors.white),
          //               alignment: ChartAlignment.center,
          //             ),
          //             labelStyle: TypographyStyles.boldText(8, Colors.white),
          //             isVisible: true,
          //           ),
          //           palette: const [
          //             Colors.yellow,
          //           ],
          //           series: [
          //             SplineSeries<TaxData, DateTime>(
          //               dataSource: taxChartData,
          //               xValueMapper: (TaxData data, _) => data.date,
          //               yValueMapper: (TaxData data, _) => data.value,
          //               markerSettings: MarkerSettings(
          //                 isVisible: true,
          //                 color: Theme.of(context).colorScheme.secondary,
          //               ),
          //               name: "Tax",
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          //
          // SizedBox(height: 20,),
        ],
      ),
    );
  }
}

class IncomeData {
  IncomeData(this.date, this.value);
  final DateTime date;
  final double value;
}

class ExpensesData {
  ExpensesData(this.date, this.value);
  final DateTime date;
  final double value;
}

class TaxData {
  TaxData(this.date, this.value);
  final DateTime date;
  final double value;
}

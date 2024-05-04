import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../Styles/AppColors.dart';
import '../../../Styles/Themes.dart';
import '../../../components/Buttons.dart';

class Transactions extends StatelessWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;
    RxList transactionsAll = [].obs;
    RxList transactions = [].obs;

    Rx<DateTime> selectedStartDate = DateTime.now().obs;
    Rx<DateTime> selectedEndDate = DateTime.now().obs;

    final DateRangePickerController _controller = DateRangePickerController();

    void getTransactions() async{
      ready.value = false;
      Map res = await httpClient.getTransactions();
      if (res['code'] == 200) {
        transactions.value = res['data'];
        transactionsAll.value = res['data'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    List filterTransactionsByDate(DateTime startDate, DateTime endDate) {
      return transactionsAll.where((report) {
        DateTime reportDate = DateTime.parse(report['created_at']);
        DateTime reportDateWithoutTime = DateTime(reportDate.year, reportDate.month, reportDate.day);

        // Include reports with the same date as start or end date
        return (reportDateWithoutTime.isAtSameMomentAs(startDate) ||
            reportDateWithoutTime.isAfter(startDate)) &&
            (reportDateWithoutTime.isAtSameMomentAs(endDate) ||
                reportDateWithoutTime.isBefore(endDate));
      }).toList();
    }

    getTransactions();

    return Scaffold(
      appBar: AppBar(
        title: Text("Recent Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: (){
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
                        initialSelectedRange: PickerDateRange(selectedStartDate.value,selectedEndDate.value),
                        onSelectionChanged: (DateRangePickerSelectionChangedArgs args){
                          if(args.value is PickerDateRange){
                            selectedStartDate.value = args.value.startDate ?? DateTime.now();
                            selectedEndDate.value = args.value.endDate ?? DateTime.now();
                          }
                        },

                        monthCellStyle: DateRangePickerMonthCellStyle(
                          textStyle: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                          disabledDatesTextStyle: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1).withOpacity(0.5),),
                          todayTextStyle: TypographyStyles.normalText(16, Themes.mainThemeColor.shade500),
                        ),
                        selectionMode: DateRangePickerSelectionMode.extendableRange,
                        headerStyle: DateRangePickerHeaderStyle(
                          textStyle: TypographyStyles.boldText(20, Get.isDarkMode ? Colors.white : Colors.black,),
                        ),
                        showNavigationArrow: true,
                      ),
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actionsOverflowButtonSpacing: 10,
                    actions: [
                      SizedBox(
                        width: Get.width,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Buttons.outlineButton(onPressed: (){
                            transactions.value = transactionsAll.value;
                            selectedEndDate.value = DateTime.now();
                            selectedStartDate.value = DateTime.now();
                            Get.back();
                            },label: "Clear"),
                        ),
                      ),SizedBox(
                        width: Get.width,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Buttons.yellowFlatButton(onPressed: (){
                            transactions.value = filterTransactionsByDate(selectedStartDate.value, selectedEndDate.value);
                            Get.back();
                            },label: "Done"),
                        ),
                      )
                    ],
                  ),
                );
              },
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: Get.isDarkMode?AppColors.primary2Color:Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20,),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Download Transaction Summary",
                        style: TypographyStyles.title(16),
                      ),
                      SizedBox(height: 16,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text("${DateFormat("yyyy/MM/dd").format(selectedStartDate.value)}  to  ${DateFormat("yyyy/MM/dd").format(selectedEndDate.value)}",
                            style: TypographyStyles.text(14),
                          ),),

                          Icon(Icons.calendar_today_outlined,color: AppColors.accentColor,),
                        ],
                      ),
                      SizedBox(height: 16,),
                      Buttons.yellowTextIconButton(onPressed: (){},width: Get.width,label: "Download report",icon:Icons.download_rounded,svg:"assets/svgs/download.svg")
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: Obx(() => ready.value ? transactions.isNotEmpty ? ListView.separated(
                shrinkWrap: true,
                itemCount: transactions.length,
                separatorBuilder: (context, index){
                  return SizedBox(height: 8,);
                },
                itemBuilder: (context,index){
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors().getSecondaryColor(),borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: Text('${transactions[index]['type']} - ${transactions[index]['description']}',
                                    style: TypographyStyles.normalText(16, Get.isDarkMode ? Colors.white : Colors.black),
                                  ),
                                  width: Get.width/100*70,
                                ),
                                SizedBox(height: 8,),
                                Text("${DateFormat("MMM dd,yyyy - HH:mm").format(DateTime.parse(transactions[index]['created_at']).toLocal())}",
                                  style: TypographyStyles.text(14),
                                )
                              ],
                            ),
                          ),
                          Text((Utils.formatCurrency.format(transactions[index]['amount'])).toString(),style: TypographyStyles.walletTransactions(16, transactions[index]['type']),),
                        ],
                      ),
                    ),
                  );
                },
              ) : LoadingAndEmptyWidgets.emptyWidget() : LoadingAndEmptyWidgets.loadingWidget()),
            ),
          ],
        ),
      )
    );
  }
}

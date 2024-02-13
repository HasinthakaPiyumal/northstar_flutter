import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetLabReports/CreateLabReport.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetLabReports/ViewLabReportAttachment.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:intl/intl.dart';

class HomeWidgetLabReports extends StatelessWidget {
  const HomeWidgetLabReports({Key? key, this.userID}) : super(key: key);
  final userID;

  @override
  Widget build(BuildContext context) {
    RxList labReports = [].obs;
    RxList labReportsAll = [].obs;

    Rx<DateTime> selectedStartDate = DateTime.now().obs;
    Rx<DateTime> selectedEndDate = DateTime.now().obs;

    final DateRangePickerController _controller = DateRangePickerController();

    void getLabReports() async {
      int id = authUser.id;
      if(userID != null) {
        id = userID;
      }
      Map res = await httpClient.getLabReports({
        'client_id': id,
      });
      print(authUser.id);
      print(res);
      if (res['code'] == 200) {
        labReports.value = res['data'];
        labReportsAll.value = res['data'];
        labReportsAll.forEach((report) {
          DateTime reportDate = DateTime.parse(report['report_date']);
          if(reportDate.isBefore(selectedStartDate.value)){
            selectedStartDate.value = reportDate;
          }
          if(reportDate.isAfter(selectedEndDate.value)){
            selectedEndDate.value = reportDate;
          }
        });
      } else {
        print(res);
      }
    }

    void deleteLabReport(id,fileName) async {

      Map res = await httpClient.deleteLabReports({
        'id': id,
        'filePath':'lab-reports/' +fileName,
      });
      print(res);
      if (res['code'] == 200) {
        getLabReports();
      } else {
        print(res);
      }
    }
    List filterLabReportsByDateRange(DateTime startDate, DateTime endDate) {
      return labReportsAll.where((report) {
        DateTime reportDate = DateTime.parse(report['report_date']);
        DateTime reportDateWithoutTime = DateTime(reportDate.year, reportDate.month, reportDate.day);

        // Include reports with the same date as start or end date
        return (reportDateWithoutTime.isAtSameMomentAs(startDate) ||
            reportDateWithoutTime.isAfter(startDate)) &&
            (reportDateWithoutTime.isAtSameMomentAs(endDate) ||
                reportDateWithoutTime.isBefore(endDate));
      }).toList();
    }


    getLabReports();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Reports'),
      ),
      floatingActionButton: userID == null ? FloatingActionButton.extended(
        onPressed: (){
          Get.to(() => CreateLabReport())?.then((value){
            getLabReports();
          });
        },
        label: Text("Add New",style: TextStyle(color: AppColors.textOnAccentColor),),
        icon: Icon(Icons.add,color: AppColors.textOnAccentColor,),
        backgroundColor: AppColors.accentColor,
        extendedPadding: EdgeInsets.symmetric(horizontal: 15,),
      ):null,
      body: Obx(()=>Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(

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
                            child: MaterialButton(
                              onPressed: (){
                                labReports.value = filterLabReportsByDateRange(selectedStartDate.value, selectedEndDate.value);
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
                  color: AppColors.primary2Color,
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
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollBehavior(),
                child: GlowingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  color: Colors.black12,
                  child: labReports.isNotEmpty ? ListView.builder(
                    itemCount: labReports.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Get.isDarkMode?AppColors.primary1Color:Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        margin: EdgeInsets.only(top: 15),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: (){
                                  CommonConfirmDialog.confirm("remove").then((value){
                                    if(value){
                                      deleteLabReport(labReports[index]['id'],labReports[index]['report_url']);
                                    }
                                  });
                                },
                                icon: Icon(Icons.delete,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${labReports[index]['report_date']}'),
                                  SizedBox(height: 16),
                                  Text("${labReports[index]['report_name']}",
                                    style: TypographyStyles.title(16),
                                  ),
                                  SizedBox(height: 8),
                                  Text('${labReports[index]['report_description']}', style: TypographyStyles.text(14).copyWith(color: Themes.mainThemeColorAccent.shade300)),
                                  SizedBox(height: 8),
                                  Text('Report Result',
                                    style: TypographyStyles.boldText(14, Colors.white),
                                  ),
                                  Text(labReports[index]['report_result'].toString(),
                                    style: TypographyStyles.boldText(16, colors.Colors().deepYellow(1)),
                                  ),
                                  SizedBox(height: 8),
                                  Divider(thickness: 1,),
                                  SizedBox(height: 8),
                                  Container(
                                    width: Get.width,
                                    child: TextButton(
                                      onPressed: (){
                                        //print(HttpClient.s3LabReportsBaseUrl + labReports[index]['report_url']);
                                        //launchUrl(Uri.parse(HttpClient.s3LabReportsBaseUrl + labReports[index]['report_url']));
                                        Get.to(()=>ViewLabReportAttachment(url: HttpClient.s3LabReportsBaseUrl + labReports[index]['report_url']));
                                      },
                                      style: ButtonStyles.matButton(colors.Colors().darkGrey(1), 0),
                                      child: Text(
                                        "View Report Attachment",
                                        style: TypographyStyles.boldText(15, Colors.white),
                                      ),
                                    ),
                                  ),
              
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ) : LoadingAndEmptyWidgets.emptyWidget(),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

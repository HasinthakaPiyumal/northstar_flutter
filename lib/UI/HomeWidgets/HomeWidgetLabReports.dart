import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetLabReports/CreateLabReport.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetLabReports/ViewLabReportAttachment.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

import '../../Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class HomeWidgetLabReports extends StatelessWidget {
  const HomeWidgetLabReports({Key? key, this.userID}) : super(key: key);
  final userID;

  @override
  Widget build(BuildContext context) {
    RxList labReports = [].obs;

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
        label: Text("Add New"),
        icon: Icon(Icons.add),
        backgroundColor: colors.Colors().deepYellow(1),
        extendedPadding: EdgeInsets.symmetric(horizontal: 15,),
      ):null,
      body: Obx(()=>Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.black12,
            child: labReports.isNotEmpty ? ListView.builder(
              itemCount: labReports.length,
              itemBuilder: (context, index) {
                return Card(
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
      )),
    );
  }
}

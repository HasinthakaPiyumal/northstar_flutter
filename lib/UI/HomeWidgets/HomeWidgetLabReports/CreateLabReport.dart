

import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetLabReports/ReportTypesList.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class CreateLabReport extends StatelessWidget {
  const CreateLabReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    RxBool ready = true.obs;
    RxBool selected = false.obs;

    var xFile;

    TextEditingController reportName = TextEditingController();
    TextEditingController reportResult = TextEditingController();
    TextEditingController reportType = TextEditingController();
    TextEditingController reportDate = TextEditingController();
    TextEditingController reportDescription = TextEditingController();

    void pickFile() async {
      xFile = await picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        selected.value = true;
        print(xFile.path);
      }
    }

    void saveNote() async{
      ready.value = false;
      Map res = await httpClient.newLabReport(xFile,{
        'client_id': authUser.id,
        'report_name': reportName.text,
        'report_result': reportResult.text,
        'report_type': reportType.text,
        'report_date': reportDate.text,
        'report_description': reportDescription.text,
        'report_url': 'NOT_SET_YET',
      });
      print(res);
      if (res['code'] == 200) {
        ready.value = false;
        Get.back();
        showSnack('Note Saved!', 'client notes is saved successfully');
      } else {
        showSnack('Something went wrong!', 'please try again');
        ready.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Submit New Lab Report'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: reportName,
                decoration: InputDecoration(
                  labelText: 'Report Name',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reportResult,
                decoration: InputDecoration(
                  labelText: 'Report Result',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reportType,
                readOnly: true,
                onTap: () {
                  Get.bottomSheet(Container(
                    height: Get.height * 0.75,
                    child: Card(
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          Expanded(child: ListView.builder(
                            itemCount: ReportTypesList.reportTypes.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(ReportTypesList.reportTypes[index]),
                                onTap: () {
                                  reportType.text = ReportTypesList.reportTypes[index];
                                  Get.back();
                                },
                              );
                            },
                          ))
                        ],
                      ),
                    ),
                  ));
                },
                decoration: InputDecoration(
                  labelText: 'Report Type',
                  suffixIcon: Icon(Icons.keyboard_arrow_down),
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6)
                  ),
                ),
                width: Get.width,
                child: InkWell(
                  onTap: (){
                    DatePickerBdaya.showDatePicker(
                      context,
                      theme: DatePickerThemeBdaya(
                        backgroundColor: Color(0xffF1F1F1),
                        containerHeight: Get.height/3,
                      ),
                      showTitleActions: true,
                      onChanged: (date) {
                        print('change $date');
                      }, onConfirm: (date) {
                      print('confirm $date');
                      reportDate.text = date.toLocal().toString().split(' ')[0];
                    },

                    );
                  },
                  child: TextField(
                    enabled: false,
                    controller: reportDate,
                    decoration: InputDecoration(
                      hintText: 'Report Date',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reportDescription,
                decoration: InputDecoration(
                  labelText: 'Report Description',
                ),
              ),
              SizedBox(height: 32),
              Container(
                height: 100,
                child: ElevatedButton(
                  style: ButtonStyles.matButton(Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().selectedCardBG, 0),
                  child:  Obx(()=> ready.value ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(()=> !selected.value ?
                        Row(
                          children: [
                            Transform.rotate(
                              angle: -45,
                              child: Icon(Icons.attachment_rounded),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Select Lab Report')
                          ],
                        ):
                        Flexible(
                            child: Text(
                                selected.value ? xFile.name : 'Select Lab Report',
                                overflow: TextOverflow.ellipsis,
                            ))
                      ),

                    ],
                  ) : Center(
                    child: CircularProgressIndicator(),
                  )),
                  onPressed: (){
                    pickFile();
                  },
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          height: 56,
          child: ElevatedButton(
            style: ButtonStyles.bigBlackButton(),
            child:  Obx(()=> ready.value ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Submit Lab Report',
                  style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade100),
                )
              ],
            ) : Center(
              child: CircularProgressIndicator(),
            )),
            onPressed: (){
              if(reportName.text.isEmpty || reportResult.text.isEmpty || reportType.text.isEmpty || reportDate.text.isEmpty || reportDescription.text.isEmpty){
                showSnack('Fill all the fields!', 'please fill all the mandatory fields and try again');
              } else {
                if(xFile == null){
                  showSnack('Select a Lab Report file!', 'please select a lab report file and try again');
                } else {
                  saveNote();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

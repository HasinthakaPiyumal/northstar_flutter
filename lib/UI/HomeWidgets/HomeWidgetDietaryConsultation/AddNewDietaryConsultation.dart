
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../../Models/NSNotification.dart';

class AddNewDietaryConsultation extends StatelessWidget {
  const AddNewDietaryConsultation({Key? key, required this.userId, required this.editMode, required this.data,this.trainerId = 0 })
      : super(key: key);
  final int userId;
  final int trainerId;
  final bool editMode;
  final Map data;

  @override
  Widget build(BuildContext context) {
    TextEditingController dietitianName = TextEditingController();
    TextEditingController date = TextEditingController();
    TextEditingController goals = TextEditingController();
    TextEditingController advice = TextEditingController();

    RxBool ready = true.obs;

    RxList mealTimes = [""].obs;
    RxList mealOptions = [""].obs;

    RxList<Map<String, dynamic>> menuItems = <Map<String, dynamic>>[
      {
        "time": "",
        "meal": "",
      },
    ].obs;

    late DateTime selectedDate;

    void addDietConsultation() async {
      Map res = await httpClient.addDietConsult({
        'client_id': userId,
        'data': {
          'dietitian_name': dietitianName.text,
          'date': DateFormat("yyyy-MM-dd").format(selectedDate).toString(),
          'goals': goals.text,
          'advice': advice.text,
          'menu': menuItems,
        }
      });
      print(res);
      if (res['code'] == 200) {
        print('trainerId');
        print(trainerId);
        if(trainerId!=0) {
          await httpClient.sendNotification(
              trainerId,
              'Dietary Consultation Form',
              'Your Client ${authUser.name} has accepted your request and added a dietary consultation form',
              NSNotificationTypes.Common, {
            'client_id': authUser.id,
            'client_name': authUser.name,
          });
        }
        Get.back();
        showSnack('Dietary Consultation Added',
            'Your dietary consultation has been added');
      } else {
        showSnack(
            'Error', 'There was an error adding your dietary consultation');
      }
    }

    void fillIfEditMode(){
      if(editMode){
        print(data['data']['menu']);
        dietitianName.text = data['data']['dietitian_name'];
        date.text = data['data']['date'];
        goals.text = data['data']['goals'];
        advice.text = data['data']['advice'];
         menuItems.clear();
         data['data']['menu'].forEach((element) {
           menuItems.add(element);
         });
      }
    }
    fillIfEditMode();
    return Scaffold(
      appBar: AppBar(
        title: Text(authUser.role == 'trainer' ? 'View':'Add New'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: dietitianName,
                enabled: editMode ? false : true,
                decoration: InputDecoration(
                  labelText: "Dietitians' Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: date,
                enabled: editMode ? false : true,
                onTap: () {
                  final DateRangePickerController datePickerController =
                      DateRangePickerController();
        
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: colors.Colors().deepGrey(1),
                      content: Container(
                        height: Get.height / 100 * 46,
                        width: Get.width / 100 * 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: colors.Colors().deepGrey(1),
                        ),
                        child: SfDateRangePicker(
                          controller: datePickerController,
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs args) {
                            selectedDate = args.value;
                            date.text = DateFormat("dd/MM/yyyy")
                                .format(selectedDate)
                                .toString();
                            Get.back();
                          },
                          monthCellStyle: DateRangePickerMonthCellStyle(
                            textStyle: TypographyStyles.normalText(
                                16, Colors.white),
                            disabledDatesTextStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.grey[400]),
                            todayTextStyle: TypographyStyles.normalText(
                                16, colors.Colors().deepYellow(1)),
                          ),
                          selectionRadius: 40,
                          selectionMode:
                              DateRangePickerSelectionMode.single,
                          selectionColor: colors.Colors().deepYellow(1),
                          selectionTextStyle:
                              TypographyStyles.boldText(14, Colors.black),
                          showNavigationArrow: true,
                          headerStyle: DateRangePickerHeaderStyle(
                            textStyle:
                                TypographyStyles.boldText(22, Colors.white),
                          ),
                          monthViewSettings:
                              const DateRangePickerMonthViewSettings(
                            dayFormat: 'EEE',
                          ),
                          headerHeight: 80,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      actionsAlignment: MainAxisAlignment.center,
                      // actions: [
                      //   MaterialButton(
                      //     onPressed: () {
                      //       Navigator.pop(context);
                      //     },
                      //     color: Colors.black,
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8)
                      //     ),
                      //     child: Padding(
                      //       padding: EdgeInsets.symmetric(vertical: 16),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Text("DONE",
                      //             style: TypographyStyles.boldText(16, Colors.white),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ],
                    ),
                  );
                },
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Treatment Plan :",
        
                style: TypographyStyles.boldText(
                    20, Get.isDarkMode ? Colors.white : Colors.black),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: goals,
                enabled: editMode ? false : true,
                decoration: InputDecoration(
                  labelText: "Goals",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: advice,
                enabled: editMode ? false : true,
                decoration: InputDecoration(
                  labelText: "Advice",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sample Menu :",
                    style: TypographyStyles.boldText(
                        20, Get.isDarkMode ? Colors.white : Colors.black),
                  ),
                  InkWell(
                    onTap:  editMode ? null :  () {
                      RxMap<String, dynamic> newItem = RxMap({
                        "time": "",
                        "meal": "",
                      });
                      menuItems.add(newItem);
        
                      print(menuItems);
                    },
                    child: Icon(Icons.add, color: Colors.white, size: 35),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Obx(() => ready.value
                  ? ListView.separated(
                      itemCount: menuItems.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 5,
                        );
                      },
                      itemBuilder: (context, index) {
                        TextEditingController time = TextEditingController();
                        time.text = menuItems[index]["time"];
        
                        return SizedBox(
                          child: Row(
                            children: [
                              SizedBox(
                                width: (Get.width - 40) / 100 * 20,
                                child: TextField(
                                  enabled: editMode ? false : true,
                                  controller: time,
                                  readOnly: true,
                                  onChanged: (value) {
                                    menuItems[index]["time"] = value;
                                    // if(mealOptions.last != "" && mealTimes.last != ""){
                                    //   mealTimes.add("");
                                    // }
                                    print(menuItems);
                                  },
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (BuildContext context,
                                          Widget? child) {
        
                                          return child!;
        
                                      },
                                    ).then((pickedTime) {
                                      if (pickedTime == null) {
                                        return;
                                      }
                                      time.text =
                                          "${pickedTime.hour}:${pickedTime.minute}";
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Time",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: (Get.width - 40) / 100 * 80,
                                child: TextField(
                                  enabled: editMode ? false : true,
                                  onChanged: (value) {
                                    menuItems[index]["meal"] = value;
                                    // if(mealOptions.last != "" && mealTimes.last != ""){
                                    //   mealOptions.add("");
                                    // }
                                    print(menuItems);
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Food/Beverage Options",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    )
                  : SizedBox()),
        SizedBox(height: 40,),
              Visibility(
                visible: editMode ? false : true,
                child:  Container(
                  width: Get.width,
                  height: 48,
                  margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ElevatedButton(
                    style: ButtonStyles.bigBlackButton(),
                    onPressed: () async {
                      if (date.text == "" || dietitianName.text == "" || goals.text == "" || advice.text == "") {
                        showSnack("Please fill all the fields",'Please fill all the fields to continue');
                      } else {
                        addDietConsultation();
                      }
                    },
                    child: Text(
                      "Add Diet Consultation",
                      style: TypographyStyles.smallBoldTitle(22).copyWith(color: AppColors.textOnAccentColor),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

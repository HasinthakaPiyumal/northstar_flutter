import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class GymDateAndTime extends StatelessWidget {
  const GymDateAndTime({Key? key,required this.gymObj, required this.clientIDs}) : super(key: key);
  final gymObj;
  final clientIDs;
  @override
  Widget build(BuildContext context) {

    RxList<DateTime> dates = List.generate(7, (index) => DateUtils.dateOnly(DateTime.now().add(Duration(days: index+1)))).obs;
    Rx<DateTime> selectedDate = DateUtils.dateOnly(DateTime.now().add(Duration(days: 1))).obs;

    RxList<DateTime> times = List.generate(7, (index) => DateUtils.dateOnly(DateTime.now().add(Duration(days: index+1)))).obs;
    Rx<DateTime> selectedStartTime = DateUtils.dateOnly(DateTime.now().add(Duration(days: 1))).obs;
    Rx<DateTime> selectedEndTime = DateUtils.dateOnly(DateTime.now().add(Duration(days: 1,hours: 2))).obs;

    RxList<bool> availability = List.generate(25, (index) => true).obs;
    RxBool ready = true.obs;
    void getAvailabilities(dateTime) async{
      Map res = await httpClient.getAvailability(gymObj['user_id'], dateTime);
      if(res['code'] == 200){
        availability.value =  List.generate(25, (index) => res['data'][index] == true).toList();
      }
    }


    void makeASchedule() async{
      ready.value = false;

      int hourlyRate = gymObj['hourly_rate'] * selectedEndTime.value.difference(selectedStartTime.value).inHours;
      Map res = await httpClient.makeASchedule(
          gymObj['user_id'],
          clientIDs,
          selectedStartTime.value,
          selectedEndTime.value,
          hourlyRate * 100,
      );
      print(res);
      if(res['code'] == 422){
        showSnack('Already a Booking at this time!',res['data']['info']['message']);
        ready.value = true;
      }

      if(res['code']== 403){
        showSnack('Insufficient Balance!',res['data']['message']);
        ready.value = true;
      }

      if(res['code'] == 200){
        Get.back();
      }
    }

    bool checkEndTimeAvailability(startTime, endTime,index){
      bool conditionOne = endTime.difference(selectedStartTime.value).inHours > 0;

      int propIndex = index == 0 ? 1 : index;
      bool conditionTwo = availability[propIndex-1] == true;

      return conditionOne && conditionTwo;
    }


    void generateTimes(DateTime date){
      times.value =  List.generate(25, (index) {
        return date.add(Duration(hours: index));
      });
      selectedStartTime.value = times[0];
      selectedEndTime.value = times[1];

      getAvailabilities(date);
    }

    generateTimes(selectedDate.value);

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Date'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 15),
          Container(
            height: 95,
            child: Obx(()=>ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: index == 0 ? EdgeInsets.only(left: 16) : EdgeInsets.only(left: 8),
                  child: Obx(()=>ElevatedButton(
                    style: selectedDate.value == dates[index] ? ButtonStyles.selectedBookingButton(12) : Get.isDarkMode ? ButtonStyles.notSelectedBookingButton(12) : ButtonStyles.notSelectedBookingButtonLightTheme(12),
                    onPressed: (){
                      selectedDate.value = dates[index];
                      generateTimes(dates[index]);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10,),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${(DateFormat('MMM').format(dates[index]).toUpperCase())}",
                            style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                          ),
                          SizedBox(height: 2,),
                          Text("${(DateFormat('dd').format(dates[index]).toUpperCase())}",
                            style: TypographyStyles.boldText(28, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                          ),
                          SizedBox(height: 4,),
                          Text("${(DateFormat('EEE').format(dates[index]).toUpperCase())}",
                            style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                          ),
                        ],
                      ),
                    ),
                  )),
                );
              },
            )),
          ),

          //Start Time
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(top:8,bottom: 0,left: 16,right: 16),
            child: Row(
              children: [
                Text('SELECT START TIME',style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade300),),
              ],
            ),
          ),

          SizedBox(height: 16),
          Container(
            height: 55,
            child: Obx(()=>ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: times.length-1,
              itemBuilder: (context, index) {
                return Container(
                  margin: index == 0 ? EdgeInsets.only(left: 16) : EdgeInsets.only(left: 8),
                  child: Obx(()=>ElevatedButton(
                    style: selectedStartTime.value == times[index] ?
                    ButtonStyles.selectedBookingButton(50) : Get.isDarkMode ? ButtonStyles.notSelectedBookingButton(50) : ButtonStyles.notSelectedBookingButtonLightTheme(50),
                    onPressed: availability[index] ? (){
                      selectedStartTime.value = times[index];
                      selectedEndTime.value = times[index+1];
                    }: null,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: RichText(
                        text: TextSpan(
                          text: '${DateFormat('hh:mm').format(times[index])}',
                          style: TypographyStyles.boldText(20,
                            availability[index] ? Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1) : Themes.mainThemeColorAccent.shade300,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: '${DateFormat(' a').format(times[index])}',
                              style: TypographyStyles.normalText(12,
                                availability[index] ? Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1) : Themes.mainThemeColorAccent.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  )),
                );
              },
            )),
          ),

          //End Time
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(top:8,bottom: 0,left: 16,right: 16),
            child: Row(
              children: [
                Text('SELECT END TIME',style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade300),),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 55,
            child: Obx(()=>ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: times.length-1,
              itemBuilder: (context, index) {
                return Container(
                  margin: index == 0 ? EdgeInsets.only(left: 16) : EdgeInsets.only(left: 8),
                  child: Obx(()=>ElevatedButton(
                      style: selectedEndTime.value == times[index] ? ButtonStyles.selectedBookingButton(50) : Get.isDarkMode ? ButtonStyles.notSelectedBookingButton(50) : ButtonStyles.notSelectedBookingButtonLightTheme(50),
                      onPressed: checkEndTimeAvailability(selectedStartTime.value, times[index],index) ? (){
                        selectedEndTime.value = times[index];
                      } : null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: RichText(
                          text: TextSpan(
                            text: '${DateFormat('hh:mm').format(times[index])}',
                            style: TypographyStyles.boldText(20,
                              checkEndTimeAvailability(selectedStartTime.value, times[index],index) ? Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1) : Themes.mainThemeColorAccent.shade300,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: '${DateFormat(' a').format(times[index])}',
                                style: TypographyStyles.normalText(12,
                                  checkEndTimeAvailability(selectedStartTime.value, times[index],index) ? Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1) : Themes.mainThemeColorAccent.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  )),
                );
              },
            )),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(15, 40, 15, 15),
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  children: [
                    Text('BOOKING SUMMARY',style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().darkGrey(1)),),
                    SizedBox(height: 25,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date',style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().darkGrey(1)),),
                        Obx(()=>Text(
                          DateFormat('EEEE, MMMM d').format(selectedDate.value),
                          style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                        )),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time Slot',style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().darkGrey(1)),),
                        Obx(() => RichText(
                          text: TextSpan(
                            text: '${DateFormat('h:mm').format(selectedStartTime.value)}',
                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                            children: <TextSpan>[
                              TextSpan(text: '${DateFormat(' a').format(selectedStartTime.value)}',
                                style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                              ),
                              TextSpan(
                                text: " - ",
                              ),
                              TextSpan(
                                text: "${DateFormat('h:mm').format(selectedEndTime.value)}",
                                style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                              ),
                              TextSpan(text: '${DateFormat(' a').format(selectedEndTime.value)}',
                                style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                              ),
                            ],
                          ),
                        ),),
                      ],
                    ),
                    SizedBox(height: 15,),
                    Divider(
                      thickness: 1,
                      color: Themes.mainThemeColorAccent.shade300.withOpacity(0.6),
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price ( ${selectedEndTime.value.difference(selectedStartTime.value).inHours} Hours )',style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),),
                        Obx(()=>Text("Rf ${(gymObj['hourly_rate'] * (selectedEndTime.value.difference(selectedStartTime.value).inHours)).toStringAsFixed(2)}",
                          style: TypographyStyles.boldText(22, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: Get.width,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: MaterialButton(
          onPressed: (){
            CommonConfirmDialog.confirm('Confirm').then((value){
              if(value) {
                makeASchedule();
              }
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.black,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("CONFIRM",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      )
    );
  }
}

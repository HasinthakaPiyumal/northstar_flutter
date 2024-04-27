import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';

class GymTimeAndPay extends StatelessWidget {
  const GymTimeAndPay({Key? key, this.gymObj, required this.clientIds}) : super(key: key);
  final gymObj;
  final List<int> clientIds;
  @override
  Widget build(BuildContext context) {

    RxList<DateTime> dates = List.generate(7, (index) => DateUtils.dateOnly(DateTime.now().add(Duration(days: index+1)))).obs;
    Rx<DateTime> selectedDate = DateUtils.dateOnly(DateTime.now().add(Duration(days: 1))).obs;

    RxList<DateTime> times = List.generate(7, (index) => DateUtils.dateOnly(DateTime.now().add(Duration(days: index+1)))).obs;
    Rx<DateTime> selectedStartTime = DateUtils.dateOnly(DateTime.now().add(Duration(days: 1))).obs;
    Rx<DateTime> selectedEndTime = DateUtils.dateOnly(DateTime.now().add(Duration(days: 1,hours: 2))).obs;
    RxMap walletData = {}.obs;

    RxList<bool> availability = List.generate(24, (index) => true).obs;
    RxBool ready = true.obs;
    void getAvailabilities(dateTime) async{
      Map res = await httpClient.getAvailability(gymObj['user_id'], dateTime);
      if(res['code'] == 200){
        availability.value =  List.generate(24, (index) => res['data'][index] == true).toList();
      }
    }

    void getWallet() async{
      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
      } else {
        print(res);
      }
    }

    getWallet();


    void makeASchedule() async{
      ready.value = false;

      int hourlyRate = gymObj['hourly_rate'] * selectedEndTime.value.difference(selectedStartTime.value).inHours;
      Map res = await httpClient.makeASchedule(
          gymObj['user_id'],
          clientIds,
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
        Get.offAll(()=> Layout());
        //ready.value = true;
        showSnack('Success!','Booking Confirmed!');
      }
    }

    bool checkEndTimeAvailability(startTime, endTime,index){
      bool conditionOne = endTime.difference(selectedStartTime.value).inHours > 0;

      int propIndex = index == 0 ? 1 : index;
      bool conditionTwo = availability[propIndex-1] == true;

      return conditionOne && conditionTwo;
    }


    void generateTimes(DateTime date){
      times.value =  List.generate(24, (index) {
        return date.add(Duration(hours: index));
      });
      selectedStartTime.value = times[0];
      selectedEndTime.value = times[1];

      getAvailabilities(date);
    }

    generateTimes(selectedDate.value);

    print(gymObj['hourly_rate']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Date'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:8,bottom: 0,left: 16,right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            //Date
            Row(
              children: [
                Text('Date',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 64,
              child: Obx(()=>ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 128,
                    margin: const EdgeInsets.only(right: 16),
                    child: Obx(()=>ElevatedButton(
                      style: selectedDate.value == dates[index] ? SignUpStyles.selectedButton() : SignUpStyles.notSelectedButton(),
                      onPressed: (){
                        selectedDate.value = dates[index];
                        generateTimes(dates[index]);
                      },
                      child: Text(DateFormat('EEEE\nMMM d').format(dates[index])),
                    )),
                  );
                },
              )),
            ),

            //Start Time
            SizedBox(height: 16),
            Row(
              children: [
                Text('Start Time',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 64,
              child: Obx(()=>ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: times.length-1,
                itemBuilder: (context, index) {
                  return Container(
                    width: 128,
                    margin: const EdgeInsets.only(right: 16),
                    child: Obx(()=>ElevatedButton(
                      style: selectedStartTime.value == times[index] ? SignUpStyles.selectedButton() : SignUpStyles.notSelectedButton(),
                      onPressed: availability[index] ? (){
                        selectedStartTime.value = times[index];
                        selectedEndTime.value = times[index+1];

                      }: null,
                      child: Text(DateFormat('HH:mm').format(times[index])),
                    )),
                  );
                },
              )),
            ),

            //End Time
            SizedBox(height: 16),
            Row(
              children: [
                Text('End Time',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 64,
              child: Obx(()=>ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: times.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 128,
                    margin: const EdgeInsets.only(right: 16),
                    child: Obx(()=>ElevatedButton(

                      style: selectedEndTime.value == times[index] ? SignUpStyles.selectedButton() : SignUpStyles.notSelectedButton(),
                      onPressed: checkEndTimeAvailability(selectedStartTime.value, times[index],index) ? (){
                        selectedEndTime.value = times[index];
                      } : null,
                      child: Text(DateFormat('HH:mm').format(times[index])),
                    )),
                  );
                },
              )),
            ),


            SizedBox(height: 32),
            Obx(()=>Text(
              DateFormat('EEEE, MMMM d').format(selectedDate.value),
              style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
            )),
            Obx(()=>Text(
              DateFormat('HH:mm').format(selectedStartTime.value) + ' to ' + DateFormat('HH:mm').format(selectedEndTime.value),
              style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),
            )),
            SizedBox(height: 16),
            Obx(()=>Text(
              '${selectedEndTime.value.difference(selectedStartTime.value).inHours} Hours\n'
                  +
                  '\$' + (gymObj['hourly_rate'] * (selectedEndTime.value.difference(selectedStartTime.value).inHours)).toString(),
              style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),
            )),
            Expanded(
              child: Text(''),
            ),
            Container(
              height: 64,
              width: Get.width,
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: (){
                  Get.defaultDialog(
                    radius: 8,
                    title: 'Confirm Payment',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Are you sure you want to book this gym for the following time?'),
                        SizedBox(height: 16),
                        Text('Wallet Balance: ' + (Utils.formatCurrency.format(walletData['balance']/100)).toString()),
                        SizedBox(height: 4),
                        Text('Booking Cost: -' + '\$' + (gymObj['hourly_rate'] * (selectedEndTime.value.difference(selectedStartTime.value).inHours)).toString(),
                        style: TextStyle(color: Colors.red),),
                        SizedBox(height: 4),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: (){
                        Get.back();
                      }, child: Text('Cancel')),
                      TextButton(onPressed: (){
                        makeASchedule();
                      }, child: Text('Pay Now')),
                    ]
                  );
                  /*CommonConfirmDialog.confirm('Pay').then((value){
                    if(value) {
                      makeASchedule();
                    }
                  });*/
                },
                style: ButtonStyles.primaryButton(),
                child: Obx(()=> ready.value ? Text('Confirm and Pay'): LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),

          ],
        ),
      )
    );
  }
}

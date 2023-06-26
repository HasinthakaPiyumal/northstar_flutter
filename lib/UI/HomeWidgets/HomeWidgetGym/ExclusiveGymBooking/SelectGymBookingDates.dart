import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/ExclusiveGymBooking/GymDateAndTime.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Styles/ButtonStyles.dart';
import '../../../SharedWidgets/CommonConfirmDialog.dart';
import '../../../SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SelectGymBookingDates extends StatelessWidget {
  const SelectGymBookingDates({Key? key, this.gymObj, required this.clientIds})
      : super(key: key);
  final gymObj;
  final List<int> clientIds;

  @override
  Widget build(BuildContext context) {
    RxMap walletData = {}.obs;
    RxList bookings = [].obs;
    RxBool ready = true.obs;
    RxInt totalHours = 0.obs;


    void getTotalHours() {
      int temp = 0;
      bookings.forEach((element) {
        temp += DateTime.parse(element['end_time'])
            .difference(DateTime.parse(element['start_time']))
            .inHours;
      });
      totalHours.value = temp;
    }

    void getUnconfirmedBookings() async {
      Map res = await httpClient.getUnconfirmedBookings(gymObj['user_id']);
      if (res['code'] == 200) {
        print(res['data']);
        bookings.value = res['data'];
        getTotalHours();
      } else {
        print(res);
      }
    }

    void payByCard(int amount) async{
      ready.value = false;
      Map res = await httpClient.topUpWallet({
        'amount': amount,
      });
      print(res);
      if(res['code'] == 200){
        print(res['data']['url']);
        await launchUrl(Uri.parse(res['data']['url']));
      } else {
        print(res);
      }
      ready.value = true;
    }

    void confirmAndPay() async{

      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
      } else {
        print(res);
      }

      Get.defaultDialog(
        radius: 8,
        title: '',
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.symmetric(horizontal: 20,),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("BOOKING SUMMARY",
              style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Bookings',
                  style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1)),
                ),
                Text(
                  '${bookings.value.length}',
                  style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                ),
              ],
            ),
            SizedBox(height: 4),
            Divider(
              thickness: 1,
              color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Hours',
                  style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1),),
                ),
                Text(
                  '${totalHours.value}',
                  style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                ),
              ],
            ),
            SizedBox(height: 7,),
            Divider(
              thickness: 1,
              color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
            ),
            SizedBox(height: 7,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total To be Paid',
                  style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                ),
                Text(
                  'MVR ${totalHours.value * gymObj['hourly_rate']}',
                  style: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                ),
              ],
            ),
            SizedBox(height: 30),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'By clicking Pay with Card, you are agreeing to our ',
                style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TypographyStyles.normalText(12, Themes.mainThemeColor),
                    recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://northstar.mv/terms-conditions/')),
                  ),
                  TextSpan(
                    text: " & ",
                    style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TypographyStyles.normalText(12, Themes.mainThemeColor),
                    recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://northstar.mv/privacy-policy')),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),

        actions: [
          Container(
            width: Get.width,
            child: ElevatedButton(
              onPressed: () async{
                if(totalHours.value * gymObj['hourly_rate'] <= walletData.value['balance']){
                  List temp = [];
                  bookings.forEach((element) {
                    temp.add(element['id']);
                  });
                  Map res = await httpClient.confirmSchedules(
                      temp,
                      totalHours.value * gymObj['hourly_rate'],
                      gymObj['user_id'],
                  );
                  if (res['code'] == 200) {
                    Get.offAll(()=>Layout());
                    showSnack('Schedule Confirmed!','Your Booking Schedule has been confirmed and paid.');
                  } else {
                    print(res);
                  }
                } else {
                  showSnack('Insufficient Balance','You do not have sufficient balance to pay for this booking.');
                }
              },
              style: ButtonStyles.matButton(Themes.mainThemeColor.shade500, 0),
              child: Obx(() => ready.value ? Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pay with eWallet',
                      style: TypographyStyles.boldText(16, Colors.black),
                    ),
                    SizedBox(height: 3,),
                    Text('(eWallet Balance: ${walletData['balance'].toStringAsFixed(2)})',
                      style: TypographyStyles.normalText(13, Colors.black),
                    ),
                  ],
                ),
              ) : LoadingAndEmptyWidgets.loadingWidget()),
            ),
          ),
          Container(
            width: Get.width,
            padding: EdgeInsets.only(top: 3),
            child: ElevatedButton(
              onPressed: (){
                payByCard(int.parse('${totalHours.value * gymObj['hourly_rate'] * 100}'));
              },
              style: SignUpStyles.selectedButton(),
              child: Obx(() => ready.value ? Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Container(
                        width: 32,
                        height: 32,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.asset('assets/BMLLogo.jpeg'),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Pay with Card',
                        style: TypographyStyles.boldText(15, Themes.mainThemeColor.shade500),
                      )
                    ]
                ),
              ) : LoadingAndEmptyWidgets.loadingWidget()),
            ),
          ),
          Container(
            height: 48,
            width: Get.width,
            child: TextButton(onPressed: ()=>Get.back(), child: Text('Cancel', style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),)),
          ),
          SizedBox(height: 5,),
        ]
      );
    }

    void deleteUnconfirmedBooking(id) async {
      await httpClient.deleteUnconfirmedBookings(id);
      getUnconfirmedBookings();
    }

    Future deleteAllUnconfirmedBookings() async {
      await httpClient.deleteAllUnconfirmedBookings();
      return true;
    }

    getUnconfirmedBookings();

    return WillPopScope(
        onWillPop: () async {
          await CommonConfirmDialog.confirm('Discard').then((value) async{
            if(value){
              await deleteAllUnconfirmedBookings();
              Get.back();
            } else {
              return false;
            }
          });
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Add Booking'),
            actions: [
              IconButton(
                padding: EdgeInsets.only(right: 15),
                icon: Icon(Icons.refresh),
                onPressed: () {
                  getUnconfirmedBookings();
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: Get.width*80/100,
                margin: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => GymDateAndTime(gymObj: gymObj, clientIDs: clientIds,))
                        ?.then((value) => getUnconfirmedBookings());
                  },
                  style: ButtonStyles.matButton(Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG, 0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add,
                          color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                        ),
                        SizedBox(width: 10,),
                        Text('Pick Your Date & Time',
                          style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                        ),
                        Icon(Icons.add, color: Colors.transparent,),
                      ],
                    )
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                  child: Obx(() => ListView.builder(
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Get.isDarkMode ? colors.Colors().lightBlack(1) : colors.Colors().selectedCardBG,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8,8,0,8),
                              child: Row(
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: Get.isDarkMode ? Colors.black : colors.Colors().darkGrey(1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text((DateFormat('MMM').format(DateTime.parse(bookings[index]['start_time']))).toUpperCase(),
                                          style: TypographyStyles.boldText(12, Themes.mainThemeColorAccent.shade100),
                                        ),
                                        Text(DateFormat('dd').format(DateTime.parse(bookings[index]['start_time'])),
                                          style: TypographyStyles.boldText(24, Themes.mainThemeColorAccent.shade100),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 15,),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(DateFormat('EEEE, MMM dd,yyyy').format(DateTime.parse(bookings[index]['start_time'])),),
                                            SizedBox(height: 8,),
                                            Text("${DateFormat('HH:mm').format(DateTime.parse(bookings[index]['start_time']))} to ${DateFormat('HH:mm').format(DateTime.parse(bookings[index]['end_time']))}",
                                              style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: (){
                                      deleteUnconfirmedBooking(bookings[index]['id']);
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                  Card(
                                  color: colors.Colors().lightBlack(1),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ),
              ),
              SizedBox(height: 80,),
            ],
          ),
          bottomSheet: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Color(0xFF434343) : Color(0xFFDBDBDB),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(25.0),
                  topRight: const Radius.circular(25.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Price",
                                style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1)),
                              ),
                              SizedBox(height: 5,),

                              Obx(() => RichText(
                                text: TextSpan(
                                  text: 'MVR',
                                  style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' ${(totalHours.value * gymObj['hourly_rate']).toStringAsFixed(2)}',
                                      style: TypographyStyles.boldText(24, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                    ),
                                  ],
                                ),
                              ),),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyles.bigBlackButton(),
                          child: Obx(() => ready.value ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 36),
                            child: Text('CONFIRM'),
                          ) : LoadingAndEmptyWidgets.loadingWidget()),
                          onPressed: () {
                            if(bookings.length>0){
                              confirmAndPay();
                            }else{
                              showSnack("No Bookings Added", "Please add bookings to continue");
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}

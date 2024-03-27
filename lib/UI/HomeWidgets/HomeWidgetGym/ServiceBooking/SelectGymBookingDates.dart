import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/ServiceBooking/GymDateAndTime.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Controllers/TaxController.dart';
import '../../../../Styles/AppColors.dart';
import '../../../../Styles/ButtonStyles.dart';
import '../../../../components/Buttons.dart';
import '../../../../components/CouponApply.dart';
import '../../../SharedWidgets/CommonConfirmDialog.dart';
import '../../../SharedWidgets/LoadingAndEmptyWidgets.dart';
import '../../../SharedWidgets/PaymentVerification.dart';

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
    RxDouble totalPrice = 0.0.obs;


    RxString couponCode = "".obs;
    RxDouble couponValue = 0.0.obs;

    void getUnconfirmedBookings() async {
      print('GYM obj ==> $gymObj');
      Map res = await httpClient.getUnconfirmedBookingsForService(gymObj['gym_services']['id']);
      if (res['code'] == 200) {
        print(res['data']);
        bookings.value = res['data'];
        totalPrice.value = double.parse((bookings.length  *clientIds.length * gymObj['gym_services']['price']).toStringAsFixed(2));
        print(gymObj['gym_services']);
        print("(gymObj['gym_services']['price']).toStringAsFixed(2)");
      } else {
        print(res);
      }
    }

    void payByCard(double amount) async {
      ready.value = false;
      List ids = [];
      bookings.forEach((element) {
        ids.add(element['id']);
      });
      Map res = await httpClient.confirmSchedulesForService({
        'booking_ids':ids,
        'service_id':gymObj['gym_services']['id'],
        'couponCode':couponCode.value,
        'paymentType':1
      });

      print(res);
      if (res['code'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        Get.to(()=>PaymentVerification());
      } else {
        showSnack("Booking Failed",res['data']['description'][0] );
      }
      ready.value = true;
    }

    void informUser(){
      clientIds.forEach((element) {
        print("Sending notification to client");
        print('GYM object $gymObj');

        bookings.forEach((bookingElement) {
          DateTime stTime = DateTime.parse(bookingElement['start_time']);


          String formattedStartTime = DateFormat('h:mm a').format(stTime); // Format the start time as '12:11 AM'
          String formattedDate = DateFormat('EEEE, MMM d').format(stTime); // Format the date as 'Saturday, Oct 27'

          String notes = "New Service booked for you at $formattedStartTime on $formattedDate.";
          print('bookingElement-->$bookingElement');
          httpClient.saveTodo({
            'user_id': element,
            'todo': "You have a gym service session!",
            'notes': notes,
            'endDate': stTime
          }, null);
        });
        httpClient.sendNotification(
            element,
            'You have new booking!',
            'Your trainer has booked a service for you.',
            NSNotificationTypes.GymAppointment, {});
      });
    }

    void confirmAndPay() async {
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          content: Obx(()=> Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BOOKING SUMMARY",
                  style: TypographyStyles.boldText(
                      16,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade100
                          : colors.Colors().lightBlack(1)),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Bookings',
                      style: TypographyStyles.normalText(
                          16,
                          Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade300
                              : colors.Colors().lightBlack(1)),
                    ),
                    Text(
                      '${bookings.value.length}',
                      style: TypographyStyles.boldText(
                          16,
                          Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade100
                              : colors.Colors().lightBlack(1)),
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
                      'For',
                      style: TypographyStyles.normalText(
                        16,
                        Get.isDarkMode
                            ? Themes.mainThemeColorAccent.shade300
                            : colors.Colors().lightBlack(1),
                      ),
                    ),
                    Text(
                      '${clientIds.length} person',
                      style: TypographyStyles.boldText(
                        16,
                        Get.isDarkMode
                            ? Themes.mainThemeColorAccent.shade100
                            : colors.Colors().lightBlack(1),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 7,
                ),
                Divider(
                  thickness: 1,
                  color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
                ),
                SizedBox(
                  height: 7,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total To be Paid',
                      style: TypographyStyles.normalText(
                        16,
                        Get.isDarkMode
                            ? Themes.mainThemeColorAccent.shade100
                            : colors.Colors().lightBlack(1),
                      ),
                    ),
                    Text(
                      'MVR ${totalPrice.value - couponValue.value}',
                      style: TypographyStyles.boldText(
                        20,
                        Get.isDarkMode
                            ? Themes.mainThemeColorAccent.shade100
                            : colors.Colors().lightBlack(1),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By clicking Pay with Card, you are agreeing to our ',
                    style: TypographyStyles.normalText(
                      12,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade100
                          : colors.Colors().lightBlack(1),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TypographyStyles.normalText(
                            12, Themes.mainThemeColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(Uri.parse(
                              'https://northstar.mv/terms-conditions/')),
                      ),
                      TextSpan(
                        text: " & ",
                        style: TypographyStyles.normalText(
                            12,
                            Get.isDarkMode
                                ? Themes.mainThemeColorAccent.shade100
                                : colors.Colors().lightBlack(1)),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TypographyStyles.normalText(
                            12, Themes.mainThemeColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                              Uri.parse('https://northstar.mv/privacy-policy')),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                CouponApply(
                    type: 3,
                    typeId: gymObj['user_id'],
                    couponCode: couponCode,
                    couponValue: couponValue,
                    payingAmount: totalPrice.value)
              ],
            ),
          ),
          actions: [
            Container(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () async {
                  if ((totalPrice.value -  couponValue.value) <=
                      walletData.value['balance']) {
                    List temp = [];
                    bookings.forEach((element) {
                      temp.add(element['id']);
                    });
                    Map res = await httpClient.confirmSchedulesForService({
                      'booking_ids':temp,
                      'service_id':gymObj['gym_services']['id'],
                      'couponCode':couponCode.value,
                      'paymentType':2
                    });
                    if (res['code'] == 200) {
                      informUser();
                      Get.offAll(() => Layout());
                      showSnack('Schedule Confirmed!',
                          'Your Booking Schedule has been confirmed and paid.');
                    } else {
                      print(res);
                    }
                  } else {
                    showSnack('Insufficient Balance',
                        'You do not have sufficient balance to pay for this booking.');
                  }
                },
                style:
                    ButtonStyles.matButton(Themes.mainThemeColor.shade500, 0),
                child: Obx(() => ready.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pay with eWallet',
                              style:
                                  TypographyStyles.boldText(16, Colors.black),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              '(eWallet Balance: ${walletData['balance'].toStringAsFixed(2)})',
                              style:
                                  TypographyStyles.normalText(13, Colors.black),
                            ),
                          ],
                        ),
                      )
                    : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              width: Get.width,
              padding: EdgeInsets.only(top: 3),
              child: ElevatedButton(
                onPressed: () {
                  payByCard(totalPrice.value);
                },
                style: SignUpStyles.selectedButton(),
                child: Obx(() => ready.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Image.asset('assets/BMLLogo.jpeg'),
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: [
                                  Text(
                                    'Pay with Card',
                                    style: TextStyle(
                                      color: AppColors.accentColor,
                                      fontSize: 20,
                                      fontFamily: 'Bebas Neue',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  Text(
                                    'Tax amount: MVR ${(taxController.getCalculatedTax( totalPrice.value - couponValue.value)).toStringAsFixed(2)}',
                                    style: TypographyStyles.text(10),
                                  )
                                ],
                              )
                            ]),
                      )
                    : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              height: 48,
              width: Get.width,
              child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TypographyStyles.boldText(
                      14,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade100
                          : colors.Colors().lightBlack(1),
                    ),
                  )),
            ),
            SizedBox(
              height: 5,
            ),
          ]);
    }

    void deleteUnconfirmedBooking(id) async {
      await httpClient.deleteUnconfirmedBookingsForService(id);
      getUnconfirmedBookings();
    }

    Future deleteAllUnconfirmedBookings() async {
      await httpClient.deleteAllUnconfirmedBookingsForService();
      return true;
    }

    getUnconfirmedBookings();

    return WillPopScope(
      onWillPop: () async {
        await CommonConfirmDialog.confirm('Discard').then((value) async {
          if (value) {
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
              width: Get.width,
              margin: const EdgeInsets.all(16),
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => GymDateAndTime(
                        gymObj: gymObj,
                        clientIDs: clientIds,
                      ))?.then((value) => getUnconfirmedBookings());
                },
                style: ButtonStyles.matButton(AppColors.accentColor, 0),
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: AppColors.textOnAccentColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Pick Your Date & Time',
                          style: TypographyStyles.boldText(
                              16, AppColors.textOnAccentColor),
                        ),
                        Icon(
                          Icons.add,
                          color: Colors.transparent,
                        ),
                      ],
                    )),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? AppColors.primary2Color
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                        child: Row(
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: AppColors.accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (DateFormat('MMM').format(DateTime.parse(
                                            bookings[index]['start_time'])))
                                        .toUpperCase(),
                                    style: TypographyStyles.boldText(
                                        12, AppColors.textOnAccentColor),
                                  ),
                                  Text(
                                    DateFormat('dd').format(DateTime.parse(
                                        bookings[index]['start_time'])),
                                    style: TypographyStyles.boldText(
                                        24, AppColors.textOnAccentColor),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, MMM dd,yyyy').format(
                                            DateTime.parse(
                                                bookings[index]['start_time'])),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "${DateFormat('HH:mm').format(DateTime.parse(bookings[index]['start_time']))}",
                                        style: TypographyStyles.boldText(
                                            16,
                                            Get.isDarkMode
                                                ? Themes.mainThemeColorAccent
                                                    .shade100
                                                : colors.Colors()
                                                    .lightBlack(1)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
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
            SizedBox(
              height: 80,
            ),
          ],
        ),
        bottomSheet: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                borderRadius: new BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Total Price",
                          style: TypographyStyles.text(16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Obx(
                          () => RichText(
                            text: TextSpan(
                              text: 'MVR',
                              style: TypographyStyles.boldText(
                                  16,
                                  Get.isDarkMode
                                      ? Themes.mainThemeColorAccent.shade100
                                      : colors.Colors().lightBlack(1)),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      ' ${totalPrice.value}',
                                  style: TypographyStyles.boldText(
                                      24,
                                      Get.isDarkMode
                                          ? Themes.mainThemeColorAccent.shade100
                                          : colors.Colors().lightBlack(1)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: Get.width,
                          child: Buttons.yellowFlatButton(
                            label: "confirm",
                            onPressed: () {
                              if (bookings.length > 0) {
                                confirmAndPay();
                              } else {
                                showSnack("No Bookings Added",
                                    "Please add bookings to continue");
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

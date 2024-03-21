import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Controllers/TaxController.dart';
import '../../../components/Buttons.dart';
import '../../../components/CouponApply.dart';
import '../../SharedWidgets/PaymentVerification.dart';

class SelectedPlan extends StatelessWidget {



  const SelectedPlan({Key? key, required this.selectedPlanID, required this.gymObj, required this.plan, required this.selectedPlanType}) : super(key: key);
  final int selectedPlanID;
  final Map gymObj;
  final int selectedPlanType;
  final dynamic plan;


  @override
  Widget build(BuildContext context) {
    List planCharges = ['monthly_charge', 'weekly_charge', 'daily_charge'];
    List types = ['monthly', 'weekly', 'daily'];
    TextEditingController startDateText = TextEditingController();

    print("palnn======");
    print(plan);

    RxString start = "".obs;
    RxString end = "".obs;
    RxInt duration = 0.obs;

    RxString couponCode = "".obs;
    RxDouble couponValue = 0.0.obs;

    RxInt selectedAmount = 1.obs;

    RxMap walletData = {}.obs;
    RxBool ready = true.obs;

    List<DropdownMenuItem<String>> menuItemsMonths = [
      const DropdownMenuItem(child: Text("1 Month"),value: "1"),
      const DropdownMenuItem(child: Text("3 Months"),value: "3"),
      const DropdownMenuItem(child: Text("6 Months"),value: "6"),
      const DropdownMenuItem(child: Text("9 Months"),value: "9"),
      const DropdownMenuItem(child: Text("1 Year"),value: "12"),
      const DropdownMenuItem(child: Text("2 Years"),value: "24"),
    ];

    List<DropdownMenuItem<String>> menuItemsWeeks = [
      const DropdownMenuItem(child: Text("1 Week"),value: "1"),
      const DropdownMenuItem(child: Text("2 Week"),value: "2"),
      const DropdownMenuItem(child: Text("3 Week"),value: "3"),
    ];

    DateTime min = DateTime.now();

    void informMe(){
      String notes = "Your gym session starts - ${startDateText.text}.";
      httpClient.sendNotification(
          authUser.id,
          'You have new booking!',
          'You have booked a gym for you.',
          NSNotificationTypes.GymAppointment, {});
      httpClient.saveTodo({
        'user_id': authUser.id,
        'todo': "You have a gym session!",
        'notes': notes,
        'endDate': DateFormat('dd-MM-yyyy').parse(startDateText.text).add(Duration(hours: 23,minutes: 59))
      }, null);
    }

    void payByCard(int amount) async{
      ready.value = false;
      Map res = await httpClient.newComGymBooking({
        // 'amount': (selectedAmount.value * plan["real_price"]) + (selectedAmount.value * plan["real_price"] * 0.06),
        // 'user_id': authUser.id,
        'gym_id': gymObj['user_id'],
        'start_date': startDateText.text,
        'plan_id':plan['id'],
        // 'quantity': selectedAmount.value,
        'paymentType':1,
        'couponCode':couponCode.value
      });
      print(res);
      if(res['code'] == 200){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        Get.to(()=>PaymentVerification());
      } else {
        print(res);
        showSnack("Booking Failed",res['data']['description'][0] );
      }
      ready.value = true;
    }
    // void informUser(){
    //   clientIds.forEach((element) {
    //     print("Sending notification to client");
    //     print('GYM object $gymObj');
    //
    //     bookings.forEach((bookingElement) {
    //       DateTime stTime = DateTime.parse(bookingElement['start_time']);
    //       DateTime enTime = DateTime.parse(bookingElement['end_time']);
    //
    //       Duration duration = enTime.difference(stTime);
    //       int totalHours = duration.inHours;
    //
    //       String formattedStartTime = DateFormat('h:mm a').format(stTime); // Format the start time as '12:11 AM'
    //       String formattedDate = DateFormat('EEEE, MMM d').format(stTime); // Format the date as 'Saturday, Oct 27'
    //
    //       String notes = "Your $totalHours-hour gym session starts at $formattedStartTime on $formattedDate.";
    //       print('bookingElement-->$bookingElement');
    //       httpClient.saveTodo({
    //         'user_id': element,
    //         'todo': "You have a gym session!",
    //         'notes': notes,
    //         'endDate': stTime
    //       }, null);
    //     });
    //     httpClient.sendNotification(
    //         element,
    //         'You have new booking!',
    //         'Your trainer has booked a gym for you.',
    //         NSNotificationTypes.GymAppointment, {});
    //   });
    // }

    void confirmAndPay(String package, int noOfDays, String startDate, double total) async{

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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Package',
              //       style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1)),
              //     ),
              //     Text(
              //       '$package',
              //       style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1)),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 4),
              // Divider(
              //   thickness: 1,
              //   color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              // ),
              // SizedBox(height: 4),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'No of Days',
              //       style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1),),
              //     ),
              //     Text(
              //       '$noOfDays',
              //       style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 4),
              // Divider(
              //   thickness: 1,
              //   color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              // ),
              // SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start Date',
                    style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1),),
                  ),
                  Text(
                    '$startDate',
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
                    'Total to be paid',
                    style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  ),
                  Text(
                    'MVR ${plan["real_price"] - couponValue.value}',
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
              CouponApply(
                  type: 2,
                  typeId: gymObj['user_id'],
                  couponCode: couponCode,
                  couponValue: couponValue,
                  payingAmount: CouponApply(
                      type: 2,
                      typeId: gymObj['user_id'],
                      couponCode: couponCode,
                      couponValue: couponValue,
                      payingAmount: plan["real_price"]))
            ],
          ),
          actions: [
            Container(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () async {
                  if (walletData.value['balance'] >= selectedAmount.value * plan["real_price"]) {
                    Map res = await httpClient.newComGymBooking({
                      // 'amount': (selectedAmount.value * plan["real_price"]) + (selectedAmount.value * plan["real_price"] * 0.06),
                      // 'user_id': authUser.id,
                      'gym_id': gymObj['user_id'],
                      'start_date': startDateText.text,
                      'plan_id':plan['id'],
                      // 'quantity': selectedAmount.value,
                      'paymentType':2,
                      'couponCode':couponCode.value
                    });



                    print(res);
                    if (res['code'] == 200) {
                      informMe();
                      Get.offAll(() => Layout());
                      print('Booking Success ---> $res');
                      showSnack('Booking Successful', 'Your booking has been successfully placed.');
                    } else {
                      showSnack('Booking Failed',
                          'Something went wrong. Please try again later.');
                    }
                  } else {
                    showSnack('Not Enough Balance',
                        'You do not have enough balance to pay for this booking');
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
                  int amt = plan["real_price"];
                  payByCard(amt);
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
                              'Tax amount: MVR ${(taxController.getCalculatedTax( plan["real_price"]- couponValue.value)).toStringAsFixed(2)}',
                              style: TypographyStyles.text(10),
                            )
                          ],
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
            SizedBox(height: 4),
          ]
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Booking"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Selected Plan",
                    style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1)),
                  )
                ],
              ),

              SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? AppColors.primary2Color : colors.Colors().lightCardBG,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(plan['name'],
                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                          ),
                          Text("MVR ${plan["real_price"]}",
                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: plan["discounted"],
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColors.accentColor,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                child: Text(
                                  "SAVE MVR ${(plan['price']*plan['discounted_percentage']/100).toStringAsFixed(2)}",
                                  style: TypographyStyles.boldText(
                                      12, AppColors.textOnAccentColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25,),

              // Text(selectedPlanID == 0 ? "No. of Months" : selectedPlanID == 0 ? "No. of Weeks" : "No. of Days",
              //   style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
              // ),

              // SizedBox(height: 15,),

              // Visibility(
              //   child: DropdownButtonFormField(
              //     decoration: InputDecoration(
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10.0),
              //         borderSide: BorderSide(
              //           color: Get.isDarkMode ? AppColors.primary2Color : colors.Colors().lightCardBG,
              //         ),
              //       ),
              //       contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
              //       labelStyle: TypographyStyles.normalText(14, Themes.mainThemeColorAccent.shade100)
              //     ),
              //     icon: Icon(Icons.keyboard_arrow_down_rounded,
              //       color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
              //     ),
              //     iconSize: 30,
              //     iconEnabledColor: Themes.mainThemeColorAccent.shade100,
              //     dropdownColor: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
              //     value: selectedAmount.value.toString(),
              //     validator: (value) => value == null || value == 'select' ? "Select no. of Months" : null,
              //     items: menuItemsMonths,
              //     onChanged: (newValue){
              //       selectedAmount.value = int.parse(newValue.toString());
              //       startDateText.clear();
              //       start.value = "";
              //       end.value = "";
              //     },
              //   ),
              //   visible: selectedPlanID == 0,
              // ),

              // Visibility(
              //   child: DropdownButtonFormField(
              //     decoration: InputDecoration(
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10.0),
              //         borderSide: BorderSide(
              //           color: AppColors.primary2Color,
              //         ),
              //       ),
              //       contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
              //       labelStyle: TypographyStyles.normalText(14, Themes.mainThemeColorAccent.shade100),
              //     ),
              //     icon: const Icon(Icons.keyboard_arrow_down_rounded,),
              //     iconSize: 30,
              //     iconEnabledColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),
              //     dropdownColor: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
              //     value: selectedAmount.value.toString(),
              //     validator: (value) => value == null || value == 'select' ? "Select no. of Weeks" : null,
              //     items: menuItemsWeeks,
              //     onChanged: (newValue){
              //       selectedAmount.value = int.parse(newValue.toString());
              //       startDateText.clear();
              //       start.value = "";
              //       end.value = "";
              //     },
              //   ),
              //   visible: selectedPlanID == 1,
              // ),

              // Visibility(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             ElevatedButton(
              //               onPressed: () {
              //                 if(selectedAmount.value > 1){
              //                   selectedAmount.value -= 1;
              //                   startDateText.clear();
              //                   start.value = "";
              //                   end.value = "";
              //                 }
              //               },
              //               child: Icon(Icons.remove, color: Colors.white),
              //               style: ElevatedButton.styleFrom(
              //                 shape: CircleBorder(),
              //                 padding: EdgeInsets.all(10),
              //                 backgroundColor: Colors.black,
              //                 foregroundColor: colors.Colors().deepYellow(1),
              //               ),
              //             ),
              //             SizedBox(width: 16),
              //             Obx(()=>Text("${selectedAmount.value}", style: TypographyStyles.title(30).copyWith(color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),)),),
              //             SizedBox(width: 16),
              //             ElevatedButton(
              //               onPressed: () {
              //                 selectedAmount.value += 1;
              //                 startDateText.clear();
              //                 start.value = "";
              //                 end.value = "";
              //               },
              //               child: Icon(Icons.add, color: Colors.white),
              //               style: ElevatedButton.styleFrom(
              //                 shape: CircleBorder(),
              //                 padding: EdgeInsets.all(10),
              //                 backgroundColor: Colors.black, // <-- Button color
              //                 foregroundColor: colors.Colors().deepYellow(1), // <-- Splash color
              //               ),
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              //   visible: selectedPlanID == 2,
              // ),

              SizedBox(height: 20,),

              TextField(
                controller: startDateText,
                readOnly: true,
                onTap: (){

                  final DateRangePickerController _controller = DateRangePickerController();
                  final DateRangePickerController _controller2 = DateRangePickerController();

                  debugPrint(selectedAmount.value.toString());

                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))
                    ),
                    builder: (BuildContext bc){
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Center(
                          child: Container(width: Get.width /1.2,
                            child: SfDateRangePicker(
                              controller: _controller2,
                              onSelectionChanged: (DateRangePickerSelectionChangedArgs args){

                                DateTime date = args.value;

                                duration.value = date.difference(date).inDays + 1;

                                _controller2.selectedDate = date;

                                startDateText.text = DateFormat("dd-MM-yyyy").format(date);

                                start.value = DateFormat("MMM dd, yyyy").format(date).toString();
                                end.value = DateFormat("MMM dd, yyyy").format(date.add(Duration(days: plan['duration_amount']))).toString();
                              },
                              monthCellStyle: DateRangePickerMonthCellStyle(
                                  textStyle: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : AppColors.primary2Color,),
                                  disabledDatesTextStyle: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : AppColors.primary2Color,),
                                  todayTextStyle: TypographyStyles.normalText(16, Themes.mainThemeColor.shade500)
                              ),
                              selectionMode: DateRangePickerSelectionMode.single,
                              showNavigationArrow: true,
                              minDate: DateTime(min.year, min.month, min.day),
                              headerStyle: DateRangePickerHeaderStyle(
                                textStyle: TypographyStyles.boldText(20, Themes.mainThemeColorAccent.shade100),
                              ),
                              monthViewSettings: DateRangePickerMonthViewSettings(
                                  dayFormat: 'EEE',
                              ),
                              headerHeight: 80,
                            ),
                          ),
                        )
                      );
                    }
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Select Start Date',
                  labelStyle: TextStyle(
                    color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                  ),
                  suffixIcon: Icon(Icons.calendar_today_outlined, color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.3) : AppColors.primary2Color,),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(()=>Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? AppColors.primary2Color : colors.Colors().lightCardBG,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("BOOKING SUMMARY",
                      style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.5) : colors.Colors().lightBlack(1),),
                    ),
                    SizedBox(height: 15,),
                    Container(
                      decoration: BoxDecoration(
                        // color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().selectedCardBG,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Start Date",
                                    style: TypographyStyles.title(20),
                                  ),
                                  SizedBox(height: 5,),
                                    Text(start.value != "" ? "${start.value}" : "-",
                                    style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                                  ),
                                ],
                              ),
                            ),
                            Container(height: 50, width: 1,
                              color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.5) : colors.Colors().darkGrey(0.5),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("End Date",
                                    style: TypographyStyles.title(20),
                                  ),
                                  SizedBox(height: 5,),
                                  Text(end.value != "" ? "${end.value}" : "-",
                                    style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 5,),

                    Divider(thickness: 1, color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.5) : colors.Colors().lightBlack(0.3),),

                    SizedBox(height: 5,),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text("GST ( 6% )",
                    //       style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
                    //     ),
                    //     Text("MVR ${(selectedAmount.value * plan["real_price"] * 0.06).toStringAsFixed(2)}",
                    //       style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
                    //     ),
                    //   ],
                    // ),

                    SizedBox(height: 10,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Amount",
                          style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
                        ),
                        Text("MVR ${plan["real_price"]}",
                          style: TypographyStyles.boldText(16, Themes.mainThemeColor.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10,),

            Container(
              width: Get.width,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Buttons.yellowFlatButton(
                label:"confirm to pay",
                onPressed: () {
                  if(start.value != "" && end.value != ""){
                    confirmAndPay(
                        selectedPlanID == 0 ? "Monthly" : selectedPlanID == 1 ? "Weekly" : "Daily",
                      duration.value,
                      start.value,
                      0.0,
                    );
                  }else{
                    showSnack("No Date(s) Selected", "Please select Date(s) or Date range");
                  }
                },
              ),
            ),
          ],
        ),
      ),),
    );
  }
}

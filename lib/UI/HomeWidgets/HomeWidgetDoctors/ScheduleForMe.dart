import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/ThemeBdayaStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/UI/SharedWidgets/PaymentVerification.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Controllers/TaxController.dart';
import '../../../Styles/AppColors.dart';
import '../../../Styles/SignUpStyles.dart';
import '../../../components/SessionTimePicker.dart';
import '../../SharedWidgets/PaymentSummary.dart';

class ScheduleForMe extends StatelessWidget {
  const ScheduleForMe({Key? key, this.doctor}) : super(key: key);

  final doctor;

  @override
  Widget build(BuildContext context) {
    print(doctor);

    RxBool ready = true.obs;
    RxMap walletData = {}.obs;

    TextEditingController dateTime = new TextEditingController();
    TextEditingController startTime = new TextEditingController();
    TextEditingController descriptionController = new TextEditingController();
    TextEditingController titleController = new TextEditingController();

    DateTime now = DateTime.now();
    late DateTime selectedDateTime = DateTime(now.year,now.month,now.day,0,0);

    String getChargingMethod() {
      return doctor['doctor']['charge_type'] == 'SESSION'
          ? '(Per Session)'
          : '(Per Hour)';
    }

    void payWithCard(DateTime dateTimeOfBooking,double total)async {
      Map res = await httpClient.doctorMeeting({
        'doctor_id': doctor['id'].toString(),
        'trainer_id': authUser.id.toString(),
        'client_id': authUser.id.toString(),
        'seconds': 3600,
        'role': authUser.role,
        'title': titleController.text,
        'description': descriptionController.text,
        'start_time': dateTimeOfBooking.toString(),
        'payment_type': 1,
      });
      if(res['code']==200){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        Get.to(()=>PaymentVerification());
      }else{
        showSnack("Booking Failed",res['data']['message'] );
      }
      print('===res');
      print(res);
    }
    void payWithEWallet(DateTime dateTimeOfBooking,double total)async {
      Map res = await httpClient.doctorMeeting({
        'doctor_id': doctor['id'].toString(),
        'trainer_id': authUser.id.toString(),
        'client_id': authUser.id.toString(),
        'seconds': 3600,
        'role': authUser.role,
        'title': titleController.text,
        'description': descriptionController.text,
        'start_time': dateTimeOfBooking.toString(),
        'payment_type': 2,
      });
      if (res['code'] == 200) {
        Get.offAll(() => Layout());
        showSnack('Booking Successful',
            'Your booking has been successfully placed.');
      } else {
        print(res);
        showSnack("Booking Failed",res['data']['message'] );
      }
    }

    void validateAndGo(DateTime dateTimeOfBooking, double total){

      if(dateTime.text.isEmpty){
          showSnack("Incomplete Information", "Please choose a date that falls before the scheduled meeting.",status: PopupNotificationStatus.warning);
          return;
      }
      if(startTime.text.isEmpty){
          showSnack("Incomplete Information", "Please select a time that precedes the scheduled meeting.",status: PopupNotificationStatus.warning);
          return;
      }
      if(titleController.text.isEmpty){
          showSnack("Incomplete Information", "Please provide a reason for scheduling the meeting.",status: PopupNotificationStatus.warning);
          return;
      }
      if(descriptionController.text.isEmpty){
          showSnack("Incomplete Information", "Please provide a additional details for scheduling the meeting.",status: PopupNotificationStatus.warning);
          return;
      }
      Get.to(()=>PaymentSummary(
        orderDetails: [
          SummaryItem(head: 'Doctor',value: 'Dr. ' + doctor['name'].toString().capitalize.toString(),),
          SummaryItem(head: 'Rate${getChargingMethod()}',value: 'MVR ' + doctor['doctor']['hourly_rate'].toStringAsFixed(2),),
          SummaryItem(head: 'Appointment Time',value: '${dateTime.text} ${startTime.text}',),
        ],
        total: total,
        payByCard: (){payWithCard(dateTimeOfBooking,total);},
        payByWallet: (){payWithEWallet(dateTimeOfBooking,total);},
      ));
    }

    void confirmAndPay(DateTime dateTimeOfBooking, double total) async {
      ready.value = false;
      Map res = await httpClient.getWallet();
      ready.value = true;

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
      } else {
        print(res);
      }

      Get.defaultDialog(
          radius: 5,
          title: '',
          titlePadding: EdgeInsets.zero,
          backgroundColor:
              Get.isDarkMode ? AppColors.primary2Color : Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "BOOKING SUMMARY",
                textAlign: TextAlign.center,
                style: TypographyStyles.title(20),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DOCTOR',
                    style: TypographyStyles.normalText(
                        16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${doctor['name']}',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
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
                    'Date:',
                    style: TypographyStyles.normalText(
                        16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${DateFormat("MMM dd,yyyy").format(dateTimeOfBooking).toString()}',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Divider(
                thickness: 1,
                color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time:',
                    style: TypographyStyles.normalText(
                        16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${DateFormat("hh:mm a").format(dateTimeOfBooking)}',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
                  ),
                ],
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
                    'Approx. Payment',
                    style: TypographyStyles.normalText(
                      16,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade100
                          : colors.Colors().lightBlack(1),
                    ),
                  ),
                  Text(
                    'MVR ${total.toStringAsFixed(2)}',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: 15),
            ],
          ),
          actions: [
            Container(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () async {
                  if (walletData.value['balance'] >=
                      double.parse(
                          doctor['doctor']['hourly_rate'].toString())) {
                    payWithEWallet(dateTimeOfBooking, total);
                  } else {
                    showSnack('Not Enough Balance',
                        'You do not have enough balance to pay for this booking');
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
                              'Pay with E-gift',
                              style: TypographyStyles.boldText(
                                  14, AppColors.textOnAccentColor),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              '(E-gift Balance: ${walletData['balance'].toStringAsFixed(2)})',
                              style: TypographyStyles.normalText(
                                  12, AppColors.textOnAccentColor),
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
                  Get.back();
                  payWithCard(dateTimeOfBooking,total);
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
                              'Tax amount: MVR ${(taxController.getCalculatedTax(double.parse(
                                  doctor['doctor']['hourly_rate'].toString()))).toStringAsFixed(2)}',
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accentColor,
                  width: 1.25,
                ),
              ),
              child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TypographyStyles.title(20),
                  )),
            ),
            SizedBox(
              height: 5,
            ),
          ]);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Channel for Me',
          style: TypographyStyles.title(20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color:
                      Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: CachedNetworkImageProvider(
                            HttpClient.s3BaseUrl + doctor['avatar_url']),
                      ),
                      SizedBox(
                        width: 26,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctor['doctor']['speciality'],
                                style: TextStyle(
                                  color: Color(0xFFFFB700),
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                )),
                            SizedBox(height: 5),
                            Text(
                              'Dr. ' + doctor['name'],
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: TypographyStyles.title(20),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rate ',
                                    style: TypographyStyles.textWithWeight(
                                        16, FontWeight.w400)),
                                Text(getChargingMethod(),
                                    style: TypographyStyles.textWithWeight(
                                        16, FontWeight.w400)),
                                Spacer(),
                                Text(
                                    'MVR ' +
                                        doctor['doctor']['hourly_rate']
                                            .toStringAsFixed(2),
                                    style: TextStyle(
                                      color: Color(0xFFFFB700),
                                      fontSize: 20,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text('Appointment for you', style: TypographyStyles.title(18)),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: ((Get.width - 32) / 2) - 8,
                    child: TextField(
                      controller: dateTime,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        DatePickerBdaya.showDatePicker(
                          context,
                          theme: ThemeBdayaStyles.main(),
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          currentTime: DateTime.now(),
                          onChanged: (date) {
                            print('change $date');
                          },
                          onConfirm: (date) {
                            print('confirm $date');

                            selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                selectedDateTime.hour,
                                selectedDateTime.minute);
                            dateTime.text = DateFormat("MMM dd,yyyy")
                                .format(date)
                                .toString();
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    width: ((Get.width - 32) / 2) - 8,
                    child: TextField(
                      controller: startTime,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Icon(Icons.access_time_rounded),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                          SessionTimePicker(
                            initial: selectedDateTime,
                            onConfirm: (date) {
                              print('confirm $date');
                              selectedDateTime = date;
                              startTime.text =
                                  '${DateFormat("HH:mm").format(date).toString()}';
                            },
                          );

                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: titleController,
                maxLength: 250,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLength: 250,
                decoration: InputDecoration(
                  labelText: 'Additional details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(36, 5, 36, 15),
        child: Container(
          width: Get.width,
          height: 44,
          child: Obx(() => ElevatedButton(
                style: ButtonStyles.bigFlatYellowButton(),
                child: ready.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_call_outlined),
                          SizedBox(width: 8),
                          Text(
                            'Schedule Meeting',
                            style: TextStyle(
                              color: Color(0xFF1B1F24),
                              fontSize: 20,
                              fontFamily: 'Bebas Neue',
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
                onPressed: () {
                  validateAndGo(selectedDateTime,double.parse(doctor['doctor']['hourly_rate'].toString()));
                  // confirmAndPay(selectedDateTime,
                  //     double.parse(doctor['doctor']['hourly_rate'].toString()));
                  // if (descriptionController.text.isNotEmpty) {
                  //   confirmAndPay(
                  //       selectedDateTime,
                  //       double.parse(
                  //           doctor['doctor']['hourly_rate'].toString()));
                  // } else {
                  //   showSnack('Description is empty!',
                  //       'please add a description about the meeting');
                  // }
                },
              )),
        ),
      ),
    );
  }
}

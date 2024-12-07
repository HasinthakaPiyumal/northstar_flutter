import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/UI/SharedWidgets/PaymentSummary.dart';
import 'package:north_star/UI/SharedWidgets/PaymentVerification.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/DropDownButtonWithBorder.dart';
import 'package:north_star/components/SessionTimePicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../Styles/BoxStyles.dart';
import '../../../../components/Buttons.dart';
import '../../../SharedWidgets/CommonConfirmDialog.dart';

class AddBooking extends StatelessWidget {
  const AddBooking({Key? key, required this.gymObj, required this.clientIds})
      : super(key: key);
  final gymObj;
  final List<int> clientIds;

  @override
  Widget build(BuildContext context) {
    Rx<DateTime> selectedDate = DateUtils.dateOnly(
      DateTime.now().add(
        Duration(days: 1),
      ),
    ).obs;

    print('Gym services');
    print(gymObj['gym_services']);

    RxList<Map> availableTimes = RxList();
    RxString selectedTime = "".obs;
    RxInt quantity = 0.obs;
    Rx<DateTime> selectedDay = DateTime.now().add(Duration(days: 1)).obs;
    Rx<DateTime> focusedDay = DateTime.now().add(Duration(days: 1)).obs;

    RxBool ready = true.obs;
    RxList bookings = [].obs;


    RxString couponCode = "".obs;
    RxDouble couponValue = 0.0.obs;

    RxDouble totalPrice = 0.0.obs;

    RxBool isAvailable = false.obs;

    void payByCard(coupon) async {
      ready.value = false;
      Map res = await httpClient.confirmSchedulesForService({
        'booking_ids':bookings,
        'service_id':gymObj['gym_services']['id'],
        'couponCode':coupon,
        'paymentType':1
      });

      print(res);
      if (res['code'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        Get.to(()=>PaymentVerification());
      } else {
        showSnack("Booking Failed",res['data']['message'] );
      }
      ready.value = true;
    }

    void informUser(){
      clientIds.forEach((element) {
        print("Sending notification to client");
        print('GYM object $gymObj');

        bookings.forEach((bookingElement) {
          DateTime time = DateFormat("hh:mm a").parse(selectedTime.value);

          DateTime stTime = DateTime(
            selectedDay.value.year,
            selectedDay.value.month,
            selectedDay.value.day,
            time.hour,
            time.minute,
          );

          String formattedStartTime = DateFormat('h:mm a').format(stTime);
          String formattedDate = DateFormat('EEEE, MMM d').format(stTime);

          String notes = "New Service booked for you at $formattedStartTime on $formattedDate.";
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


    void payWithWallet(coupon)async{
        Map res = await httpClient.confirmSchedulesForService({
          'booking_ids':bookings,
          'service_id':gymObj['gym_services']['id'],
          'couponCode':coupon,
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
    }


    void validateAndGo(){
      Get.to(()=>PaymentSummary(
        orderDetails: [
          SummaryItem(head: 'Total Hours',value: quantity.value.toString(),),
          SummaryItem(head: 'Amount',value: "MVR "+(gymObj['gym_services']['price'] * clientIds.length * quantity.value).toStringAsFixed(2),),
        ],
        total: (gymObj['gym_services']['price'] * clientIds.length * quantity.value).toDouble(),
        payByCard: (coupon){payByCard(coupon);},
        payByWallet: (coupon){payWithWallet(coupon);},
        isCouponAvailable: true,
        couponData:{
          'type': 3,
          'typeId': gymObj['gym_services']['id'],
        },
      ));
    }


    String formatTimeWithAMPM(String time) {
      try {
        DateTime dateTime = DateTime.parse(time);

        return DateFormat("hh:mm a").format(dateTime);
      } catch (e) {
        print(e);
        return time;
      }
    }

    void makeASchedule() async {
      ready.value = false;
      DateTime time = DateFormat("hh:mm a").parse(selectedTime.value);

      DateTime startDT = DateTime(
        selectedDay.value.year,
        selectedDay.value.month,
        selectedDay.value.day,
        time.hour,
        time.minute,
      );

      DateTime endDT = startDT.add(Duration(hours: quantity.value));

      Map res = await httpClient.makeAScheduleForService(
          gymObj['gym_services']['id'], clientIds, startDT,endDT);
      print(res);
      // res['code'] = 200;
      if (res['code'] == 422) {
        showSnack(
            'Already a Booking at this time!', res['data']['info']['message']);
        ready.value = true;
      }

      if (res['code'] == 403) {
        showSnack('Insufficient Balance!', res['data']['message']);
        ready.value = true;
      }

      if (res['code'] == 200) {
        bookings.value = [res['data']['booking_id']];
        validateAndGo();
      }
    }

    void getAvailableTimeSlots(dateTime) async {
      ready.value = false;
      Map res = await httpClient.getAvailableTimeSlots(gymObj['gym_services']['id'], dateTime);
      print('Time slots');
      print(res);
      print(dateTime.toString());
      selectedTime.value = "";
      availableTimes.clear();
      if (res['code'] == 200) {
        isAvailable.value = true;
        selectedTime.value = "";
        quantity.value = 0;
        String serviceStartTime = gymObj['gym_services']['start_time'];
        availableTimes.value = List.generate(
          res['data'].length,
          (index) {
            return {
              'time': DateTime.parse(serviceStartTime).add(
                Duration(hours: index),
              ),
              'availability': res['data'][index]
            };
          },
        );
        ready.value = true;
      }else{
        quantity.value = 0;
        isAvailable.value = false;
        ready.value = true;
      }
    }

    getAvailableTimeSlots(selectedDay.value);

    return Scaffold(
        appBar: AppBar(
          title: Text('Booking Date'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color:
                        Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Obx(
                  () => TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: focusedDay.value,
                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: false,
                      defaultDecoration: BoxDecorations().commonCalendarDec,
                      disabledDecoration: BoxDecorations().commonCalendarDec,
                      outsideDecoration: BoxDecorations().commonCalendarDec,
                      todayDecoration: BoxDecoration(
                          // color: colors.Colors().deepYellow(1),
                          // borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                      weekendDecoration: BoxDecorations().commonCalendarDec,
                      selectedDecoration: BoxDecoration(
                        color: colors.Colors().deepYellow(1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      cellMargin: const EdgeInsets.all(0),
                      selectedTextStyle: TypographyStyles.title(12).copyWith(
                        color: Colors.white,
                      ),
                      weekendTextStyle: TypographyStyles.title(12).copyWith(
                        color: Colors.white,
                      ),
                      defaultTextStyle: TypographyStyles.title(12).copyWith(
                        color: Colors.white,
                      ),
                    ),
                    daysOfWeekHeight: 40,
                    rowHeight: 40,
                    calendarFormat: CalendarFormat.twoWeeks,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.w600),
                      headerMargin: EdgeInsets.zero,
                      headerPadding: EdgeInsets.only(bottom: 10),
                      leftChevronPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      rightChevronPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TypographyStyles.title(12)
                          .copyWith(color: colors.Colors().lightWhite(0.6)),
                      weekendStyle: TypographyStyles.title(12)
                          .copyWith(color: colors.Colors().lightWhite(0.6)),
                    ),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onDaySelected: (selected, focused) {
                      selectedDay.value = selected;
                      focusedDay.value = focused;
                      selectedDate.value = selected;
                      getAvailableTimeSlots(selected);
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay.value, day);
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pick a time slot',
                textAlign: TextAlign.start,
                style: TypographyStyles.title(16),
              ),
            ),
            Obx(() => Visibility(
              visible: isAvailable.value && ready.value,
              child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Start Time',
                          textAlign: TextAlign.start,
                          style: TypographyStyles.text(16),
                        ),
                        Container(
                            width: Get.width - 160,
                            child: availableTimes
                                .map((item) => item['availability']
                                ? formatTimeWithAMPM(
                                item['time'].toString())
                                : '-')
                                .where((time) => time != '-')
                                .toSet()
                                .toList().length>0?DropdownButtonWithBorder(
                                width: Get.width - 200,
                                items: availableTimes
                                    .map((item) => item['availability']
                                        ? formatTimeWithAMPM(
                                            item['time'].toString())
                                        : '-')
                                    .where((time) => time != '-')
                                    .toSet()
                                    .toList(),
                                selectedValue: selectedTime.value != ""
                                    ? selectedTime.value
                                    : null,
                                onChanged: (val) {
                                  quantity.value = 1;
                                  selectedTime.value = val;
                                }):Text('No available time slots',textAlign: TextAlign.end,)),
                      ],
                    ),
                  ),
            )),
            Obx(
              () => Visibility(
                visible: isAvailable.value && ready.value,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'End Time',
                        textAlign: TextAlign.start,
                        style: TypographyStyles.text(16),
                      ),
                      Text(
                        selectedTime.value != ""
                            ? formatTimeWithAMPM(DateFormat('hh:mm a')
                                .parse(selectedTime.value)
                                .add(Duration(hours: quantity.value))
                                .toString())
                            : '-',
                        textAlign: TextAlign.start,
                        style: TypographyStyles.text(16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Obx(() => Visibility(
              visible: isAvailable.value && ready.value,
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Buttons.yellowFlatButton(
                            onPressed: () {
                              quantity.value = quantity.value - 1;
                            },
                            disabled: quantity.value<2||selectedTime.value == "",
                            height: 30,
                            width: 100,
                            label: 'Remove one hour'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Buttons.yellowFlatButton(
                            onPressed: () {
                              quantity.value = quantity.value + 1;
                            },
                            disabled: selectedTime.value == "" ||
                                !availableTimes
                                    .map((item) => item['availability']
                                        ? formatTimeWithAMPM(
                                            item['time'].toString())
                                        : '-')
                                    .where((time) => time != '-')
                                    .toSet()
                                    .toList()
                                    .contains(formatTimeWithAMPM(
                                        DateFormat('hh:mm a')
                                            .parse(selectedTime.value)
                                            .add(Duration(hours: quantity.value))
                                            .toString())),
                            height: 30,
                            width: 100,
                            label: 'Add One Hour'),
                      ),
                    ],
                  ),
            )),
            Obx(()=>Visibility(
              visible: !isAvailable.value && ready.value,
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(child: Text("Not available")),
            ))),
            Obx(()=>Visibility(
              visible: !ready.value,
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(child: CircularProgressIndicator()),
            ))),

            Obx(
              () => Padding(
                padding: EdgeInsets.fromLTRB(15, 40, 15, 90),
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'BOOKING SUMMARY',
                          style: TypographyStyles.boldText(
                              14,
                              Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade300
                                  : colors.Colors().darkGrey(1)),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Hours',
                              style: TypographyStyles.normalText(
                                  16,
                                  Get.isDarkMode
                                      ? Themes.mainThemeColorAccent.shade100
                                      : colors.Colors().lightBlack(1)),
                            ),
                            Text(
                              quantity.value.toString(),
                              style: TypographyStyles.boldText(
                                  22,
                                  Get.isDarkMode
                                      ? Themes.mainThemeColorAccent.shade100
                                      : colors.Colors().lightBlack(1)),
                            )
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TypographyStyles.normalText(
                                  16,
                                  Get.isDarkMode
                                      ? Themes.mainThemeColorAccent.shade100
                                      : colors.Colors().lightBlack(1)),
                            ),
                            Text(
                              "MVR ${(gymObj['gym_services']['price'] * clientIds.length * quantity.value).toStringAsFixed(2)}",
                              style: TypographyStyles.boldText(
                                  22,
                                  Get.isDarkMode
                                      ? Themes.mainThemeColorAccent.shade100
                                      : colors.Colors().lightBlack(1)),
                            )
                          ],
                        ),
                      ],
                    ),
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
            child: Buttons.yellowFlatButton(
              label: "confirm",
              onPressed: () {
                CommonConfirmDialog.confirm('Confirm').then((value) {
                  if (value) {
                    makeASchedule();
                  }
                });
              },
            )));
  }
}

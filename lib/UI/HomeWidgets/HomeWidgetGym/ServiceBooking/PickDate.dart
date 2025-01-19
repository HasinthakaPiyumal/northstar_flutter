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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:north_star/Models/AuthUser.dart';

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
    Rx<DateTime> selectedDay = DateTime.now().obs;
    Rx<DateTime> focusedDay = DateTime.now().obs;

    DateTime serviceStartDateTime =
        DateTime.parse(gymObj['gym_services']['start_time'] + 'Z').toLocal();
    DateTime serviceEndDateTime =
        DateTime.parse(gymObj['gym_services']['end_time'] + 'Z').toLocal();

    RxBool ready = true.obs;
    RxList bookings = [].obs;

    RxString couponCode = "".obs;
    RxDouble couponValue = 0.0.obs;

    RxDouble totalPrice = 0.0.obs;

    RxBool isAvailable = false.obs;

    void payByCard(coupon) async {
      ready.value = false;
      Map res = await httpClient.confirmSchedulesForService({
        'booking_ids': bookings,
        'service_id': gymObj['gym_services']['id'],
        'couponCode': coupon,
        'paymentType': 1
      });

      print(res);
      if (res['code'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        Get.to(() => PaymentVerification());
      } else {
        showSnack("Booking Failed", res['data']['message']);
      }
      ready.value = true;
    }

    void informUser() {
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

          String notes =
              "New Service booked for you at $formattedStartTime on $formattedDate.";
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
            'You have a gym service session ${gymObj['gym_services']['name']}-${gymObj['gym_city']}',
            NSNotificationTypes.GymAppointment, {});
      });
    }

    bool isTimeInRange(DateTime target, DateTime startTime, DateTime endTime) {
      DateTime now = target;

      if (startTime.isAtSameMomentAs(target)) return true;

      if (startTime.isBefore(endTime)) {
        return now.isAfter(startTime) && now.isBefore(endTime);
      } else {
        return now.isAfter(startTime) || now.isBefore(endTime);
      }
    }

    void payWithWallet(coupon) async {
      Map res = await httpClient.confirmSchedulesForService({
        'booking_ids': bookings,
        'service_id': gymObj['gym_services']['id'],
        'couponCode': coupon,
        'paymentType': 2
      });
      if (res['code'] == 200) {
        informUser();
        Get.offAll(() => Layout());
        showSnack('Schedule Confirmed!',
            'You have paid for an NS Service ${gymObj['gym_services']['name']}-${gymObj['gym_city']}');
      } else {
        print(res);
      }
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

    void validateAndGo() {
      Get.to(() => PaymentSummary(
            orderDetails: [
              SummaryItem(
                head: 'Total Hours',
                value: quantity.value.toString(),
              ),
              SummaryItem(
                head: 'Booking Date',
                value: DateFormat('EEEE, MMM d').format(selectedDay.value),
              ),
              SummaryItem(
                head: 'Time',
                value:
                    '${selectedTime.value} - ${formatTimeWithAMPM(DateFormat('hh:mm a').parse(selectedTime.value).add(Duration(hours: quantity.value)).toString())}',
              ),
              SummaryItem(
                head: 'Amount',
                value: "MVR " +
                    (gymObj['gym_services']['price'] *
                            clientIds.length *
                            quantity.value)
                        .toStringAsFixed(2),
              ),
            ],
            total: (gymObj['gym_services']['price'] *
                    clientIds.length *
                    quantity.value)
                .toDouble(),
            payByCard: (coupon) {
              payByCard(coupon);
            },
            payByWallet: (coupon) {
              payWithWallet(coupon);
            },
            isCouponAvailable: true,
            couponData: {
              'type': 3,
              'typeId': gymObj['gym_services']['id'],
            },
          ));
    }

    DateTime combineDateWithTime(DateTime targetDate, DateTime targetTime) {
      return DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        targetTime.hour,
        targetTime.minute,
        targetTime.second,
        targetTime.millisecond,
        targetTime.microsecond,
      );
    }

    void makeASchedule() async {
      if (selectedTime.value == "") {
        showSnack(
            'No time slot selected!', 'Please select a time slot to book.',
            status: PopupNotificationStatus.error);
        return;
      }
      ready.value = false;
      DateTime time = DateFormat("hh:mm a").parse(selectedTime.value);

      DateTime startDT = DateTime(
        selectedDay.value.year,
        selectedDay.value.month,
        selectedDay.value.day,
        time.hour,
        time.minute,
      ).toUtc();

      DateTime endDT = startDT.add(Duration(hours: quantity.value));

      Map res = await httpClient.makeAScheduleForService(
          gymObj['gym_services']['id'], clientIds, startDT, endDT);
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
        ready.value = true;
        validateAndGo();
      }
    }

    String _formatDuration(Duration duration) {
      String sign = duration.isNegative ? '-' : '+';
      int hours = duration.inHours.abs();
      int minutes = duration.inMinutes.abs() % 60;

      // Format as "+HH:MM" or "-HH:MM"
      return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }

    void getAvailableTimeSlots(dateTime) async {
      ready.value = false;

      DateTime startOfDay =
          DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
      DateTime endOfDay =
          DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);

      print(
          "Start of the Day: ${startOfDay.toIso8601String()} ${startOfDay.timeZoneName}");

      print("Start Time: ${startOfDay}");
      print("End Time: ${endOfDay.toString()}");
      print("End Time: $dateTime");
      Map res = await httpClient.getAvailableTimeSlots(
          gymObj['gym_services']['id'],
          dateTime,
          _formatDuration(DateTime.now().timeZoneOffset));
      print('Time slots');
      print(res);

      selectedTime.value = "";
      availableTimes.clear();

      if (res['code'] == 200) {
        isAvailable.value = true;
        selectedTime.value = "";
        quantity.value = 0;
        DateTime serviceStartTime = combineDateWithTime(
            dateTime,
            DateTime.parse(gymObj['gym_services']['start_time'] + 'Z')
                .toLocal());
        DateTime serviceEndTime = combineDateWithTime(dateTime,
            DateTime.parse(gymObj['gym_services']['end_time'] + 'Z').toLocal());
        // availableTimes.value = List.generate(
        //   res['data'].length,
        //   (index) {
        //     print(DateTime.parse(serviceStartTime).toString());
        //     print(DateTime.parse(serviceStartTime).toLocal().toString());
        //     return {
        //       'time': DateTime.parse(serviceStartTime).add(
        //         Duration(hours: index),
        //       ),
        //       'availability': res['data'][index]
        //     };
        //   },
        // );
        for (int i = 0; i < 24; i++) {
          DateTime checkingTime = serviceStartTime.add(
            Duration(hours: i),
          );
          print('checkingTime');
          print(checkingTime);
          print(serviceStartTime);
          print(serviceEndTime);
          print('isAfter ${serviceEndTime.isBefore(checkingTime)}');
          if (serviceEndTime.isBefore(checkingTime.add(Duration(hours: 1)))) {
            break;
          }
          bool isBooked = false;
          for (int j = 0; j < res['data'].length; j++) {
            dynamic item = res['data'][j];
            bool isReserved = isTimeInRange(
                checkingTime,
                DateTime.parse(item['start_time'] + 'Z').toLocal(),
                DateTime.parse(item['end_time'] + 'Z').toLocal());
            print('Is Reserved: $isReserved');
            print(
                '$isReserved $checkingTime ${DateTime.parse(item['start_time'] + 'Z').toLocal()} ${DateTime.parse(item['end_time'] + 'Z').toLocal()}');

            if (isReserved) {
              isBooked = true;
              break;
            }
          }
          print('checkingTime $checkingTime');

          // Only add times that are after current time
          if (checkingTime.isAfter(DateTime.now())) {
            availableTimes
                .add({'time': checkingTime, 'availability': !isBooked});
          }
        }
        ready.value = true;
      } else {
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
                    firstDay: DateTime.now().isBefore(serviceStartDateTime)
                        ? serviceStartDateTime
                        : DateTime.now(),
                    lastDay: serviceEndDateTime,
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
                                        .toList()
                                        .length >
                                    0
                                ? DropdownButtonWithBorder(
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
                                    })
                                : Text(
                                    'No available time slots',
                                    textAlign: TextAlign.end,
                                  )),
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
                            disabled:
                                quantity.value < 2 || selectedTime.value == "",
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
                                    .contains(formatTimeWithAMPM(DateFormat(
                                            'hh:mm a')
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
            Obx(() => Visibility(
                visible: !isAvailable.value && ready.value,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(child: Text("Not available")),
                ))),
            Obx(() => Visibility(
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
        bottomSheet: Obx(
          () => Container(
              width: Get.width,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Buttons.yellowFlatButton(
                label: "confirm",
                isLoading: !ready.value,
                onPressed: () {
                  CommonConfirmDialog.confirm('Confirm',
                          hintText:
                              'This service is available for 45 minutes from the start time provided.')
                      .then((value) {
                    if (value) {
                      makeASchedule();
                    }
                  });
                },
              )),
        ));
  }
}

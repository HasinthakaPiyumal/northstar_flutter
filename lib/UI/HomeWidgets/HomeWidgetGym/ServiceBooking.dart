import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/SessionTimePicker.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../Styles/BoxStyles.dart';
import '../../../../components/Buttons.dart';
import '../../SharedWidgets/CommonConfirmDialog.dart';

class ServiceBooking extends StatelessWidget {
  const ServiceBooking(
      {Key? key, required this.gymObj, required this.clientIDs})
      : super(key: key);
  final gymObj;
  final clientIDs;

  @override
  Widget build(BuildContext context) {
    print(gymObj);
    RxList<DateTime> dates = List.generate(
        7,
        (index) => DateUtils.dateOnly(
            DateTime.now().add(Duration(days: index + 1)))).obs;
    Rx<DateTime> selectedDate =
        DateUtils.dateOnly(DateTime.now().add(Duration(days: 1))).obs;

    RxList<DateTime> times = List.generate(
        7,
        (index) => DateUtils.dateOnly(
            DateTime.now().add(Duration(days: index + 1)))).obs;
    Rx<DateTime> selectedStartTime =
        DateUtils.dateOnly(DateTime.now().add(Duration(days: 1))).obs;
    Rx<DateTime> selectedEndTime =
        DateUtils.dateOnly(DateTime.now().add(Duration(days: 1, hours: 2))).obs;

    TextEditingController startTime = new TextEditingController();
    TextEditingController endTime = new TextEditingController();

    Rx<DateTime> focusedDay = DateTime.now().add(Duration(days: 1)).obs;
    Rx<DateTime> selectedDay = DateTime.now().add(Duration(days: 1)).obs;

    RxList<bool> availability = List.generate(25, (index) => true).obs;
    RxBool ready = true.obs;
    void getAvailabilities(dateTime) async {
      Map res = await httpClient.getAvailability(gymObj['user_id'], dateTime);
      if (res['code'] == 200) {
        availability.value =
            List.generate(25, (index) => res['data'][index] == true).toList();
      }
    }

    void makeASchedule() async {
      ready.value = false;
      int dateDifferent =
          selectedDay.value.difference(selectedEndTime.value).inDays;
      print("DUration-->$dateDifferent");
      selectedStartTime.value =
          selectedStartTime.value.add(Duration(days: dateDifferent));
      selectedEndTime.value =
          selectedEndTime.value.add(Duration(days: dateDifferent));
      int hourlyRate = gymObj['hourly_rate'] *
          selectedEndTime.value.difference(selectedStartTime.value).inHours;
      print(selectedStartTime);
      Map res = await httpClient.makeASchedule(
        gymObj['user_id'],
        clientIDs,
        selectedStartTime.value,
        selectedEndTime.value,
        hourlyRate * 100,
      );
      print(res);
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
        Get.back();
      }
    }

    bool checkEndTimeAvailability(startTime, endTime, index) {
      bool conditionOne =
          endTime.difference(selectedStartTime.value).inHours > 0;

      int propIndex = index == 0 ? 1 : index;
      bool conditionTwo = availability[propIndex - 1] == true;

      return conditionOne && conditionTwo;
    }

    void generateTimes(DateTime date) {
      times.value = List.generate(25, (index) {
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
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Select your booking days',
                textAlign: TextAlign.start,
                style: TypographyStyles.text(16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
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
                      isTodayHighlighted: true,
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
                    daysOfWeekHeight: 30,
                    rowHeight: 40,
                    calendarFormat: CalendarFormat.month,
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
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay.value, day);
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Select start time & end time',
                textAlign: TextAlign.start,
                style: TypographyStyles.text(16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: ((Get.width - 32) / 2) - 8,
                    child: TextField(
                      readOnly: true,
                      controller: startTime,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Icon(Icons.access_time_rounded),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        SessionTimePicker(
                          initial: selectedStartTime.value,
                          onConfirm: (date) {
                            selectedStartTime.value = date;
                            startTime.text = DateFormat('HH:mm').format(date);
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    width: ((Get.width - 32) / 2) - 8,
                    child: TextField(
                      readOnly: true,
                      controller: endTime,
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        prefixIcon: Icon(Icons.access_time_rounded),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        SessionTimePicker(
                          initial: selectedEndTime.value,
                          onConfirm: (date) {
                            print('confirm $date');
                            selectedEndTime.value = date;
                            endTime.text = DateFormat('HH:mm').format(date);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 40, 15, 15),
              child: Container(
                width: Get.width,
                decoration: BoxDecoration(
                    color:
                        Get.isDarkMode ? AppColors.primary2Color : Colors.white,
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
                            'Date',
                            style: TypographyStyles.normalText(
                                16,
                                Get.isDarkMode
                                    ? Themes.mainThemeColorAccent.shade300
                                    : colors.Colors().darkGrey(1)),
                          ),
                          Obx(() => Text(
                                DateFormat('EEEE, MMMM d')
                                    .format(selectedDate.value),
                                style: TypographyStyles.boldText(
                                    16,
                                    Get.isDarkMode
                                        ? Themes.mainThemeColorAccent.shade100
                                        : colors.Colors().lightBlack(1)),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time Slot',
                            style: TypographyStyles.normalText(
                                16,
                                Get.isDarkMode
                                    ? Themes.mainThemeColorAccent.shade300
                                    : colors.Colors().darkGrey(1)),
                          ),
                          Obx(
                            () => RichText(
                              text: TextSpan(
                                text:
                                    '${DateFormat('h:mm').format(selectedStartTime.value)}',
                                style: TypographyStyles.boldText(
                                  16,
                                  Get.isDarkMode
                                      ? Themes.mainThemeColorAccent.shade100
                                      : colors.Colors().lightBlack(1),
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        '${DateFormat(' a').format(selectedStartTime.value)}',
                                    style: TypographyStyles.normalText(
                                      12,
                                      Get.isDarkMode
                                          ? Themes.mainThemeColorAccent.shade100
                                          : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                  TextSpan(
                                    text: " - ",
                                  ),
                                  TextSpan(
                                    text:
                                        "${DateFormat('h:mm').format(selectedEndTime.value)}",
                                    style: TypographyStyles.boldText(
                                      16,
                                      Get.isDarkMode
                                          ? Themes.mainThemeColorAccent.shade100
                                          : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${DateFormat(' a').format(selectedEndTime.value)}',
                                    style: TypographyStyles.normalText(
                                      12,
                                      Get.isDarkMode
                                          ? Themes.mainThemeColorAccent.shade100
                                          : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Divider(
                        thickness: 1,
                        color: Themes.mainThemeColorAccent.shade300
                            .withOpacity(0.6),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price ( ${selectedEndTime.value.difference(selectedStartTime.value).inHours} Hours )',
                            style: TypographyStyles.normalText(
                                16,
                                Get.isDarkMode
                                    ? Themes.mainThemeColorAccent.shade100
                                    : colors.Colors().lightBlack(1)),
                          ),
                          Obx(() => Text(
                                "MVR${(gymObj['hourly_rate'] * (selectedEndTime.value.difference(selectedStartTime.value).inHours)).toStringAsFixed(2)}",
                                style: TypographyStyles.boldText(
                                    22,
                                    Get.isDarkMode
                                        ? Themes.mainThemeColorAccent.shade100
                                        : colors.Colors().lightBlack(1)),
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
            child: Buttons.yellowFlatButton(
              label: "confirm",
              onPressed: () {

              },
            )));
  }
}
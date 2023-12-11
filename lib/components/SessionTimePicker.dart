import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Styles/AppColors.dart';
import '../Styles/TypographyStyles.dart';

class SessionTimePicker {
  SessionTimePicker(
      {required Null Function(dynamic date) onConfirm,
      required DateTime initial}) {
    DateTime now = DateTime.now();
    int hour = initial.hour;
    int minutes = initial.minute;
    int minH = (initial.year == now.year &&
            initial.month == now.month &&
            initial.day == now.day)
        ? now.hour
        : 0;
    minH = now.minute > 45 ? minH + 1 : minH;
    if (minH > hour) {
      hour = minH;
    }
    print(initial);
    int minM = (initial.year == now.year &&
            initial.month == now.month &&
            initial.day == now.day &&
            hour == now.hour)
        ? now.minute
        : 0;
    minM = minH <= hour ? ((minM ~/ 15) * 15) : ((minM ~/ 15) * 15) + 15;
    if (minM > minutes) {
      minutes = minM;
    }
    List<int> hoursList = [];
    List<int> minutesList = [];
    for (int h = minH; h < 24; h++) {
      hoursList.add(h);
    }
    for (int m = minM; m <= 45; m += 15) {
      minutesList.add(m);
    }
    FixedExtentScrollController _hourScrollController =
        FixedExtentScrollController(initialItem: hoursList.indexOf(hour));
    FixedExtentScrollController _minutesScrollController =
        FixedExtentScrollController(initialItem: minutesList.indexOf(minutes));

    Get.bottomSheet(
      SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              height: 340,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "Cancel",
                          style: TypographyStyles.textWithWeight(
                              16, FontWeight.w400),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back(result: {"h": hour, "m": minutes});
                        },
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: Color(0xFFFFB700),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: (Get.width - 80) / 2,
                          height: 250,
                          child: ListWheelScrollView.useDelegate(
                            controller: _hourScrollController,
                            itemExtent: 35,
                            diameterRatio: 1.5,
                            physics: FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                hour = hoursList[index];
                                minM = (initial.year == now.year &&
                                        initial.month == now.month &&
                                        initial.day == now.day &&
                                        hour == now.hour)
                                    ? now.minute
                                    : 0;
                                print("minH $minH");
                                print("hour $hour");
                                if (minH <= hour) {
                                  minM = ((minM ~/ 15) * 15);
                                } else {
                                  minM = ((minM ~/ 15) * 15) + 15;
                                }

                                if (minM > minutes) {
                                  minutes = minM;
                                }
                                minutesList = [];
                                for (int m = minM; m <= 45; m += 15) {
                                  minutesList.add(m);
                                }
                                // if(minH<hour){
                                //   _minutesScrollController.jumpToItem(minutesList.indexOf(minutes));
                                // }
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (BuildContext context, int index) {
                                final isSelected = hoursList[index] == hour;
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.07)
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${hoursList[index] < 10 ? "0" : ''}${hoursList[index]}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                              childCount: hoursList
                                  .length, // Change this to the desired range
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(":"),
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: (Get.width - 80) / 2,
                          height: 250,
                          child: ListWheelScrollView.useDelegate(
                            controller: _minutesScrollController,
                            itemExtent: 35,
                            diameterRatio: 1.5,
                            physics: FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                minutes = minutesList[index];
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (BuildContext context, int index) {
                                final isSelected =
                                    minutesList[index] == minutes;
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.07)
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${minutesList[index] == 0 ? "0" : ''}${minutesList[index]}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                              childCount: minutesList
                                  .length, // Change this to the desired range
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: true,
      persistent: false,
    ).then((value) {
      if (value != null && value['h'] is int && value['m'] is int) {
        print('Selected time: ${value['h']}:${value['m']}');
        DateTime selectedDateTime = DateTime(
          initial.year,
          initial.month,
          initial.day,
          value['h'],
          value['m'],
        );
        onConfirm(selectedDateTime);
      }
    });
  }
}

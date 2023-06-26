import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class TodoScheduleCalender extends StatelessWidget {
  const TodoScheduleCalender({Key? key, this.list}) : super(key: key);
  final list;
  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    Rx<DateTime> selectedDay = DateTime.now().subtract(Duration(days: 10)).obs;

    List getEventsForDay(DateTime day) {
      List events = [];
      String dateMod = day.toString().substring(0, 10);
      list.forEach((element) {
        String elementDate = element['endDate'].toString().substring(0, 10);
        if (elementDate == dateMod) {
          events.add(element);
          print('Has Event');
        }
      });
      return events;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Calender'),
      ),
      body:Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(()=> ready.value ? TableCalendar(
          onFormatChanged: (val){},
          startingDayOfWeek: StartingDayOfWeek.monday,
          firstDay: DateTime.utc(2021, 1, 1),
          lastDay: DateTime.utc(2050, 12, 31),
          focusedDay: selectedDay.value,
          onDaySelected: (sDay, fDay) {
            print(sDay);
            selectedDay.value = sDay;
          },
          calendarStyle: CalendarStyle(
            markerSize: 16,
            selectedDecoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),

            markerDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          eventLoader: (day) {
            return getEventsForDay(day);
          },
        ): Center(
          child: LinearProgressIndicator(),
        )),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleCalender extends StatelessWidget {
  const ScheduleCalender({Key? key, this.list}) : super(key: key);
  final list;
  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;

    List getEventsForDay(DateTime day) {
      List events = [];
      String dateMod = day.toString().substring(0, 10);
      list.forEach((element) {
        String elementDate = element['start_time'].toString().substring(0, 10);
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
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events){
                return Container(
                  child: events.length > 0 ? SizedBox(
                    height: 15,
                    width: 15,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Themes.mainThemeColor.shade500,
                      child: Text("${events.length}",
                        style: TypographyStyles.boldText(13, Colors.black),
                      ),
                    ),
                  ) : SizedBox(),
                );
              }
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
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

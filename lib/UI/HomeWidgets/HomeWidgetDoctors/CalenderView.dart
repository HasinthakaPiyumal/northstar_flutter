import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderView extends StatelessWidget {
  const CalenderView({Key? key, this.meetings}) : super(key: key);
  final meetings;
  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;

    List getEventsForDay(DateTime day) {
      String dtString = day.toString().split(' ')[0];

      List events = [];
      meetings.forEach((element) {
        if (element['start_time'].toString().split(' ')[0] == dtString) {
          events.add(element);
          print('Has Event');
        }
      });
      return events;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Calender',style: TypographyStyles.title(20),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Container(

              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Get.isDarkMode?AppColors.primary2Color:Colors.white,),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => ready.value ? TableCalendar(
                onFormatChanged: (val) {},

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
                            style: TypographyStyles.boldText(11, Colors.black),
                          ),
                        ),
                      ) : SizedBox(),
                    );
                  }
                ),
                calendarStyle: CalendarStyle(
                  // rowDecoration: BoxDecoration(color: AppColors.primary2Color),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentColor,
                  ),

                ),
                eventLoader: (day) {
                  return getEventsForDay(day);
                },

              ) : Center(
                child: LinearProgressIndicator(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

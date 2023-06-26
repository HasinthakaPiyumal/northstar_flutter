import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../Models/AuthUser.dart';
import '../../../Models/HttpClient.dart';
import '../../../Models/Meeting.dart';
import '../../../Models/MeetingDataSource.dart';

class ToDoEventsCalender extends StatelessWidget {
  const ToDoEventsCalender({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxList<Meeting> events = <Meeting>[].obs;

    void getEvents() async{
      ready.value = false;
      print(authUser.id);
      Map res = await httpClient.getAllEvents();
      Map res2 = await httpClient.getAllEventsInFitnessService();
      if(res['code'] == 200 && res2['code'] == 200){
        List commonList = res['data'];
        commonList.addAll(res2['data']);
        events.value = List.generate(commonList.length, (index) {
          return new Meeting(commonList[index]);
        });
        ready.value = true;
      } else {
        print(res2);
        ready.value = true;
      }
    }

    getEvents();

    CalendarController controller = CalendarController();


    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Calender'),
      ),
      body: Obx(()=> ready.value ? SfCalendar(
        firstDayOfWeek: 1,
        dataSource: MeetingDataSource(events.value),
        view: CalendarView.month,
        monthViewSettings: MonthViewSettings(showAgenda: true),

        showCurrentTimeIndicator: true,
        showNavigationArrow: true,
        showWeekNumber: true,
        controller: controller,
        onTap: (CalendarTapDetails event) {
          print(event.appointments?[0].to);
        },
      ) : Center(child: LoadingAndEmptyWidgets.loadingWidget())),
    );
  }
}


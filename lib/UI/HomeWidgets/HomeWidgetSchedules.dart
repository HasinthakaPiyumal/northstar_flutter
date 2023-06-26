import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:flutter_zoom_sdk/zoom_options.dart';
// import 'package:flutter_zoom_sdk/zoom_view.dart';

class HomeWidgetSchedules extends StatelessWidget {
  const HomeWidgetSchedules({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList meetings = [].obs;
    late Timer timer;

    // joinMeeting(BuildContext context, meetingID, meetingPassword) async {
    //   bool _isMeetingEnded(String status) {
    //     var result = false;


    //     if (Platform.isAndroid)
    //       result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
    //     else
    //       result = status == "MEETING_STATUS_IDLE";

    //     return result;
    //   }
    //   ZoomOptions zoomOptions = new ZoomOptions(
    //     domain: "zoom.us",
    //     appKey: "lEyBF3jYyimQaNqk8Di4VIVUgw5XVFJPh73H",
    //     appSecret: "KUOaQNqmt034e9q40A9IdiGxJTxjsgVTYhyb", //API SECRET FROM ZOOM
    //   );
    //   var meetingOptions = new ZoomMeetingOptions(
    //       userId: authUser.name,
    //       meetingId: meetingID,
    //       meetingPassword: meetingPassword,
    //       disableDialIn: "true",
    //       disableDrive: "true",
    //       disableInvite: "true",
    //       disableShare: "true",
    //       disableTitlebar: "false",
    //       viewOptions: "true",
    //       noAudio: "false",
    //       noDisconnectAudio: "false"
    //   );

    //   var zoom = ZoomView();
    //   zoom.initZoom(zoomOptions).then((results) {
    //     if(results[0] == 0) {
    //       zoom.onMeetingStatus().listen((status) {
    //         print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
    //         if (_isMeetingEnded(status[0])) {
    //           print("[Meeting Status] :- Ended");
    //           timer.cancel();
    //         }
    //       });
    //       print("listen on event channel");
    //       zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
    //         timer = Timer.periodic(new Duration(seconds: 2), (timer) {
    //           zoom.meetingStatus(meetingOptions.meetingId!)
    //               .then((status) {
    //             print("[Meeting Status Polling] : " + status[0] + " - " + status[1]);
    //           });
    //         });
    //       });
    //     }
    //   }).catchError((error) {
    //     print("[Error Generated] : " + error);
    //   });


    // }

    void getScheduled() async {
      ready.value = false;
      var request = http.Request('GET', Uri.parse(HttpClient.baseURL + '/api/meeting/doctor-meetings/my-meetings/'+ authUser.role.toString()+ '/' + authUser.id.toString()));
      request.headers.addAll(client.getHeader());

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = jsonDecode(await response.stream.bytesToString());
        print(res);
        meetings.value = res;
        ready.value = true;
      } else {
        print(await response.stream.bytesToString());
        print(response);
        ready.value = true;
      }
    }

    List getEventsForDay(DateTime day) {
      String dtString = day.toString().split(' ')[0];

      List events = [];
      meetings.forEach((element) {
        if (element['start_time'] == dtString) {
          events.add(element);
          print('Has Event');
        }
      });
      return events;
    }

    getScheduled();

    return Scaffold(
        appBar: AppBar(title: Text('Schedules')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8,bottom: 8),
                child: Text('Upcoming Schedules',
                    style: TypographyStyles.title(21)),
              ),
              Container(
                width: Get.width,
                height: Get.width / 2,
                child: Obx(() => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: meetings.length,
                      itemBuilder: (_, index) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          width: Get.width,
                          height: Get.height * 0.23,
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(DateFormat.d().format(DateTime.parse(meetings[index]['start_time'])),
                                              style: TypographyStyles.title(30)),
                                          ElevatedButton(
                                              style: ButtonStyles.bigBlackButton(),
                                              onPressed: (){
                                                //joinMeeting(context, meetings[index]['meeting_id'], meetings[index]['passcode']);
                                              }, child: Text('Join'))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                              DateFormat.EEEE().format(DateTime.parse(meetings[index]['start_time']))
                                                  + ', ' +
                                                  DateFormat.MMMM().format(DateTime.parse(meetings[index]['start_time']))
                                                  + ' ' + DateFormat.y().format(DateTime.parse(meetings[index]['start_time']))
                                              ,
                                              style: TypographyStyles.title(16)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(meetings[index]['title'], style: TypographyStyles.title(14)),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(DateFormat.jm().format(DateTime.parse(meetings[index]['start_time'])), style: TypographyStyles.title(14)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Calender', style: TypographyStyles.title(21)),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() => ready.value
                    ? TableCalendar(
                        onFormatChanged: (val) {},
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        firstDay: DateTime.utc(2021, 1, 1),
                        lastDay: DateTime.utc(2025, 12, 31),
                        focusedDay: DateTime.now(),
                  calendarStyle: CalendarStyle(
                    markerSize: 16,
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                        eventLoader: (day) {
                          return getEventsForDay(day);
                        },

                      )
                    : Center(
                        child: LinearProgressIndicator(),
                      )),
              ),
            ],
          ),
        ));
  }
}

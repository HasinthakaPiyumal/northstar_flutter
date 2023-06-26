import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_zoom_sdk/zoom_options.dart';
// import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetVideoSessions/CreateVideoSession.dart';
import 'package:http/http.dart' as http;
import 'package:north_star/Plugins/HttpClient.dart';

import '../SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class HomeWidgetVideoSessions extends StatelessWidget {
  const HomeWidgetVideoSessions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList meetings = [].obs;
    RxBool ready = false.obs;
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
    //     ZoomOptions zoomOptions = new ZoomOptions(
    //       domain: "zoom.us",
    //       appKey: "lEyBF3jYyimQaNqk8Di4VIVUgw5XVFJPh73H",
    //       appSecret: "KUOaQNqmt034e9q40A9IdiGxJTxjsgVTYhyb", //API SECRET FROM ZOOM
    //     );
    //     var meetingOptions = new ZoomMeetingOptions(
    //         userId: authUser.name,
    //         meetingId: meetingID,
    //         meetingPassword: meetingPassword,
    //         disableDialIn: "true",
    //         disableDrive: "true",
    //         disableInvite: "true",
    //         disableShare: "true",
    //         disableTitlebar: "false",
    //         viewOptions: "true",
    //         noAudio: "false",
    //         noDisconnectAudio: "false"
    //     );

    //     var zoom = ZoomView();
    //     zoom.initZoom(zoomOptions).then((results) {
    //       if(results[0] == 0) {
    //         zoom.onMeetingStatus().listen((status) {
    //           print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
    //           if (_isMeetingEnded(status[0])) {
    //             print("[Meeting Status] :- Ended");
    //             timer.cancel();
    //           }
    //         });
    //         print("listen on event channel");
    //         zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
    //           timer = Timer.periodic(new Duration(seconds: 2), (timer) {
    //             zoom.meetingStatus(meetingOptions.meetingId!)
    //                 .then((status) {
    //               print("[Meeting Status Polling] : " + status[0] + " - " + status[1]);
    //             });
    //           });
    //         });
    //       }
    //     }).catchError((error) {
    //       print("[Error Generated] : " + error);
    //     });


    // }


    void getMeeting() async {
      ready.value = false;
      var request;

      if (authUser.role == 'trainer'){
        request = http.Request(
            'GET',
            Uri.parse(HttpClient.baseURL + '/api/meeting/trainer-client-meeting-trainer/'+authUser.id.toString()));
      } else {
        request = http.Request(
            'GET',
            Uri.parse(HttpClient.baseURL + '/api/meeting/trainer-client-meeting-client/'+authUser.id.toString()));
      }
      request.headers.addAll(client.getHeader());

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = jsonDecode(await response.stream.bytesToString());
        print(res);
        meetings.value = res;
        ready.value = true;
        print(res);
      } else {
        var dt = jsonDecode(await response.stream.bytesToString());
        print(dt);
        ready.value = true;
        print(response.reasonPhrase);
      }
    }

    getMeeting();

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Sessions'),
      ),
      floatingActionButton: authUser.role == 'trainer' ? FloatingActionButton.extended(
        onPressed: () {
          Get.to(()=>CreateVideoSession())?.then((value) => {
            getMeeting()
          });
        },
        label: Text('Create New'),
        icon: Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ):null,
      body:Obx(()=> ready.value ? meetings.length > 0 ? ListView.builder(
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            width: Get.width,
            height: Get.height * 0.23,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().selectedCardBG,
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
                                 // joinMeeting(context, meetings[index]['meeting_id'], meetings[index]['passcode']);
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
      ):
      LoadingAndEmptyWidgets.emptyWidget() : LoadingAndEmptyWidgets.loadingWidget()),

    );
  }
}

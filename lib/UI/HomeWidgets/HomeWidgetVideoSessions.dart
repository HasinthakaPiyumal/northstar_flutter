import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

// import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
//
// import 'package:flutter_zoom_sdk/zoom_options.dart';
// import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetVideoSessions/CreateVideoSession.dart';
import 'package:north_star/UI/SharedWidgets/MeetingScreen.dart';

import '../../components/Buttons.dart';
import '../SharedWidgets/LoadingAndEmptyWidgets.dart';

class HomeWidgetVideoSessions extends StatelessWidget {
  const HomeWidgetVideoSessions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList meetings = [].obs;
    RxBool ready = false.obs;
    late Timer timer;

    void joinMeeting(meeting) {
      print("meeting['meeting_id'] + meeting['passcode']");
      print(meeting['meeting_id'] + meeting['passcode']);
      Get.to(() => MeetingScreen(
            meeting['meeting_id'] + meeting['passcode'],
            isMulti: true,
          ));
    }

    // var zoom = ZoomVideoSdk();
    // InitConfig initConfig = InitConfig(
    //   appGroupId: "group.test.sdk",
    //   domain: "zoom.us",
    //   enableLog: true,
    // );
    // zoom.initSdk(initConfig);

    // void joinMeeting(String id, String code) async {
    //   // Map<String, bool> SDKaudioOptions = {
    //   //   "connect": true,
    //   //   "mute": true
    //   // };
    //   // Map<String, bool> SDKvideoOptions = {
    //   //   "localVideoOn": true,
    //   // };
    //   // JoinSessionConfig joinSession = JoinSessionConfig(
    //   //   sessionName:id,
    //   //   sessionPassword: code,
    //   //   token: "JWT token",
    //   //   userName: "User name",
    //   //   audioOptions: SDKaudioOptions,
    //   //   videoOptions: SDKvideoOptions,
    //   //   sessionIdleTimeoutMins: 1,
    //   // );
    //   // await zoom.joinSession(joinSession);
    // }
    // joinMeeting(BuildContext context, meetingID, meetingPassword) async {
    //   print('join meeting 01 --> $meetingPassword----$meetingID');
    //   bool _isMeetingEnded(String status) {
    //     var result = false;
    //
    //     if (Platform.isAndroid)
    //       result = status == "MEETING_STATUS_DISCONNECTING" ||
    //           status == "MEETING_STATUS_FAILED";
    //     else
    //       result = status == "MEETING_STATUS_IDLE";
    //
    //     return result;
    //   }
    //
    //   ZoomOptions zoomOptions = new ZoomOptions(
    //     domain: "zoom.us",
    //     appKey: "lEyBF3jYyimQaNqk8Di4VIVUgw5XVFJPh73H",
    //     appSecret:
    //         "KUOaQNqmt034e9q40A9IdiGxJTxjsgVTYhyb", //API SECRET FROM ZOOM
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
    //       noDisconnectAudio: "false");
    //
    //   var zoom = ZoomView();
    //   zoom.initZoom(zoomOptions).then((results) {
    //     print('join meeting 02 --> $meetingPassword----$meetingID');
    //     if (results[0] == 0) {
    //       // zoom.onMeetingStatus().listen((status) {
    //       //   print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
    //       //   if (_isMeetingEnded(status[0])) {
    //       //     print("[Meeting Status] :- Ended");
    //       //     // timer.cancel();
    //       //   }
    //       // });
    //       print("listen on event channel");
    //       // zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
    //       //   timer = Timer.periodic(new Duration(seconds: 2), (timer) {
    //       //     zoom.meetingStatus(meetingOptions.meetingId!).then((status) {
    //       //       print("[Meeting Status Polling] : " +
    //       //           status[0] +
    //       //           " - " +
    //       //           status[1]);
    //       //     });
    //       //   });
    //       // });
    //     }
    //   }).catchError((error) {
    //     print("[Error Generated] : " + error);
    //   });
    // }

    // joinMeeting(BuildContext context, meetingID, meetingPassword) async {
    //   bool _isMeetingEnded(String status) {
    //     var result = false;
    //
    //     if (Platform.isAndroid)
    //       result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
    //     else
    //       result = status == "MEETING_STATUS_IDLE";
    //
    //     return result;
    //   }
    //   if(meetingID.isNotEmpty && meetingPassword.isNotEmpty){
    //     ZoomOptions zoomOptions = new ZoomOptions(
    //       domain: "zoom.us",
    //       appKey: "lEyBF3jYyimQaNqk8Di4VIVUgw5XVFJPh73H", //API KEY FROM ZOOM - Sdk API Key
    //       appSecret: "KUOaQNqmt034e9q40A9IdiGxJTxjsgVTYhyb", //API SECRET FROM ZOOM - Sdk API Secret
    //     );
    //     var meetingOptions = new ZoomMeetingOptions(
    //         userId: 'username', //pass username for join meeting only --- Any name eg:- EVILRATT.
    //         meetingId: '', //pass meeting id for join meeting only
    //         meetingPassword: '', //pass meeting password for join meeting only
    //         disableDialIn: "true",
    //         disableDrive: "true",
    //         disableInvite: "true",
    //         disableShare: "true",
    //         disableTitlebar: "false",
    //         viewOptions: "true",
    //         noAudio: "false",
    //         noDisconnectAudio: "false"
    //     );
    //
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
    //       print(error);
    //     });
    //   }else{
    //     if(meetingID.isEmpty){
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text("Enter a valid meeting id to continue."),
    //       ));
    //     }
    //     else if(meetingPassword.isEmpty){
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text("Enter a meeting password to start."),
    //       ));
    //     }
    //   }
    // }

    void getMeeting() async {
      ready.value = false;
      var request;

      if (authUser.role == 'trainer') {
        request = http.Request(
            'GET',
            Uri.parse(HttpClient.baseURL +
                '/api/meeting/trainer-client-meeting-trainer/' +
                authUser.id.toString()));
      } else {
        request = http.Request(
            'GET',
            Uri.parse(HttpClient.baseURL +
                '/api/meeting/trainer-client-meeting-client/' +
                authUser.id.toString()));
      }
      request.headers.addAll(client.getHeader());
print(HttpClient.baseURL);
print('HttpClient.baseURL');

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = jsonDecode(await response.stream.bytesToString());
        meetings.value = res;
        ready.value = true;
      } else {
        var dt = jsonDecode(await response.stream.bytesToString());
        ready.value = true;
      }
    }

    getMeeting();

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Sessions'),
      ),
      floatingActionButton: authUser.role == 'trainer'
          ? Buttons.yellowTextIconButton(
              onPressed: () {
                Get.to(() => CreateVideoSession())
                    ?.then((value) => {getMeeting()});
              },
              icon: Icons.add,
              label: 'create new',
              width: 135)
          : null,
      body: Obx(() => ready.value
          ? meetings.length > 0
              ? ListView.builder(
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    print("DateTime.parse(meetings[index]['start_time'])");
                    print(DateTime.parse(meetings[index]['start_time']));
                    print(DateTime.parse(meetings[index]['start_time']).toLocal());
                    return Container(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      width: Get.width,
                      // height: Get.height * 0.23,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Get.isDarkMode
                            ? AppColors.primary2Color
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            // DateFormat.MMMMEEEEd().format(DateTime.parse(
                                            //     meetings[index]['start_time'])),
                                            meetings[index]['title'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TypographyStyles.title(20)),
                                      ),
                                      ElevatedButton(
                                          style: ButtonStyles.bigBlackButton(),
                                          onPressed: () {
                                            joinMeeting(meetings[index]);
                                            // joinMeeting(
                                            //   context,
                                            //     meetings[index]['meeting_id'],
                                            //     meetings[index]['passcode']);
                                          },
                                          child: Text('Join'))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          DateFormat.EEEE().format(
                                                  DateTime.parse(meetings[index]
                                                      ['start_time']).toLocal()) +
                                              ', ' +
                                              DateFormat.MMMM().format(
                                                  DateTime.parse(meetings[index]
                                                      ['start_time']).toLocal()) +
                                              ' ' +
                                              DateFormat.y().format(
                                                  DateTime.parse(meetings[index]
                                                      ['start_time']).toLocal()),
                                          style: TypographyStyles.text(16)),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(meetings[index]['title'],
                                              style:
                                                  TypographyStyles.title(14)),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                              DateFormat.jm().format(
                                                  DateTime.parse(meetings[index]
                                                      ['start_time']).toLocal()),
                                              style:
                                                  TypographyStyles.title(14)),
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
                )
              : LoadingAndEmptyWidgets.emptyWidget()
          : LoadingAndEmptyWidgets.loadingWidget()),
    );
  }
}

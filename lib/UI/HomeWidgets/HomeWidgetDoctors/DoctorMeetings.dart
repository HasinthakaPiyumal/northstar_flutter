import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
// import 'package:flutter_zoom_sdk/zoom_options.dart';
// import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

import 'CalenderView.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class DoctorMeetings extends StatelessWidget {
  const DoctorMeetings({Key? key}) : super(key: key);

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
      Map res = await httpClient.getMyDocMeetings();

      if (res['code'] == 200) {
        meetings.value = res['data'];
        print(res['data']);
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }



    getScheduled();

    return Scaffold(
        appBar: AppBar(
          title: Text('My Appointments',
            style: TypographyStyles.title(21),
          ),
          actions: [
            IconButton(onPressed: (){
              Get.to(()=>CalenderView(meetings: meetings));
            }, icon: Icon(Icons.calendar_today)),
          ],
        ),
        body: Obx(() => ready.value ? meetings.isNotEmpty ? ListView.builder(
          itemCount: meetings.length,
          itemBuilder: (_, index) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              width: Get.width,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(DateFormat("h:mm a").format(DateTime.parse(meetings[index]['start_time'])), style: TypographyStyles.boldText(22, Themes.mainThemeColor.shade500)),
                          SizedBox(width: 15,),
                          Container(
                            height: 30,
                            width: 2,
                            color: Themes.mainThemeColorAccent.shade100.withOpacity(0.5),
                          ),
                          SizedBox(width: 15,),
                          Text(DateFormat("dd MMM, yyyy").format(DateTime.parse(meetings[index]['start_time'])), style: TypographyStyles.title(20)),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Text("${meetings[index]['title']}",
                        textAlign: TextAlign.left,
                        style: TypographyStyles.normalText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().darkGrey(0.6),),
                      ),
                      SizedBox(height: 10,),
                      RichText(
                        text: TextSpan(
                          text: 'for ',
                          style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().lightBlack(0.7),
                          ),
                          children: <TextSpan>[
                            TextSpan(text: '${meetings[index]['client']['name']}',
                                style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.9) : colors.Colors().lightBlack(0.9))
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: meetings[index]['approved'] ? Colors.green : meetings[index]['has_rejected'] ? Colors.red : colors.Colors().deepYellow(1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                              child: Text(meetings[index]['approved'] ? "Approved" : meetings[index]['has_rejected'] ? "Rejected" : "Waiting for Approval",
                                style: TypographyStyles.boldText(
                                  12,
                                  meetings[index]['approved'] || meetings[index]['has_rejected'] ? Themes.mainThemeColorAccent.shade100 : Colors.black,
                                ),
                              ),
                            ),
                          ),

                          (meetings[index]['approved'] && !meetings[index]['finished']) ? MaterialButton(
                            onPressed: (){

                              int timeDif = DateTime.parse(meetings[index]['start_time']).difference(DateTime.now()).inMinutes;

                              print(timeDif);

                              if(timeDif < 5 && timeDif > -120){
                                //joinMeeting(context, meetings[index]['meeting_id'], meetings[index]['passcode']);
                              }else{
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: colors.Colors().darkGrey(1),
                                    title: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: "Can't join,",
                                        style: TypographyStyles.title(20),
                                        children: <TextSpan>[
                                          TextSpan(text: timeDif > 5 ? ' you are early.' : timeDif < -120 ? " your time period expired" : "",
                                            style: TypographyStyles.title(20),
                                          ),
                                        ],
                                      ),
                                    ),
                                    content: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: "Your meeting",
                                        style: TypographyStyles.normalText(18, Themes.mainThemeColorAccent.shade100),
                                        children: <TextSpan>[
                                          TextSpan(text: timeDif > 5 ? ' is ' : timeDif < -120 ? " was " : "",
                                            style: TypographyStyles.normalText(18, Themes.mainThemeColorAccent.shade100),
                                          ),
                                          TextSpan(text: timeDif > 5 ? 'scheduled for ${DateFormat("dd MMM, yyyy").format(DateTime.parse(meetings[index]['start_time']))} at ${DateFormat("h:mm a").format(DateTime.parse(meetings[index]['start_time']))}. Please join at this time.' : timeDif < -120 ? "scheduled for ${DateFormat("dd MMM, yyyy").format(DateTime.parse(meetings[index]['start_time']))} at ${DateFormat("h:mm a").format(DateTime.parse(meetings[index]['start_time']))}." : "",
                                            style: TypographyStyles.normalText(18, Themes.mainThemeColorAccent.shade100),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.black,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Row(
                                children: [
                                  Icon(Icons.videocam_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5,),
                                  Text("Join",
                                    style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade100),
                                  ),
                                ],
                              ),
                            ),
                          ) : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) : LoadingAndEmptyWidgets.emptyWidget() : LoadingAndEmptyWidgets.loadingWidget()));
  }
}

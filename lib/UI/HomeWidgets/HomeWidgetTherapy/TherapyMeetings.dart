import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

// import 'package:flutter_zoom_sdk/zoom_options.dart';
// import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import './TherapyList.dart';
import 'CalenderView.dart';

class TherapyMeetings extends StatelessWidget {
  const TherapyMeetings({Key? key}) : super(key: key);

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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(
            'My Appointments',
            style: TypographyStyles.title(20),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(() => CalenderView(meetings: meetings));
                },
                icon: Icon(
                  Icons.calendar_today_rounded,
                  size: 24,
                )),
          ],
        ),
        body: Obx(() => ready.value
            ? Column(children: [
          Expanded(
            child: meetings.isNotEmpty
                      ? ListView.builder(
                          itemCount: meetings.length,
                          itemBuilder: (_, index) {
                            return Container(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                              width: Get.width,
                              child: Card(
                                elevation: 0,
                                color: Get.isDarkMode
                                    ? AppColors.primary2Color
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svgs/mi_user.svg",
                                            width: 24,
                                            height: 24,
                                            color: Get.isDarkMode
                                                ? Colors.white
                                                : Color(0xFF1B1F24),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '${meetings[index]['client']['name']}',
                                            style:
                                                TypographyStyles.textWithWeight(
                                                    14, FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svgs/mi_watch.svg",
                                            width: 24,
                                            height: 24,
                                            color: Get.isDarkMode
                                                ? Colors.white
                                                : Color(0xFF1B1F24),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            DateFormat("h:mm a").format(
                                                DateTime.parse(meetings[index]
                                                    ['start_time'])),
                                            style: TextStyle(
                                              color: Color(0xFFFFB700),
                                              fontSize: 20,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Container(
                                            height: 30,
                                            width: 1,
                                            color: Themes
                                                .mainThemeColorAccent.shade100
                                                .withOpacity(0.5),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                              DateFormat("dd MMM, yyyy").format(
                                                  DateTime.parse(meetings[index]
                                                      ['start_time'])),
                                              style: TextStyle(
                                                color: Color(0xFFFFB700),
                                                fontSize: 20,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                              ))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svgs/clipboard.svg",
                                            width: 24,
                                            height: 24,
                                            color: Get.isDarkMode
                                                ? Colors.white
                                                : Color(0xFF1B1F24),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text("${meetings[index]['title']}",
                                              textAlign: TextAlign.left,
                                              style:
                                                  TypographyStyles.textWithWeight(
                                                      16, FontWeight.w300)),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: meetings[index]['approved']
                                                  ? Colors.green
                                                  : meetings[index]
                                                          ['has_rejected']
                                                      ? Colors.red
                                                      : colors.Colors()
                                                          .deepYellow(1),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 15),
                                              child: Text(
                                                meetings[index]['approved']
                                                    ? "Approved"
                                                    : meetings[index]
                                                            ['has_rejected']
                                                        ? "Rejected"
                                                        : "Waiting for Approval",
                                                style: TextStyle(
                                                  color: Color(0xFF1B1F24),
                                                  fontSize: 20,
                                                  fontFamily: 'Bebas Neue',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          (meetings[index]['approved'] &&
                                                  !meetings[index]['finished'])
                                              ? SizedBox(
                                                  width: 10,
                                                )
                                              : SizedBox(
                                                  width: 0,
                                                ),
                                          (meetings[index]['approved'] &&
                                                  !meetings[index]['finished'])
                                              ? MaterialButton(
                                                  onPressed: () {
                                                    int timeDif = DateTime.parse(
                                                            meetings[index]
                                                                ['start_time'])
                                                        .difference(
                                                            DateTime.now())
                                                        .inMinutes;

                                                    print(timeDif);

                                                    if (timeDif < 5 &&
                                                        timeDif > -120) {
                                                      //joinMeeting(context, meetings[index]['meeting_id'], meetings[index]['passcode']);
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(5),
                                                          ),
                                                          backgroundColor: Get
                                                                  .isDarkMode
                                                              ? AppColors
                                                                  .primary2Color
                                                              : AppColors
                                                                  .baseColor,
                                                          title: RichText(
                                                            textAlign:
                                                                TextAlign.center,
                                                            text: TextSpan(
                                                              text: "Can't join,",
                                                              style:
                                                                  TypographyStyles
                                                                      .title(18),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: timeDif >
                                                                          5
                                                                      ? ' you are early.'
                                                                      : timeDif <
                                                                              -120
                                                                          ? " your time period expired"
                                                                          : "",
                                                                  style:
                                                                      TypographyStyles
                                                                          .title(
                                                                              18),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          content: RichText(
                                                            textAlign:
                                                                TextAlign.center,
                                                            text: TextSpan(
                                                              text:
                                                                  "Your meeting",
                                                              style: TypographyStyles
                                                                  .textWithWeight(
                                                                      14,
                                                                      FontWeight
                                                                          .w400),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: timeDif >
                                                                          5
                                                                      ? ' is '
                                                                      : timeDif <
                                                                              -120
                                                                          ? " was "
                                                                          : "",
                                                                  style: TypographyStyles
                                                                      .textWithWeight(
                                                                          14,
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                TextSpan(
                                                                  text: timeDif >
                                                                          5
                                                                      ? 'scheduled for ${DateFormat("dd MMM, yyyy").format(DateTime.parse(meetings[index]['start_time']))} at ${DateFormat("h:mm a").format(DateTime.parse(meetings[index]['start_time']))}. Please join at this time.'
                                                                      : timeDif <
                                                                              -120
                                                                          ? "scheduled for ${DateFormat("dd MMM, yyyy").format(DateTime.parse(meetings[index]['start_time']))} at ${DateFormat("h:mm a").format(DateTime.parse(meetings[index]['start_time']))}."
                                                                          : "",
                                                                  style: TypographyStyles
                                                                      .textWithWeight(
                                                                          14,
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                  ),
                                                  color: Colors.black,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 15),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.videocam_rounded,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Join",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Bebas Neue',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : LoadingAndEmptyWidgets.emptyWidget(),
          )
          ,Container(
            width: Get.width * 0.9,
            height: 44,
            margin: EdgeInsets.only(bottom: 40),
            child: ElevatedButton(
              style: ButtonStyles.bigFlatYellowButton(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_call_outlined),
                  SizedBox(width: 8),
                  Text('make an appointment',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Bebas Neue',
                        fontWeight: FontWeight.w400,
                      ))
                ],
              ),
              onPressed: () {
                Get.to(() => TherapyList());
                // Get.to(() => TherapyMeetings());
              },
            ),
          ),
              ])
            : LoadingAndEmptyWidgets.loadingWidget()));
  }
}

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// import 'package:flutter_zoom_sdk/zoom_options.dart';
// import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetFinance.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetResources.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetToDos.dart';
import 'package:north_star/UI/Members/UserView.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorPageController.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorPaymentsHistories.dart';
import 'package:north_star/UI/PrivateDoctor/ScheduleCalender.dart';
import 'package:north_star/UI/PrivateDoctor/SchedulesHistory.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/UI/Wallet.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../Models/AuthUser.dart';
import '../../components/Buttons.dart';
import '../SharedWidgets/MeetingScreen.dart';

class FrontPage extends StatelessWidget {
  const FrontPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool online = true.obs;
    RxBool ready = false.obs;
    RxList list = [].obs;
    RxInt countSchedule = 0.obs;
    RxInt countPending = 0.obs;
    RxBool joining = false.obs;
    late Timer timer;

    void toggleOnlineStatus() async {
      ready.value = false;
      await httpClient.toggleOnlineStatus();
      ready.value = true;
    }

    void getDocHome() async {
      ready.value = false;
      Map res = await httpClient.getDoctorHome();
      if (res['code'] == 200) {
        print(res);
        online.value = res['data']['doctor']['online'];
        list.value = res['data']['upcoming'];
        countSchedule.value = res['data']['upcoming_count'];
        countPending.value = res['data']['pending_count'];
      }
      ready.value = true;
    }

    void payNow(int seconds, Map meetingData) async {
      ready = false.obs;
      print('pay now');
      Map res = await httpClient.payForDocMeetingNow({
        'doctor_id': meetingData['doctor_id'],
        'client_id': meetingData['client_id'],
        'seconds': seconds
      });

      print(res);
      if (res['code'] == 200) {
        getDocHome();
      } else {
        ready.value = true;
      }
    }

    void finish(id) async {
      print(id);
      ready.value = false;
      Map res = await httpClient.finishDoctorMeeting(id);
      print(res);
      if (res['code'] == 200) {
        Get.back();
        getDocHome();
      } else {
        print(res);
        ready.value = true;
        getDocHome();
        Get.back();
      }
    }

    void askIfFinished( Map meetingData) {
      joining.value = false;
      Get.defaultDialog(
        radius: 8,
        barrierDismissible: false,
        title: 'Finished?',
        content: Text('Are you finished with this session?'),
        actions: [
          TextButton(
            child: Text('Yes'),
            onPressed: () {
              // payNow(seconds, meetingData);
              finish(meetingData['id']);
            },
          ),
          TextButton(
            child: Text('No'),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      );
    }

    joinMeeting(meeting) async {
      Get.to(() => MeetingScreen(meeting['meeting_id'] + meeting['passcode']));
    }
    //
    // joinMeeting(BuildContext context, meetingID, meetingPassword, meetingId, Map meetingData) async {
    //   joining.value = true;
    //   bool _isMeetingEnded(String status) {
    //     var result = false;

    //     if (Platform.isAndroid)
    //       result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
    //     else
    //       result = status == "MEETING_STATUS_IDLE";

    //     return result;
    //   }
    //   ZoomOptions zoomOptions = ZoomConfigs.zoomOptions;
    //   ZoomMeetingOptions meetingOptions = new ZoomMeetingOptions(
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
    //   ZoomView zoom = ZoomView();
    //   zoom.initZoom(zoomOptions).then((results) {
    //     if(results[0] == 0) {
    //       zoom.onMeetingStatus().listen((status) {
    //         print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
    //         if (_isMeetingEnded(status[0])) {
    //           print("[Meeting Status] :- Ended");
    //           timer.cancel();
    //           print(timer.tick);
    //           askIfFinished(timer.tick,meetingData);
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

    getDocHome();

    return Scaffold(
        body: SingleChildScrollView(
      child: Obx(() => ready.value
          ? Column(
              children: [
                SizedBox(height: 24),
                authUser.user['doctor']['approved']
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Your account is not yet approved. Please wait for approval.',
                          style: TypographyStyles.title(16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 20,),
                    Text('Online', style: TypographyStyles.title(24)),
                    Obx(() => CupertinoSwitch(
                        value: online.value,
                        onChanged: (value) {
                          online.value = value;
                          toggleOnlineStatus();
                        })),
                    IconButton(
                      onPressed: () {
                        getDocHome();
                      },
                      icon: Icon(Icons.refresh),
                    )
                  ],
                ),
                SizedBox(height: 24),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                          onPressed: () {
                            DoctorPageController.doctorPageController.value
                                .jumpToPage(1);
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 10),
                                      Text('Schedule',
                                          style: TypographyStyles.title(15).copyWith(color: AppColors.textOnAccentColor)),
                                      SizedBox(height: 4),
                                      Container(width: 58,height: 3,decoration: BoxDecoration(color: AppColors.textOnAccentColor, borderRadius: BorderRadius.circular(5)),),
                                      SizedBox(height: 4),
                                      Text(countSchedule.string,
                                          style: TypographyStyles.title(20).copyWith(color: AppColors.textOnAccentColor)),
                                      SizedBox(height: 6),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 10),
                                      Text('Pending',
                                          style: TypographyStyles.title(15).copyWith(color: AppColors.textOnAccentColor)),
                                      SizedBox(height: 4),
                                      Container(width: 58,height: 3,decoration: BoxDecoration(color: AppColors.textOnAccentColor, borderRadius: BorderRadius.circular(5)),),
                                      SizedBox(height: 4),
                                      Text(countPending.string,
                                          style: TypographyStyles.title(20).copyWith(color: AppColors.textOnAccentColor)),
                                      SizedBox(height: 6),
                                    ],
                                  ),
                                ]),
                          )),
                    )),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Appointments',
                          style: TypographyStyles.title(18)),
                      IconButton(
                          onPressed: () {
                            DoctorPageController.doctorPageController.value
                                .jumpToPage(2);
                          },
                          icon: SvgPicture.asset(
                            "assets/svgs/next.svg",
                            width: 24,
                            height: 24,
                            color: Get.isDarkMode?Colors.white:AppColors.textOnAccentColor,
                          ),)
                    ],
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                //   width: Get.width,
                //   height: 260,
                //   child: Obx(() => list.length > 0
                //       ? PageView.builder(
                //           itemCount: list.length,
                //           controller: PageController(
                //             viewportFraction: 0.8,
                //           ),
                //           pageSnapping: true,
                //           padEnds: false,
                //           itemBuilder: (_, index) {
                //             return Padding(
                //               padding: EdgeInsets.only(
                //                   right: index == list.length - 1 ? 20 : 10),
                //               child: Container(
                //                 margin: index == 0
                //                     ? EdgeInsets.only(left: 6)
                //                     : EdgeInsets.zero,
                //                 decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.circular(15),
                //                   color: Get.isDarkMode
                //                       ? colors.Colors().deepGrey(1)
                //                       : colors.Colors().lightCardBG,
                //                 ),
                //                 child: Padding(
                //                   padding:
                //                       const EdgeInsets.fromLTRB(20, 10, 20, 10),
                //                   child: Column(
                //                     mainAxisAlignment: MainAxisAlignment.center,
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: [
                //                       InkWell(
                //                         child: Row(
                //                           mainAxisAlignment:
                //                               MainAxisAlignment.spaceBetween,
                //                           children: [
                //                             Row(
                //                               children: [
                //                                 CircleAvatar(
                //                                   radius: 26,
                //                                   backgroundImage:
                //                                       CachedNetworkImageProvider(
                //                                           'https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/avatars/' +
                //                                               list[index]
                //                                                       ['client']
                //                                                   [
                //                                                   'avatar_url']),
                //                                 ),
                //                                 SizedBox(width: 20),
                //                                 Column(
                //                                   crossAxisAlignment:
                //                                       CrossAxisAlignment.start,
                //                                   children: [
                //                                     Text(
                //                                         list[index]['client']
                //                                                 ['name']
                //                                             .toString()
                //                                             .split(" ")
                //                                             .first,
                //                                         style: TypographyStyles
                //                                             .title(20)),
                //                                     SizedBox(height: 5),
                //                                     Text(
                //                                         list[index]['client']
                //                                             ['email'],
                //                                         style: TypographyStyles
                //                                             .text(14)),
                //                                   ],
                //                                 ),
                //                               ],
                //                             ),
                //                             Image.asset(
                //                               "assets/icons/externallink.png",
                //                               color: Get.isDarkMode
                //                                   ? Themes.mainThemeColorAccent
                //                                       .shade100
                //                                       .withOpacity(0.5)
                //                                   : colors.Colors()
                //                                       .lightBlack(1),
                //                               height: 20,
                //                             ),
                //                           ],
                //                         ),
                //                         onTap: () {
                //                           Get.to(() => UserView(
                //                               userID: list[index]['client']
                //                                   ['id']));
                //                         },
                //                       ),
                //                       SizedBox(height: 2),
                //                       Divider(),
                //                       SizedBox(height: 4),
                //                       Row(
                //                         children: [
                //                           Column(
                //                             crossAxisAlignment:
                //                                 CrossAxisAlignment.start,
                //                             children: [
                //                               Text('Date',
                //                                   style:
                //                                       TypographyStyles.boldText(
                //                                     12,
                //                                     Get.isDarkMode
                //                                         ? Themes
                //                                             .mainThemeColorAccent
                //                                             .shade100
                //                                             .withOpacity(0.7)
                //                                         : colors.Colors()
                //                                             .lightBlack(0.6),
                //                                   )),
                //                               SizedBox(height: 5),
                //                               Text(
                //                                 "${DateFormat("MMM dd,yyyy").format(DateTime.parse(list[index]['start_time']))}",
                //                                 style:
                //                                     TypographyStyles.title(16),
                //                               ),
                //                             ],
                //                           ),
                //                           SizedBox(width: 25),
                //                           Column(
                //                             crossAxisAlignment:
                //                                 CrossAxisAlignment.start,
                //                             children: [
                //                               Text('Time',
                //                                   style:
                //                                       TypographyStyles.boldText(
                //                                     12,
                //                                     Get.isDarkMode
                //                                         ? Themes
                //                                             .mainThemeColorAccent
                //                                             .shade100
                //                                             .withOpacity(0.7)
                //                                         : colors.Colors()
                //                                             .lightBlack(0.6),
                //                                   )),
                //                               SizedBox(height: 5),
                //                               Text(
                //                                 "${DateFormat("hh:mm a").format(DateTime.parse(list[index]['start_time']))}",
                //                                 style:
                //                                     TypographyStyles.title(16),
                //                               ),
                //                             ],
                //                           )
                //                         ],
                //                       ),
                //                       SizedBox(height: 5),
                //                       Divider(),
                //                       SizedBox(height: 5),
                //                       Row(
                //                         mainAxisAlignment:
                //                             MainAxisAlignment.end,
                //                         children: [
                //                           Expanded(child: Buttons.outlineButton(onPressed: (){askIfFinished( list[index]);}, label: "Finish")),
                //                           SizedBox(width: 10,),
                //                           Expanded(child: Buttons.yellowFlatButton(onPressed: (){joinMeeting(list[index]);},label:"Join")),
                //                         ],
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             );
                //           },
                //         )
                //       : Center(
                //           child: Center(
                //             child: Text("Nothing Here yet"),
                //           ),
                //         )),
                // ),
                SizedBox(height: 16),
                Container(
                  width: Get.width,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                      style: Get.isDarkMode
                          ? ButtonStyles.secondaryButton()
                          : ButtonStyles.matRadButton(
                              colors.Colors().selectedCardBG, 0, 12),
                      onPressed: () {
                        Get.to(() => HomeWidgetToDos());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Todo and Notes'),
                            Icon(Icons.chevron_right)
                          ],
                        ),
                      )),
                ),
                SizedBox(height: 8),
                Container(
                  width: Get.width,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                      style: Get.isDarkMode
                          ? ButtonStyles.secondaryButton()
                          : ButtonStyles.matRadButton(
                              colors.Colors().selectedCardBG, 0, 12),
                      onPressed: () {
                        Get.to(() => SchedulesHistory());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Prescription Manager'),
                            Icon(Icons.chevron_right)
                          ],
                        ),
                      )),
                ),
                SizedBox(height: 8),
                Container(
                  width: Get.width,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                      style: Get.isDarkMode
                          ? ButtonStyles.secondaryButton()
                          : ButtonStyles.matRadButton(
                              colors.Colors().selectedCardBG, 0, 12),
                      onPressed: () {
                        Get.to(() => ScheduleCalender(list: list));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Schedule Calender'),
                            Icon(Icons.chevron_right)
                          ],
                        ),
                      )),
                ),
                SizedBox(height: 8),
                Container(
                  width: Get.width,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                      style: Get.isDarkMode
                          ? ButtonStyles.secondaryButton()
                          : ButtonStyles.matRadButton(
                              colors.Colors().selectedCardBG, 0, 12),
                      onPressed: () {
                        Get.to(() => HomeWidgetResources());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Library Resources'),
                            Icon(Icons.chevron_right)
                          ],
                        ),
                      )),
                ),
                SizedBox(height: 8),
                Container(
                  width: Get.width,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                      style: Get.isDarkMode
                          ? ButtonStyles.secondaryButton()
                          : ButtonStyles.matRadButton(
                              colors.Colors().selectedCardBG, 0, 12),
                      onPressed: () {
                        Get.to(() => DoctorPaymentHistories());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payments'),
                            Icon(Icons.chevron_right)
                          ],
                        ),
                      )),
                ),
                SizedBox(height: 8),
                // Container(
                //   width: Get.width,
                //   height: 75,
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: ElevatedButton(
                //       style: Get.isDarkMode
                //           ? ButtonStyles.secondaryButton()
                //           : ButtonStyles.matRadButton(
                //               colors.Colors().selectedCardBG, 0, 12),
                //       onPressed: () {
                //         Get.to(() => HomeWidgetFinance());
                //       },
                //       child: Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 12),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text('Finance'.toUpperCase()),
                //             Icon(Icons.chevron_right)
                //           ],
                //         ),
                //       )),
                // ),
                // SizedBox(height: 8),
                // Container(
                //   width: Get.width,
                //   height: 75,
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: ElevatedButton(
                //       style: Get.isDarkMode
                //           ? ButtonStyles.secondaryButton()
                //           : ButtonStyles.matRadButton(
                //               colors.Colors().selectedCardBG, 0, 12),
                //       onPressed: () {
                //         Get.to(() => Wallet());
                //       },
                //       child: Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 12),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text('E Wallet'.toUpperCase()),
                //             Icon(Icons.chevron_right)
                //           ],
                //         ),
                //       )),
                // ),
                // SizedBox(height: 8),
              ],
            )
          : Center(
              child: LoadingAndEmptyWidgets.loadingWidget(),
            )),
    ));
  }
}

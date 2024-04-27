import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/ZoomConfigs.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Members/UserView.dart';
import 'package:north_star/UI/PrivateDoctor/SchedulesHistory.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
//import 'package:flutter_zoom_sdk/zoom_options.dart';
//import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../components/Buttons.dart';
import '../SharedWidgets/MeetingScreen.dart';

class Upcoming extends StatelessWidget {
  const Upcoming({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxBool joining = false.obs;
    RxList list = [].obs;
    late Timer timer;

    void getUpcoming() async{
      ready.value = false;
      Map res = await httpClient.getDoctorUpcoming();
      print(res);
      if (res['code'] == 200) {
        list.value = res['data']['meetings'];
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void payNow(int seconds, Map meetingData) async{
      ready = false.obs;
      print('pay now');
      Map res = await httpClient.payForDocMeetingNow({
        'doctor_id': meetingData['doctor_id'],
        'client_id': meetingData['client_id'],
        'seconds': seconds
      });

      print(res);
      if(res['code'] == 200){
         getUpcoming();
      }  else {
        ready.value = true;
      }
    }

    void finish(id) async{
      print(id);
      ready.value = false;
      Map res = await httpClient.finishDoctorMeeting(id);
      print(res);
      if (res['code'] == 200) {
        Get.back();
        getUpcoming();
      }
      else {
        print(res);
        ready.value = true;
        getUpcoming();
        Get.back();
      }
    }

    void askIfFinished( Map meetingData){
      joining.value = false;
      Get.defaultDialog(
        radius: 8,
        barrierDismissible: false,
        title: 'Finished?',
        content: Text('Are you finished with this session?'),
        actions: [
          TextButton(
            child: Text('Yes'),
            onPressed: (){
              // payNow(seconds, meetingData);
              finish(meetingData['id']);
            },
          ),
          TextButton(
            child: Text('No'),
            onPressed: (){
              Get.back();
            },
          ),
        ],
      );
    }

    // joinMeeting(BuildContext context, meetingID, meetingPassword, meetingId, Map meetingData) async {
    //   joining.value = true;
    //   httpClient.sendNotification(meetingData['client_id'], 'Doctor has joined the Meeting!', 'Your Doctor has joined the Meeting!');
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
    joinMeeting(meeting) async {
      Get.to(() => MeetingScreen(meeting['meeting_id'] + meeting['passcode']));
    }
    getUpcoming();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(()=> ready.value ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Get.width,
              height: 80,
              child: ElevatedButton(
                  style: Get.isDarkMode ? ButtonStyles.primaryButton() : ButtonStyles.matRadButton(colors.Colors().selectedCardBG, 0, 12),
                  onPressed: (){
                    Get.to(()=> SchedulesHistory());
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history,
                              color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                            ),
                            SizedBox(width: 10,),
                            Text('HISTORY'.toUpperCase(),
                              style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right)
                      ],
                    ),
                  )
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Schedules', style: TypographyStyles.title(18)),
            ),
            SizedBox(height: 8,),
            Expanded(child: list.isNotEmpty ? ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color:Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundImage: CachedNetworkImageProvider(
                                          'https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/avatars/' + list[index]['client']['avatar_url']
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(list[index]['client']['name'].toString().split(" ").first,style: TypographyStyles.title(20)),
                                        SizedBox(height: 5),
                                        Text(list[index]['client']['email'],style: TypographyStyles.text(14)),
                                      ],
                                    ),
                                  ],
                                ),
                                Image.asset("assets/icons/externallink.png",
                                  color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1),
                                  height: 20,
                                ),
                              ],
                            ),
                            onTap: (){
                              Get.to(()=> UserView(userID: list[index]['client']['id']));
                            },
                          ),
                          SizedBox(height: 2),
                          Divider(),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date', style: TypographyStyles.boldText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().lightBlack(0.6),)),
                                  SizedBox(height: 5),
                                  Text("${DateFormat("MMM dd,yyyy").format(DateTime.parse(list[index]['start_time']))}",
                                    style: TypographyStyles.title(16),
                                  ),
                                ],
                              ),
                              SizedBox(width: 25),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Time', style: TypographyStyles.boldText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().lightBlack(0.6),)),
                                  SizedBox(height: 5),
                                  Text("${DateFormat("hh:mm a").format(DateTime.parse(list[index]['start_time']))}",
                                    style: TypographyStyles.title(16),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(list[index]['title'], style: TypographyStyles.title(16)),
                          SizedBox(height: 10),
                          Text(list[index]['description'], style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().lightBlack(0.6),)),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Buttons.outlineButton(onPressed: (){askIfFinished( list[index]);},width: 120, label: "Finish"),
                              SizedBox(width: 10,),
                              Buttons.yellowFlatButton(onPressed: (){joinMeeting(list[index]);},width: 120,label:"Join"),
                              // ElevatedButton(
                              //   child: Padding(
                              //     padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                              //     child: Row(
                              //       children: [
                              //         Icon(Icons.videocam_rounded,
                              //           color: Colors.black,
                              //         ),
                              //         SizedBox(width: 5,),
                              //         Text('JOIN',
                              //           style: TypographyStyles.boldText(15, Colors.black),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              //   style: ButtonStyles.matRadButton(Themes.mainThemeColor.shade500, 5, 12),
                              //   onPressed: (){
                              //     joinMeeting(list[index]);
                              //     //joinMeeting(context, list[index]['meeting_id'], list[index]['passcode'], list[index]['id'], list[index]);
                              //   },
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ) : LoadingAndEmptyWidgets.emptyWidget()),
          ],
        ): LinearProgressIndicator()),
      ),
    );
  }
}

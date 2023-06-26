// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_zoom_sdk/zoom_options.dart';
// import 'package:flutter_zoom_sdk/zoom_view.dart';
// import 'package:north_star/Models/AuthUser.dart';

// class ZoomMeeting {
//   Future<bool> joinMeeting(BuildContext context, meetingID, meetingPassword) async {
//     late Timer timer;

//     bool _isMeetingEnded(String status) {
//       var result = false;
//       if (Platform.isAndroid)
//         result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
//       else
//         result = status == "MEETING_STATUS_IDLE";
//       return result;
//     }

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
//     await zoom.initZoom(zoomOptions).then((results) {
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
//     return true;
//   }
// }

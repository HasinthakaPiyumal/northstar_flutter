// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/entities/notification_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:north_star/Models/HttpClient.dart';

Future<void> showCallkitIncoming(
  String uuid, {
  String nameCaller = "",
  String avatar = "default.jpg",
}) async {
  // final params = CallKitParams(
  //   id: uuid,
  //   nameCaller: nameCaller,
  //   appName: 'North Star',
  //   avatar: HttpClient.s3BaseUrl + avatar,
  //   type: 0,
  //   duration: 30000,
  //   textAccept: 'Accept',
  //   textDecline: 'Decline',
  //   missedCallNotification: const NotificationParams(
  //     showNotification: true,
  //     isShowCallback: false,
  //     subtitle: 'Missed call',
  //   ),
  //   extra: <String, dynamic>{'userId': '1a2b3c4d'},
  //   headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
  //   android: const AndroidParams(
  //     isCustomNotification: true,
  //     isShowLogo: false,
  //     ringtonePath: 'system_ringtone_default',
  //     backgroundColor: "#1E2630",
  //     backgroundUrl: 'assets/images/backgrounds/call.png',
  //     actionColor: '#4CAF50',
  //   ),
  //   ios: const IOSParams(
  //     iconName: 'CallKitLogo',
  //     handleType: '',
  //     supportsVideo: true,
  //     maximumCallGroups: 2,
  //     maximumCallsPerCallGroup: 1,
  //     audioSessionMode: 'default',
  //     audioSessionActive: true,
  //     audioSessionPreferredSampleRate: 44100.0,
  //     audioSessionPreferredIOBufferDuration: 0.005,
  //     supportsDTMF: true,
  //     supportsHolding: true,
  //     supportsGrouping: false,
  //     supportsUngrouping: false,
  //     ringtonePath: 'system_ringtone_default',
  //   ),
  // );
  // await FlutterCallkitIncoming.showCallkitIncoming(params);
}

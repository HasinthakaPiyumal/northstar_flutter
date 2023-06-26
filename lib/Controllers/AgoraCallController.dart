import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:uuid/uuid.dart';

class AgoraCallController {
  static RxBool ready = false.obs;

  static late RtcEngine agoraEngine;
  static bool isJoined = false;
  static RxBool accepted = false.obs;
  static int remoteUID = 0;

  static Map user = {};

  static Rx<Duration> duration = Duration(seconds: 0).obs;
  static late DateTime startTime;
  static late DateTime endTime;
  static String channelName = 'defaultChannel';
  static late Timer timer;

  static const String token = '983f2eee1a9a4d2f90c04e17b9694fea';
  static const String appId = '0e76a00a008e418bb9074ccad44724de';

  static RxString callStatus = 'Calling...'.obs; // Calling, Connected, Disconnected
  static String callConnectionStatus = 'Not Connected'; // Not Connected, Connected

  static RxBool speakerPhone = false.obs;
  static RxBool mute = false.obs;

  static Future<bool> init(Map<String,dynamic> userData) async {
    user = userData;

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: appId,
    ));

    await agoraEngine.disableVideo();

    channelName = Uuid().v4();

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user uid:${connection.localUid} joined the channel");
          isJoined = true;
          callStatus.value = 'Calling...';
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user uid joined the channel");
          callStatus.value = 'Connected';
          callConnectionStatus = 'Connected';
          remoteUID = remoteUid;
          startTime = DateTime.now();
          timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
            duration.value = DateTime.now().difference(startTime);
          });
        },

        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("Remote user uid left the channel");
          callStatus.value = 'Disconnected';
          remoteUID = 0;
          endTime = DateTime.now();
        },

      ),
    );

      await httpClient.invokeCall({
        'from': authUser.id,
        'to': user['id'],
        'channel': channelName,
      });

      print(channelName);

    await joinCall();
    ready.value = true;
    accepted.value = true;
    return true;
  }

  static Future<bool> initIncoming(Map<String,dynamic> data) async {
    user = data['from'];
    channelName = data['channel'];
    print(channelName);
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
      appId: appId,
    ));

    await agoraEngine.disableVideo();



    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user uid joined the channel");
          isJoined = true;
          callStatus.value = 'Calling...';
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user uid:$remoteUid joined the channel");
          callStatus.value = 'Connected';
          callConnectionStatus = 'Connected';
          remoteUID = remoteUid;
          startTime = DateTime.now();
          timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
            duration.value = DateTime.now().difference(startTime);
          });
        },

        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("Remote user uid left the channel");
          callStatus.value = 'Disconnected';
          remoteUID = 0;
          endTime = DateTime.now();
        },

      ),
    );

    ready.value = true;

    return true;
  }

  static Future<bool> joinCall() async {
    accepted.value = true;
    isJoined = true;
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: authUser.id,
    );

    return true;
  }

  static rejectCall() async {
    try {
      timer.cancel();
    } catch(e) {
      print(e);
    }
    accepted.value = false;
    Get.back();
  }

  static void switchSpeaker() async {
    if(speakerPhone.value) {
      await agoraEngine.setEnableSpeakerphone(false);
      speakerPhone.value = false;
      return;
    } else {
      await agoraEngine.setEnableSpeakerphone(true);
      speakerPhone.value = true;
      return;
    }
  }

  static void switchMute() async {
    if(mute.value) {
      await agoraEngine.muteLocalAudioStream(false);
      mute.value = false;
      return;
    } else {
      await agoraEngine.muteLocalAudioStream(true);
      mute.value = true;
      return;
    }
  }

  static void leaveCall() async {
    await agoraEngine.leaveChannel();
    try {
      timer.cancel();
    } catch(e) {
      print(e);
    }
    accepted.value = false;
    isJoined = false;
    Get.back();
  }
}

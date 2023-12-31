import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/CallData.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:uuid/uuid.dart';

import 'CallConrtoller.dart';

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
  static late Timer timer;

  // static const String token = '983f2eee1a9a4d2f90c04e17b9694fea';
  // static var String token =
  //     '007eJxTYNhouCButkT3v5+rX32akKBl+jV3hdWhGXNzPz53f6YboVqlwJCaYm6ZnJhoaGhilGiSaG5oYWJmaG6ekpRmbmyeamSZKnv/X0pDICNDvI8cAyMUgvh8DCmpaYmlOSXOGYl5eak5DAwAbiUlPw==';
  // static const String appId = '0e76a00a008e418bb9074ccad44724de';
  // static const String appId = '717e3dfc72374428b1daa46b39e9145b'; // backend appId
  static const String appId =
      'ed79caa1142a4a71846177dbf737e29e'; // temporary appId
  static RxString callStatus =
      'Calling...'.obs; // Calling, Connected, Disconnected
  static String callConnectionStatus =
      'Not Connected'; // Not Connected, Connected

  static RxBool speakerPhone = false.obs;
  static RxBool mute = false.obs;

  static Future<String> getToken(channelName) async {
    var data = {
      "channelName": channelName,
      "uid": authUser.id,
      "expirationTimeInSeconds": 3600
    };
    dynamic res = await httpClient.getRtcToken(data);
    res['data'] = json.decode(res['data']);
    print('rtc token ---> ${res['data']}');
    return res['data']['token'];
  }

  static Future<bool> init(Map<String, dynamic> userData) async {
    user = userData;

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: appId, logConfig: LogConfig(level: LogLevel.logLevelApiCall)));

    await agoraEngine.disableVideo();

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
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("Remote user uid left the channel");
          callStatus.value = 'Disconnected';
          remoteUID = 0;
          endTime = DateTime.now();
          timer.cancel();
          duration.value = Duration(seconds: 0);
          // Get.back(closeOverlays: true, canPop: false);
          agoraEngine.leaveChannel();
        },
      ),
    );

    await agoraEngine.enableAudio();
    await agoraEngine.enableLocalAudio(true);
    var channelName = Uuid().v4();
    print(user);
    callData.setCallData(id:'${user['id']}',callerName: user['name'], avatar: user['avatar_url'],channelName: channelName);
    invokeCall(user['id'], channelName);

    await joinCall(channelName);
    ready.value = true;
    accepted.value = true;
    return true;
  }

  static Future<bool> initIncoming(Map<String, dynamic> data) async {
    user = data['from'];
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
      appId: appId,
    ));
    callStatus.value = 'Incoming...';

    await agoraEngine.disableVideo();
    await agoraEngine.enableAudio();
    await agoraEngine.enableLocalAudio(true);
    print("Incoming call...");

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user uid joined the channel");
          isJoined = true;
          callStatus.value = 'Calling...';
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user uid:$remoteUid joined the channel");
          startTime = DateTime.now();
          callStatus.value = 'Connected';
          callConnectionStatus = 'Connected';
          remoteUID = remoteUid;
          timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
            duration.value = DateTime.now().difference(startTime);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("Remote user uid left the channel");
          agoraEngine.leaveChannel();
          callStatus.value = 'Disconnected';
          remoteUID = 0;
          endTime = DateTime.now();
          timer.cancel();
          duration.value = Duration(seconds: 0);
          // Get.back(closeOverlays: true, canPop: false);
        },
      ),
    );

    ready.value = true;

    return true;
  }

  static Future<bool> joinCall(channelName) async {
    accepted.value = true;
    isJoined = true;
    print("Joining call...");
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    var crcToken = await getToken(channelName);
    print("Joining channel---> $channelName");
    try {
      await agoraEngine.joinChannel(
        token: crcToken,
        channelId: channelName,
        options: options,
        uid: authUser.id,
      );
      print("Joined call...");
    } catch (e) {
      print("Error joining channel: $e");
      return false;
    }

    return true;
  }

  static rejectCall() async {
    print('rejecting call by agora');
    try {
      timer.cancel();
    } catch (e) {
      print(e);
    }
    accepted.value = false;
    await agoraEngine.leaveChannel();
    Get.back();
  }

  static void switchSpeaker() async {
    print('speaker change');
    if (speakerPhone.value) {
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
    if (mute.value) {
      await agoraEngine.muteLocalAudioStream(false);
      mute.value = false;
      return;
    } else {
      await agoraEngine.muteLocalAudioStream(true);
      mute.value = true;
      return;
    }
  }

  // static void leaveCall() async {
  //   await agoraEngine.leaveChannel();
  //   try {
  //     timer.cancel();
  //   } catch (e) {
  //     print(e);
  //   }
  //   accepted.value = false;
  //   isJoined = false;
  //   Get.back();
  // }
  static void leaveCall() async {
    await agoraEngine.leaveChannel();
    accepted.value = false;
    isJoined = false;
    callStatus.value = 'End call';
    callConnectionStatus = 'Not Connected';
    try {
      timer.cancel();
      duration.value = Duration(seconds: 0);
    } catch (e) {
      print(e);
    }
    print("calling end");
    Get.back(closeOverlays: true, canPop: false);
  }
}

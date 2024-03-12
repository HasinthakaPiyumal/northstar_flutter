import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/AgoraCallController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Models/CallData.dart';
import '../Models/Enums.dart';
import '../Models/HttpClient.dart';
import '../UI/Members/CallView.dart';
import 'CallKitController.dart';
import 'FirebaseMessageController.dart';

void processCall(dynamic data,String uuid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
  if (token.isNotEmpty) {
    print("Calling------<,,");
    if(data["method"]==CallEvents.StartCall.index.toString()){
      print("Incoming call ==");
      print(data);
      callData.setCallData(id:data["caller"],callerName: data["caller_name"], avatar: data["caller_avatar"],channelName: data["channel_name"]);
      showCallkitIncoming(uuid,
          nameCaller: data["caller_name"], avatar: data["caller_avatar"],channel: data["channel_name"],id:int.parse(data["caller"]) );
    }else if(data["method"]==CallEvents.RejectCall.index.toString()){
      print('===Call reject');
      print(callData.id==int.parse(data["caller"]));
      if(callData.id==int.parse(data["caller"])){
        AgoraCallController.rejectCall();
        await FlutterCallkitIncoming.endAllCalls();
      }
    }else if(data["method"]==CallEvents.DisconnectCall.index.toString()){
      if(callData.id==int.parse(data["caller"])){
        AgoraCallController.leaveCall();
        FlutterCallkitIncoming.endAllCalls();
      }
    }
  }
}

void invokeCall(int userId, String channelName) async {
  // if(callData.channelName != "defaultChannel" && callData.id!=0){
  //   callMessage(callData.id, callData.channelName, CallEvents.DisconnectCall);
  // }
  callMessage(userId, channelName, CallEvents.StartCall);
}
void rejectCall(int userId, String channelName) async {
  callMessage(userId, channelName, CallEvents.RejectCall);
}
void endCall(int userId, String channelName) async {
  callMessage(userId, channelName, CallEvents.DisconnectCall);
}

void callMessage(int userId, String channelName,CallEvents callEvent) async {
  String deviceToken = await getTokenByUser(userId);
  Map res = await httpClient.getMyProfile();
  dynamic avatar = res["data"]["avatar_url"] ?? "default.jpg";
  dynamic data = {
    "channel": MessageChannel.Call.index.toString(),
    "method": callEvent.index.toString(),
    "caller": authUser.id.toString(),
    "caller_name": authUser.name,
    "caller_avatar": avatar,
    "callee": userId.toString(),
    "currentTime": DateTime.now().toUtc().toString(),
    "channel_name": channelName,
  };
  if (deviceToken == "") {
    return;
  }
  sendFCMMessage(deviceToken, data);
}

void cancelCall() {
  // sendFCMMessage();
}

Future<String> getTokenByUser(int id) async {
  dynamic currentToken = await FirebaseFirestore.instance
      .collection("UserTokens")
      .doc(id.toString())
      .get();
  print("token $currentToken");
  if (currentToken.exists) {
    currentToken = currentToken.data()['token'];
  } else {
    currentToken = "";
  }
  return currentToken;
}

void setupNotificationAction() async{
  print("calling callkit listner");
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    print("callkit action print==========");
    print(event!.event);
    switch (event!.event) {
      case Event.actionDidUpdateDevicePushTokenVoip:
      // TODO: Handle this case.
        break;
      case Event.actionCallIncoming:
      // TODO: Handle this case.
        break;
      case Event.actionCallStart:
      // TODO: Handle this case.
        break;
      case Event.actionCallDecline:
        print('callData.id,callData.channelName');
        print('${callData}');
        rejectCall(event.body['extra']['id'],event.body['extra']['channel']);
        break;
      case Event.actionCallEnded:
      // TODO: Handle this case.
        break;
      case Event.actionCallTimeout:
      // TODO: Handle this case.
        break;
      case Event.actionCallCallback:
      // TODO: Handle this case.
        break;
      case Event.actionCallToggleHold:
      // TODO: Handle this case.
        break;
      case Event.actionCallToggleMute:
      // TODO: Handle this case.
        break;
      case Event.actionCallToggleDmtf:
      // TODO: Handle this case.
        break;
      case Event.actionCallToggleGroup:
      // TODO: Handle this case.
        break;
      case Event.actionCallToggleAudioSession:
      // TODO: Handle this case.
        break;
      case Event.actionCallCustom:
      // TODO: Handle this case.
        break;
      case Event.actionCallAccept:
      // TODO: Handle this case.
        print("answer clicked 00");
        await FlutterCallkitIncoming.endAllCalls();
        Get.to(()=>CallView(callData: {"channel":event.body['extra']['channel'],"from":{"avatar_url":event.body['extra']['avatar'],"name":event.body['extra']['name']}},));
        break;
    }
  });
}
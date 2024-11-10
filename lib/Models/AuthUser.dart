import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/ZegoCloudController.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../Controllers/ProWidgetController.dart';

class AuthUser {
  late int id;
  late String name;
  late String email;
  late String role;
  late String token;
  late Map user;

  void _setUser(Map<String, dynamic> userObj) {
    print('====userObj');
    print(userObj);
    id = userObj['id'];
    name = userObj['name'];
    email = userObj['email'];
    role = userObj['role'];
    user = userObj;
    var config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoCloudController.appID /*input your AppID*/,
      appSign: ZegoCloudController.appSign /*input your AppSign*/,
      userID: '${userObj['id']}',
      userName: userObj['name'],
      plugins: [ZegoUIKitSignalingPlugin()],
      requireConfig: (ZegoCallInvitationData data) {
        var config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
        config.onOnlySelfInRoom = (s)async{
          print('removed from room');
          if(ZegoCloudController.isOutgoing){
            int duration = DateTime.now().difference(ZegoCloudController.timeStamp).inSeconds;
            print({'receiver_id': ZegoCloudController.calleeId, 'duration': duration, 'status': "Outgoing"});
            httpClient.saveCallLog({'receiver_id': ZegoCloudController.calleeId, 'duration': duration, 'status': "Outgoing"});
          }
          Get.back();
        };
        config.onHangUp = (){
          print('Hanguping');
          if(ZegoCloudController.isOutgoing){
            int duration = DateTime.now().difference(ZegoCloudController.timeStamp).inSeconds;
            print({'receiver_id': ZegoCloudController.calleeId, 'duration': duration, 'status': "Outgoing"});
            httpClient.saveCallLog({'receiver_id': ZegoCloudController.calleeId, 'duration': duration, 'status': "Outgoing"});
          }
          Get.back();
        };
        // config.avatarBuilder = (BuildContext context, Size size,
        //     ZegoUIKitUser? user, Map extraInfo) {
        //   return user != null
        //       ? Container(
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       image: DecorationImage(
        //         image: NetworkImage(
        //           'https://your_server/app/avatar/${user.id}.png',
        //         ),
        //       ),
        //     ),
        //   )
        //       : const SizedBox();
        // };
        return config;
      },
      events: ZegoUIKitPrebuiltCallInvitationEvents(
        onIncomingCallAcceptButtonPressed: (){
          ZegoCloudController.isOutgoing = false;
        },
        onOutgoingCallAccepted: (callId,ZegoCallUser user)async{
          print("======================");
          print("onOutgoingCallAccepted");
          ZegoCloudController.isOutgoing = true;
          ZegoCloudController.timeStamp = DateTime.now();
          ZegoCloudController.calleeId = int.parse(user.id);
          // Map res = await httpClient.saveCallLog(
          //     {'receiver_id': user.id, 'duration': 0, 'status': "Outgoing"});
        },
        onOutgoingCallCancelButtonPressed: ()async{
          print("======================");
          print("onOutgoingCallCancelButtonPressed");
          // Map res = await httpClient.saveCallLog(
          //     {'receiver_id': user.id, 'duration': 0, 'status': "Outgoing"});
        },
        onOutgoingCallRejectedCauseBusy: (callId,ZegoCallUser user)async{
          print("======================");
          print("onOutgoingCallRejectedCauseBusy");
          // Map res = await httpClient.saveCallLog(
          //     {'receiver_id': user.id, 'duration': 0, 'status': "Outgoing"});
        },
        onOutgoingCallDeclined: (callId,ZegoCallUser user)async{
          print("======================");
          print("onOutgoingCallDeclined");
          // Map res = await httpClient.saveCallLog(
          //     {'receiver_id': user.id, 'duration': 0, 'status': "Outgoing"});
        },
        onOutgoingCallTimeout: (s,ss,as)async{
          print("======================");
          print("onOutgoingCallTimeout");
          // Map res = await httpClient.saveCallLog(
          //     {'receiver_id': user.id, 'duration': 0, 'status': "Outgoing"});
        },
        onInvitationUserStateChanged: (ss ){
          print("State changed =====");
        }
      )
      // uiConfig:
    );
    print('Initialized zego cloud signaling');
  }

  Future<bool> saveUser(Map<String, dynamic> user) async {
    _setUser(user);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Saving user printing-->$user');
    await prefs.setString('user', jsonEncode(user));
    return true;
  }

  Future<bool> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode({}));
    await prefs.setString('token', '');
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    return true;
  }


  Future checkAuth() async {
    Map res = await httpClient.authCheckWithoutTokenRefresh();

    if (res['code'] == 200) {
      Map<String, dynamic> userData = res['data']['user'];
      print("====userData");
      print(userData);
      authUser.saveUser(userData);
    }
  }
}

AuthUser authUser = new AuthUser();

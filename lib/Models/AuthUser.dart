import 'dart:convert';

import 'package:north_star/Controllers/ZegoCloudController.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

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
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoCloudController.appID /*input your AppID*/,
      appSign: ZegoCloudController.appSign /*input your AppSign*/,
      userID: userObj['id'],
      userName: userObj['name'],
      plugins: [ZegoUIKitSignalingPlugin()],
    );
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

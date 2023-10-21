import 'dart:convert';

import 'package:north_star/Models/HttpClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  late int id;
  late String name;
  late String email;
  late String role;
  late String token;
  late Map user;

  void _setUser(Map<String, dynamic> userObj) {
    id = int.parse(userObj['id']) ;
    name = userObj['name'];
    email = userObj['email'];
    role = userObj['role'];
    user = userObj;
  }

  Future<bool> saveUser(Map<String, dynamic> user) async {
    _setUser(user);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
    return true;
  }

  Future<bool> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode({}));
    await prefs.setString('token', '');
    return true;
  }

  Future checkAuth() async {
    Map res = await httpClient.authCheckWithoutTokenRefresh();
    if (res['code'] == 200) {
      Map<String, dynamic> userData = res['data']['user'];
      authUser.saveUser(userData);
    }
  }
}

AuthUser authUser = new AuthUser();

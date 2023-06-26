import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpClient{
  http.Client secClient = new http.Client();
  String token = '';
  int expireIn = 0;
  int id = 0;


  //static String baseURL = 'http://10.0.2.2:8000';
  static String baseURL = 'https://api.northstar.mv';

  var headers;

  HttpClient();

  void changeToken(String newToken){
    this.token = newToken;
    this.headers = {
      'Authorization': 'Bearer $newToken',
      'Content-Type': 'application/json'
    };
  }

  void changeExpireIn(int seconds){
    this.expireIn = seconds;
  }
  void changeID(int newID){
    this.id = newID;
  }

  String getToken(){
    return this.token;
  }

  getHeader(){
    return this.headers;
  }

  Future<dynamic> post(String url, Map body) async {
    var request = http.Request('POST', Uri.parse(baseURL + url));
    request.headers.addAll(this.headers);
    request.body = jsonEncode(body);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = jsonDecode(await response.stream.bytesToString());
      print(res);
      return res;
    } else {
      var res = jsonDecode(await response.stream.bytesToString());
      print(res);
      return res;
    }
  }

  Future<dynamic> get(String url) async {
    var request = http.Request('GET', Uri.parse(baseURL + url));
    request.headers.addAll(this.headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = jsonDecode(await response.stream.bytesToString());
      print(res);
      return res;
    } else {
      var res = jsonDecode(await response.stream.bytesToString());
      print(res);
      return res;
    }
  }

  Future<List> search(String url, String pattern) async{
    var request = http.Request('POST', Uri.parse(baseURL + url));
    request.headers.addAll(this.headers);
    request.body = jsonEncode({'search_key': pattern});
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = jsonDecode(await response.stream.bytesToString());
      print(res);
      return res;
    } else {
      var dt = jsonDecode(await response.stream.bytesToString());
      print(dt);
      return [];
    }
  }

}

HttpClient client = new HttpClient();

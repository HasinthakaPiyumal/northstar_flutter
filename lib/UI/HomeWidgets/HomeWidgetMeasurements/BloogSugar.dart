import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:http/http.dart' as http;

class BloodSugar extends StatelessWidget {
  const BloodSugar({Key? key, this.user}) : super(key: key);
  final user;

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxMap result = {}.obs;
    TextEditingController bloodSugarController = TextEditingController();

    RxString unit = 'AfterEating'.obs;

    void saveResult() async{
      ready.value = false;
      var request = http.MultipartRequest('POST', Uri.parse('http://139.59.111.170/api/boodsugartest'));
      request.headers.addAll(client.getHeader());

      request.fields.addAll({
        'boodsugarcount': bloodSugarController.text,
        'unit': unit.value,
        'user_id': user['id'].toString(),
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        var res = jsonDecode(await response.stream.bytesToString());
        print(res);
        result.value = res;
        ready.value = true;
      } else {
        var res = jsonDecode(await response.stream.bytesToString());
        showSnack('Error', res.toString());
        ready.value = true;
      }
    }

    void getResult(){
      if(bloodSugarController.text !=''){
        saveResult();
      } else {
        showSnack('Empty Values!', 'Please fill all the values');
      }
    }

    return Scaffold(
        backgroundColor: Color(0xffE2E2E2),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text('A'),
                        ),
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        trailing: IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () => Get.back(),
                        )
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: bloodSugarController,
                            decoration: InputDecoration(
                              labelText: 'Blood Sugar Count',
                              hintText: '200',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Obx(()=>Container(
                            height: 58,
                            child: OutlinedButton(
                                child: Text('Unit : ${unit.value}'),
                                onPressed: (){
                                  Get.defaultDialog(
                                      radius: 4,
                                      title: 'Select Unit',
                                      content: Column(
                                        children: [
                                          CupertinoButton(
                                            child: Text('Fasting'),
                                            onPressed: (){
                                              unit.value = 'Fasting';
                                              Get.back();
                                            },
                                          ),
                                          CupertinoButton(
                                            child: Text('After Eating'),
                                            onPressed: (){
                                              unit.value = 'AfterEating';
                                              Get.back();
                                            },
                                          ),
                                          CupertinoButton(
                                            child: Text('Hours After Eating'),
                                            onPressed: (){
                                              unit.value = 'HoursAfterEating';
                                              Get.back();
                                            },
                                          ),
                                        ],
                                      )
                                  );
                                }
                            ),
                          )),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: Get.width,
                      height: 58,
                      child: Obx(() {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: Themes().roundedBorder(12),
                              backgroundColor: Color(0xFF1C1C1C)),
                          child: !ready.value
                              ? Center(
                            child: CircularProgressIndicator(),
                          )
                              : Text(
                            'Calculate',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          onPressed: () {
                            getResult();
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(()=> Text(result['value'] ?? '', style: TypographyStyles.title(16),))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(()=> Text(result.toString() != '"Please Enter Correct Data"' ? '' : 'Please Enter Correct Data', style: TypographyStyles.title(16),)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}

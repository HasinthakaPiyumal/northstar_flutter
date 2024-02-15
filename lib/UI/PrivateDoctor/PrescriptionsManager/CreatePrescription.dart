import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:http/http.dart' as http;
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/PopUps.dart';

class CreatePrescription extends StatelessWidget {
  const CreatePrescription({Key? key, this.userData}) : super(key: key);

  final userData;

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxList meds = [].obs;
    TextEditingController prescriptionInfo = TextEditingController();

    void savePrescription() async{
      ready.value = false;
      var request = http.Request('POST', Uri.parse(HttpClient.baseURL +'/api/fitness/prescriptions/actions/save'));
      request.headers.addAll(client.getHeader());

      var medicines = [];

      meds.forEach((element) {
        medicines.add({
          'name': element['name'].text,
          'dose': element['dosage'].text,
        });
      });

      request.body = jsonEncode({
        'user_id': userData['id'],
        'doctor_id': authUser.id,
        'prescription_data': {
          'prescription_info': prescriptionInfo.text,
          'medicines': medicines,
        },
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = jsonDecode(await response.stream.bytesToString());
        print(res);
        Get.back();
        showSnack('Prescription Saved!', 'Prescription Saved Successfully!');
      } else {
        print(await response.stream.bytesToString());
        ready.value = true;
      }
    }

    return WillPopScope(
      onWillPop: () async {
        CommonConfirmDialog.confirm('Discard').then((value){
          if(value){
            Get.back();
            return true;
          } else {
            return false;
          }
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Prescription'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/avatars/' + userData['avatar_url'],
                    ),
                  ),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userData['name'], style: TypographyStyles.title(20),),
                      SizedBox(height: 5,),
                      Text(userData['email']),
                    ],
                  )
                ],
              ),
              SizedBox(height: 10,),
              Divider(),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text('Prescription', style: TypographyStyles.title(18),),
                ],
              ),
              SizedBox(height: 15,),
              TextField(
                controller: prescriptionInfo,
                decoration: InputDecoration(
                  hintText: 'Enter Prescription',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Medicines', style: TypographyStyles.title(18)),
                  Container(
                    height: 58,
                    child: TextButton(
                      onPressed: () {
                        meds.add({
                          'name': TextEditingController(),
                          'dosage': TextEditingController(),
                        });
                      },
                      child: Text('+ Add Medicine'),
                    ),
                  )
                ],
              ),

              Expanded(
                child: Obx(()=>ListView.builder(
                  itemCount: meds.length,
                  itemBuilder: (_,index){
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: meds[index]['name'],
                              decoration: InputDecoration(
                                hintText: 'Medicine Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: meds[index]['dosage'],
                              decoration: InputDecoration(
                                hintText: 'Dosage',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                    );
                  },
                )),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            height: 58,
            width: Get.width,
            child: ElevatedButton(
              onPressed: (){
                savePrescription();
              },
              style: ButtonStyles.bigBlackButton(),
              child: Text('Save',
                style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
class QualificationsAddEdit extends StatelessWidget {
  const QualificationsAddEdit({Key? key, this.qData}) : super(key: key);

  final qData;

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;

    TextEditingController title = new TextEditingController();
    TextEditingController description = new TextEditingController();

    void saveOrEditQualifications() async{
      ready.value = false;
      Map data;
      if(qData != null){
        data ={
          "id": qData["id"],
          "user_id": authUser.id,
          "title": title.text,
          "description": description.text
        };
      } else {
        data = {
          "user_id": authUser.id,
          "title": title.text,
          "description": description.text
        };
      }

      Map res = await httpClient.saveOrEditQualification(data);

      if (res['code'] == 200) {
        print(res);
        Future.delayed(Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        Get.back();
        ready.value = true;
      }
    }

    void fillFields(){
      if(qData != null){
        title.text = qData["title"];
        description.text = qData["description"];
      }
    }

    fillFields();

    return Scaffold(
      appBar: AppBar(
        title: Text('Qualifications'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      hintText: 'Title',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: description,
                    decoration: InputDecoration(
                      hintText: 'Description',
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 56,
                    width: Get.width,
                    child: Obx(()=>ElevatedButton(
                      style: ButtonStyles.bigBlackButton(),
                      child: ready.value ? Text('Save'): CircularProgressIndicator(),
                      onPressed: (){
                        if( title.text.isEmpty || description.text.isEmpty){
                          showSnack('Error', 'Please fill all fields');
                        } else {
                          saveOrEditQualifications();
                        }
                      },
                    )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../Styles/TypographyStyles.dart';

class QualificationsAddEdit extends StatelessWidget {
  const QualificationsAddEdit({Key? key, this.qData}) : super(key: key);

  final qData;

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;

    TextEditingController title = new TextEditingController();
    TextEditingController description = new TextEditingController();

    void saveOrEditQualifications() async {
      ready.value = false;
      Map data;
      if (qData != null) {
        data = {
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

    void fillFields() {
      if (qData != null) {
        title.text = qData["title"];
        description.text = qData["description"];
      }
    }

    fillFields();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Qualifications', style: TypographyStyles.title(20)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.star_border),
                        hintText: 'Title',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        )),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: description,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Description',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        )),
                  ),
                  SizedBox(height: 26),
                  Container(
                    height: 44,
                    width: Get.width-60,
                    child: Obx(() => ElevatedButton(
                          style: ButtonStyles.bigFlatYellowButton(),
                          child: ready.value
                              ? Text('Save',style: TextStyle(
                            color: Color(0xFF1B1F24),
                            fontSize: 20,
                            fontFamily: 'Bebas Neue',
                            fontWeight: FontWeight.w400,
                          ),)
                              : CircularProgressIndicator(),
                          onPressed: () {
                            if (title.text.isEmpty ||
                                description.text.isEmpty) {
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

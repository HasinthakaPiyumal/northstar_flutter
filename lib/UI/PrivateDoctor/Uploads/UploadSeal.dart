import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

class UploadSeal extends StatelessWidget {
  const UploadSeal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    RxBool hasSelectImage = false.obs;
    RxBool ready = true.obs;

    var xFile;
    var avatar;

    void pickFile() async {
      xFile = await picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        avatar = File(xFile.path);
        hasSelectImage.value = true;
        print(xFile.path);
      }
    }

    void uploadFile() async {
      ready.value = false;
      Map res = await httpClient.uploadSeal(xFile);

      print(res);
      if(res['code'] == 200) {
        Get.back();
      } else {
        ready.value = true;
        showSnack('Upload Failed', res['data'].toString());
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Seal'),
      ),
      body: Obx(()=> ready.value ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(),
            Container(
              width: Get.width * 0.8,
              height: 48,
              child: ElevatedButton(
                style: ButtonStyles.bigBlackButton(),
                child: Text('Pick Your Seal'),
                onPressed: pickFile,
              ),
            ),
            SizedBox(height: 16),
            hasSelectImage.value ? Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: Get.width * 0.8,
                    height: Get.width * 0.8,
                    child: Image.file(avatar,fit: BoxFit.fitWidth),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: Get.width * 0.8,
                  height: 48,
                  child: ElevatedButton(
                    style: ButtonStyles.bigBlackButton(),
                    child: Text('Upload'),
                    onPressed: (){
                      uploadFile();
                    },
                  ),
                ),
              ],
            ) : Container(),
          ],
        ),
      ): Center(child: CircularProgressIndicator())),
    );
  }
}

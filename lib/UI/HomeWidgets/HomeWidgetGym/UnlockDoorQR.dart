import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../Styles/TypographyStyles.dart';

class UnlockDoorQR extends StatelessWidget {
  const UnlockDoorQR({Key? key, this.gymID}) : super(key: key);
  final gymID;
  @override
  Widget build(BuildContext context) {

    MobileScannerController cameraController = MobileScannerController();

    void unlockGym(gymID) async{
      cameraController.stop();
      Map res = await httpClient.unlockDoor({
        'user_id': authUser.id,
        'gym_id': gymID
      });
      print(res);
      if(res['code'] == 200){
        Get.back();
        showSnack('Gym Unlocked!', 'The Door is now open for you to enter!');
      } else if (res['code'] == 401){
        Get.back();
        showSnack(res['data']['error'], res['data']['info']['message']);
      } else {
        Get.back();
        showSnack('Error', 'Something went wrong!');
      }
    }


    return Scaffold(
      appBar: AppBar(  centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Unlock Door QR',style: TypographyStyles.title(20)),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: Get.width,
            width: Get.width,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MobileScanner(
                controller: cameraController,
                onDetect: (barcode) {
                  print('detected barcode');
                  print(barcode.barcodes[0].rawValue);
                  int gymID = int.parse(barcode.barcodes[0].rawValue!);
                  unlockGym(gymID);
                },
              ),
            )
          ),
          SizedBox(height: Get.height * 0.05),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text('Scan the QR Code on the door to unlock it.',
                textAlign: TextAlign.center,
                style: TypographyStyles.text(16),
            )
          )
        ],
      ),
    );
  }
}

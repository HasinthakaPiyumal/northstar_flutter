import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../Styles/TypographyStyles.dart';

class VendingQr extends StatelessWidget {
  const VendingQr({Key? key, this.gymID}) : super(key: key);
  final gymID;
  @override
  Widget build(BuildContext context) {

    MobileScannerController cameraController = MobileScannerController();

    void unlockGym(gymID) async{
      cameraController.stop();
        showSnack('Error', 'Something went wrong!');
    }


    return Scaffold(
      appBar: AppBar(  centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('QR Code Scan',style: TypographyStyles.title(20)),
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
                    int gymID = int.parse(barcode.raw.toString());
                    unlockGym(gymID);
                  },
                ),
              )
          ),
          SizedBox(height: Get.height * 0.05),
          Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text('Scan the QR Code on the vending machine to by it.',
                textAlign: TextAlign.center,
                style: TypographyStyles.text(16),
              )
          )
        ],
      ),
    );
  }
}

import 'dart:convert';

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

    void confirmDialog(vendingStr) async{
      cameraController.stop();
      try {
        Map<String, dynamic> vendingJson = jsonDecode(vendingStr);
        List<String> requiredKeys = ['product_code', 'name', 'price', 'quantity', 'orderId'];

        for (String key in requiredKeys) {
          if (!vendingJson.containsKey(key) || vendingJson[key] == null) {
            String errorMessage = "Missing $key field!";
            Get.back();
            showSnack('Error', errorMessage);
            break;
          }
        }
        Get.back(result: vendingJson);
        // showSnack("Success!", "QR scan complete.");
      } catch (e, s) {
        Get.back();
        showSnack('Error', "Something Went Wrong in QR Code");
      }

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
                  onDetect: (vendingJson) {
                    String vendingStr =vendingJson.barcodes[0].rawValue!.toString();
                    confirmDialog(vendingStr);
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

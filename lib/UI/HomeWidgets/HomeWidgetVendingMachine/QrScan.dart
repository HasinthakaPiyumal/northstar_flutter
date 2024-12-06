import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetVendingMachine/VendingCart.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';

import '../../../Styles/TypographyStyles.dart';
import 'MyOrders.dart';

class VendingQr extends StatelessWidget {
  const VendingQr({Key? key, this.gymID}) : super(key: key);
  final gymID;
  @override
  Widget build(BuildContext context) {

    MobileScannerController? cameraController;
    RxBool cameraStarted = false.obs;
    RxBool tryAgain = false.obs;

    bool checkQr(vendingJson){
      List<String> requiredKeys = ['product_code', 'name', 'price', 'quantity', 'orderId'];

      for (String key in requiredKeys) {
        if (!vendingJson.containsKey(key) || vendingJson[key] == null) {
          String errorMessage = "Missing $key field!";
          return false;
        }
      }
      vendingJson['quantity'] = int.parse("${vendingJson['quantity']}");
      if(!(vendingJson['quantity'] is int)){
        return false;
      }
      return true;
    }

    void confirmDialog(vendingStr) async{
      cameraController?.stop();
      cameraController = null;
      try {
        Map<String, dynamic> vendingJson = jsonDecode(vendingStr);
        if(checkQr(vendingJson)){
          vendingJson['price'] = double.parse(double.parse("${vendingJson['price']}").toStringAsFixed(2));
          showSnack('qr  code scan successful', "Now you are being redirected to cart page...",status: PopupNotificationStatus.success);
          Get.off(()=>VendingCart(orderDetails: vendingJson,));
          // Future.delayed(Duration(seconds: 3),()async{
          // });
        }else{
          showSnack('the QR code scan has failed', "Oops! Something went wrong with the QR code",status: PopupNotificationStatus.error);
        }
        cameraStarted.value = false;
      } catch (e, s) {
        // Get.back();
        cameraStarted.value = false;
        tryAgain.value = true;
        showSnack('the QR code scan has failed', "Oops! Something went wrong with the QR code",status: PopupNotificationStatus.error);
      }

    }


    return Scaffold(
      appBar: AppBar(  centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('QR Code Scan',style: TypographyStyles.title(20)),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/svgs/vending-history.svg",
              width: 20,
              height: 20,
              color:
              Get.isDarkMode ? Colors.white : AppColors.textOnAccentColor,
            ),
            onPressed: () {
              Get.to(HomeWidgetVendingMachineMyOrders());
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 60,),
            Text("Scan QR Code",style:TextStyle(
              fontSize: 20,
              fontFamily: 'Bebas Neue',
              fontWeight: FontWeight.w400,
              height: 0,
            ),),
            SizedBox(height: 4,),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Text('Scan the QR code in the vending machine to buy your product',
                  textAlign: TextAlign.center,
                  style: TypographyStyles.text(14),
                )
            ),
            Obx(()=> cameraStarted.value? Container(
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
              ):Container(
                margin: EdgeInsets.all(16),
                child: Lottie.asset(
                  'assets/lotties/qr-scan.json',
                  // Replace with your animation file path
                  width:  Get.width,
                  height:  Get.width,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: 20,),
            Obx(()=>Buttons.yellowFlatButton(onPressed: (){
              cameraController = MobileScannerController();
              cameraStarted.value = true;
              cameraController?.start();
            },label: !tryAgain.value?"Scan":"Try Again",width: Get.width-64,isLoading:cameraStarted.value)),
            SizedBox(height: 20,),
            Obx(() => Visibility(visible:!cameraStarted.value&&tryAgain.value,child: Buttons.outlineButton(onPressed: (){Get.back();},label: "Go Back",width: Get.width-64)))
          ],
        ),
      ),
    );
  }
}

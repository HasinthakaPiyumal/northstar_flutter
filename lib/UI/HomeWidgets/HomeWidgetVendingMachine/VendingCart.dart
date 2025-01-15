import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/components/Radios.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Controllers/TaxController.dart';
import '../../../Models/HttpClient.dart';
import '../../../Utils/PopUps.dart';
import '../../../components/Buttons.dart';
import '../../SharedWidgets/CommonConfirmDialog.dart';
import '../../SharedWidgets/PaymentVerification.dart';
import 'MyOrders.dart';

class VendingCart extends StatelessWidget {
  const VendingCart({required this.orderDetails});
  final Map orderDetails;

  @override
  Widget build(BuildContext context) {
    RxMap walletData = {}.obs;
    RxBool ready = false.obs;
    RxBool isWallet = true.obs;

    void getWalletData() async {
      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
        ready.value = true;
      } else {
        print(res);
      }
    }
    void payWithCard(result) async {
      result['payment_type'] = 1;
      print('payment result');
      print(result);

      Map res = await httpClient.purchaseDrink(result);

      print('===res');
      print(res);
      if (res['code'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        Get.to(() => PaymentVerification());
      } else {
        showSnack("Booking Failed", res['data']['message'],status:PopupNotificationStatus.error);
      }
      print('===res');
      print(res);
    }
    void payByWallet(){
      if (walletData.value['balance'] >= orderDetails['price']) {
        CommonConfirmDialog.confirm("Process Payment")
            .then((value) async {
          if(value){
            ready.value = false;
            orderDetails['payment_type'] = 2;
            Map res = await httpClient.purchaseDrink(orderDetails);
            print(res);
            if (res['code'] == 200) {
              ready.value = true;
              Get.off(() => HomeWidgetVendingMachineMyOrders());
              print('Purchasing Success ---> $res');
              showSnack(
                  'Purchasing Successful', 'You have paid for a vending machine product ${orderDetails['name']}',status: PopupNotificationStatus.success);
            } else {
              ready.value = true;
              showSnack('Purchasing Failed', res['data']['message'],status: PopupNotificationStatus.error);
            }
          }
        });
      } else {
        showSnack('Not Enough Balance',
            'You do not have enough balance to pay for this Purchasing',status:PopupNotificationStatus.error);
      }
    }

    getWalletData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Order"),
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => ready.value
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? AppColors.primary2Color
                            : Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Summary",
                          style: TypographyStyles.title(20),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order Id:', style: TypographyStyles.text(16)),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                              orderDetails['orderId'],
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Product Code:',
                                style: TypographyStyles.text(16)),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                              orderDetails['product_code'],
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Product Name:',
                                style: TypographyStyles.text(16)),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                              orderDetails['name'],
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantity:', style: TypographyStyles.text(16)),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                              orderDetails['quantity'].toString(),
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                        // SizedBox(height: 8,),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text('E-Wallet balance:',style: TextStyle(fontWeight: FontWeight.w300)),
                        //     SizedBox(width: 10,),
                        //     Expanded(child: Text("MVR ${walletData['balance'].toStringAsFixed(2)}",textAlign: TextAlign.end,)),
                        //   ],
                        // ),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: TextStyle(
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Bebas Neue',
                                  fontWeight: FontWeight.w400,
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text("MVR ${orderDetails['price']}",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child: Container(
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Your Payment Method",
                      style: TypographyStyles.title(20),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              isWallet.value = true;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: Get.width / 2 -24,
                              decoration: BoxDecoration(
                                  color: Get.isDarkMode
                                      ? AppColors.primary2Color
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      "assets/icons/wallet.png",
                                      width: 48,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "E-gift",
                                          style: TypographyStyles.text(16),
                                        ),
                                        !isWallet.value
                                            ? Radios.radio()
                                            : Radios.radioChecked2(),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Balance: MVR ${walletData['balance'].toStringAsFixed(2)}",
                                      style: TypographyStyles.text(12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16,),
                          InkWell(
                            onTap: () {
                              isWallet.value = false;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              width: Get.width / 2 -24,
                              decoration: BoxDecoration(
                                  color: Get.isDarkMode
                                      ? AppColors.primary2Color
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      "assets/icons/card.png",
                                      width: 48,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Bank Card",
                                          style: TypographyStyles.text(16),
                                        ),
                                        isWallet.value
                                            ? Radios.radio()
                                            : Radios.radioChecked2(),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Tax amount: MVR ${(taxController.getCalculatedTax(orderDetails['price'])).toStringAsFixed(2)}',
                                      style: TypographyStyles.text(12),
                                    ),
                                    Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])
              : Container(
            margin: EdgeInsets.only(top:Get.height/2-96),
              child: LoadingAndEmptyWidgets.loadingWidget()),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Buttons.yellowFlatButton(onPressed: (){
          if(isWallet.value){
            payByWallet();
          }else{
            payWithCard(orderDetails);
          }
        },width: Get.width-32,label: "Proceed To Pay"),
      ),
    );
  }
}

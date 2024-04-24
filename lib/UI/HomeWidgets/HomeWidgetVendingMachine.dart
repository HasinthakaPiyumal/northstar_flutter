import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/components/MaterialBottomSheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Controllers/TaxController.dart';
import '../../Models/HttpClient.dart';
import '../../Styles/ButtonStyles.dart';
import '../../Styles/SignUpStyles.dart';
import '../../Styles/Themes.dart';
import '../../Utils/PopUps.dart';
import '../../components/Buttons.dart';
import '../SharedWidgets/LoadingAndEmptyWidgets.dart';
import '../SharedWidgets/PaymentVerification.dart';
import 'HomeWidgetVendingMachine/MyOrders.dart';
import 'HomeWidgetVendingMachine/QrScan.dart';

class HomeWidgetVendingMachine extends StatelessWidget {
  const HomeWidgetVendingMachine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxList<dynamic> cat = RxList<dynamic>([
      {"url": "https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/vending_machine/1.png"},
      {"url": "https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/vending_machine/2.png"},
      {"url": "https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/vending_machine/3.png"},
    ]);
    RxList<dynamic> pro = RxList<dynamic>([
      {"url": "https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/vending_machine/4.png"},
      {"url": "https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/vending_machine/5.png"},
      {"url": "https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/vending_machine/6.png"},
    ]);


    void payWithCard(result)async {
      result['payment_type'] = 1;
      print('payment result');
      print(result);
      Map res = await httpClient.purchaseDrink(result);

      print('===res');
      print(res);
      if(res['code']==200){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        Get.to(()=>PaymentVerification());
      }else{
        showSnack("Booking Failed",res['data']['message'] );
      }
      print('===res');
      print(res);
    }
    void showConfirmation(result) async{
      print('Confirm Payment');
      print(result);
      RxMap walletData = {}.obs;
      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
      } else {
        print(res);
      }
      MaterialBottomSheet("Confirm Payment",
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order Id:',style: TextStyle(fontWeight: FontWeight.w300)),
                  SizedBox(width: 10,),
                  Expanded(child: Text(result['orderId'],textAlign: TextAlign.end,)),
                ],
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Product Code:',style: TextStyle(fontWeight: FontWeight.w300)),
                  SizedBox(width: 10,),
                  Expanded(child: Text(result['product_code'],textAlign: TextAlign.end,)),
                ],
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Product Name:',style: TextStyle(fontWeight: FontWeight.w300)),
                  SizedBox(width: 10,),
                  Expanded(child: Text(result['name'],textAlign: TextAlign.end,)),
                ],
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quantity:',style: TextStyle(fontWeight: FontWeight.w300)),
                  SizedBox(width: 10,),
                  Expanded(child: Text(result['quantity'].toString(),textAlign: TextAlign.end,)),
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
              SizedBox(height: 8,),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Price:',style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16)),
                  SizedBox(width: 10,),
                  Expanded(child: Text("MVR ${result['price']}",textAlign: TextAlign.end,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16))),
                ],
              ),
              SizedBox(height: 20,),
              Container(
                width: Get.width,
                child: ElevatedButton(
                  onPressed: () async {
                    if (walletData.value['balance'] >= result['price']) {
                      CommonConfirmDialog.confirm("Process Payment").then((value) async{

                          ready.value = false;
                          result['payment_type'] = 2;
                          Map res = await httpClient.purchaseDrink(result);
                          print(res);
                          if (res['code'] == 200) {
                            ready.value = true;
                            Get.back();
                            Get.to(() => HomeWidgetVendingMachineMyOrders());
                            print('Purchasing Success ---> $res');
                            showSnack('Purchasing Successful', 'Your drink will be ready shortly.');
                          } else {
                            ready.value = true;
                            Get.back();
                            showSnack('Purchasing Failed',
                                res['data']['message']);
                          }

                      });
                    } else {
                      showSnack('Not Enough Balance',
                          'You do not have enough balance to pay for this Purchasing');
                    }
                  },
                  style: ButtonStyles.matButton(Themes.mainThemeColor.shade500, 0),
                  child: Obx(() => ready.value ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Pay with eWallet',
                          style: TypographyStyles.boldText(16, Colors.black),
                        ),
                        SizedBox(height: 3,),
                        Text('(eWallet Balance: ${walletData['balance'].toStringAsFixed(2)})',
                          style: TypographyStyles.normalText(13, Colors.black),
                        ),
                      ],
                    ),
                  ) : CircularProgressIndicator(color: AppColors.textOnAccentColor,)),
                ),
              ),
              SizedBox(height: 16,),
              Container(
                width: Get.width,
                padding: EdgeInsets.only(top: 3),
                child: ElevatedButton(
                  onPressed: () {
                    payWithCard(result);
                    // subscribeNow(plan);
                  },
                  style: SignUpStyles.selectedButton(),
                  child: Obx(() => ready.value
                      ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.asset('assets/BMLLogo.jpeg'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            children: [
                              Text(
                                'Pay with Card',
                                style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontSize: 20,
                                  fontFamily: 'Bebas Neue',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              Text(
                                'Tax amount: MVR ${(taxController.getCalculatedTax(result['price'])).toStringAsFixed(2)}',
                                style: TypographyStyles.text(10),
                              )
                            ],
                          )
                        ]),
                  )
                      : LoadingAndEmptyWidgets.loadingWidget()),
                ),
              ),
              SizedBox(height: 16,),
              Buttons.outlineButton(onPressed: (){
                Get.back();
              },label: "Cancel",width: Get.width-40)

            ],
          ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Vending Machine'),
          actions: [
            IconButton(
              icon: Icon(Icons.paste_rounded),
              onPressed: () {
                Get.to(HomeWidgetVendingMachineMyOrders());
              },
            )
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColors.accentColor),
          child: IconButton(
            icon: Icon(Icons.qr_code_scanner_outlined),
            color: AppColors.textOnAccentColor,
            onPressed: () {
              Get.to(VendingQr())?.then((value) {
                print('Vending machine return');
                print(value);
                if (value != null) {
                  showConfirmation(value);
                }
              });
            },
          ),
        ),
        // body: Container(
        //   margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        //   // height: 460,
        //   width: Get.width - 20,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(8),
        //     color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
        //   ),
        //   child: Column(
        //     // mainAxisAlignment: MainAxisAlignment.center, // Align vertically
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       SizedBox(
        //         height: 20,
        //       ),
        //       Text(
        //         "Get Your Refreshment Here!", // A  catchier headline
        //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        //       ),
        //       SizedBox(height: 20), // Add a little spacing
        //       Lottie.asset(
        //         'assets/lotties/drink.json',
        //         width: 200, // Adjust size as needed
        //         height: 200,
        //         fit: BoxFit.contain, // Ensure animation fits within space
        //       ),
        //       SizedBox(height: 40),
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 16),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               "Instructions:",
        //               style:
        //                   TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        //             ),
        //             SizedBox(height: 15),
        //             Text(
        //                 "1. Choose your drink and follow the machine's instructions."),
        //             Text("2. Select payment method: E-Wallet."),
        //             Text("3. Scan the QR code on the machine."),
        //             Text("4. Pay with your preferred e-wallet."),
        //           ],
        //         ),
        //       ),
        //       SizedBox(
        //         height: 30,
        //       ),
        //     ],
        //   ),
        // )
        body: Column(
          children: [
            Obx(
              () => Container(
                height: 160,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cat.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Obx(() => InkWell(
                                onTap: () {
                                  print(cat[index][
                                      'url']); // Changed to 'url' instead of 'id'
                                },
                                child: Container(
                                    margin: EdgeInsets.only(
                                        right: cat.length - 1 == index ? 16 : 8,
                                        left: index == 0 ? 16 : 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10)),
                                    width: 160,
                                    height: 160,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: CachedNetworkImage(
                                          imageUrl: cat[index]['url'],
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                // Display image or content
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ));
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                width: Get.width - 32,
                child: Text(
                  "Products",
                  style: TypographyStyles.title(20),
                  textAlign: TextAlign.start,
                )),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: pro.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Obx(() => InkWell(
                            onTap: () {
                              print(pro[index]
                                  ['url']); // Changed to 'url' instead of 'id'
                            },
                            child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                width: 160,
                                height: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                    pro[index]['url'],
                                    fit: BoxFit.cover,
                                  ),
                                )),
                            // Display image or content
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ));
                    },
                    scrollDirection: Axis.vertical,
                  ),
                ),
              ),
            ),
          ],
        ),
        );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/TaxController.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/CouponApply.dart';

import '../../Models/HttpClient.dart';
import '../../Styles/AppColors.dart';
import '../../Styles/TypographyStyles.dart';
import '../../components/Buttons.dart';
import '../../components/Radios.dart';
import 'LoadingAndEmptyWidgets.dart';

class PaymentSummary extends StatelessWidget {
  PaymentSummary({
    required this.orderDetails,
    required this.total,
    this.headerWidget = const SizedBox(),
    required this.payByCard,
    required this.payByWallet,
    this.isCouponAvailable = false
  });
  Widget headerWidget;
  final Function payByCard;
  final Function payByWallet;
  final List<SummaryItem> orderDetails;
  final double total;

  bool isCouponAvailable;


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
    getWalletData();
    void proceedNow(){
      if(isWallet.value){
        if(walletData['balance']>=total){
          payByWallet();
        }else{
          showSnack('Insufficient Balance',
              'You do not have sufficient balance to pay for this booking.',status: PopupNotificationStatus.error);
        }
      }else{
        payByCard();
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Summary'),
      ),
      body: SingleChildScrollView(
        child: Obx(
              () => ready.value
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(child: headerWidget),
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
                    "Summary",
                    style: TypographyStyles.title(20),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: orderDetails.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 8,);
                      },
                      itemBuilder: (context,index){
                        SummaryItem item = orderDetails[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.head}:', style: TypographyStyles.text(16)),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                                  item.value.toString(),
                                  textAlign: TextAlign.end,
                                )),
                          ],
                        );
                  }, ),
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
                          child: Text("MVR ${total}",
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
                                    "Ewallet",
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
                                    "Band Card",
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
                                'Tax amount: MVR ${(taxController.getCalculatedTax(total)).toStringAsFixed(2)}',
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
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isCouponAvailable?CouponApply(type: 1, typeId: 1, couponValue: 0.0.obs, payingAmount: 100, couponCode: "111".obs):SizedBox(),
            SizedBox(height: isCouponAvailable?16:0,),
            Buttons.yellowFlatButton(onPressed: (){
              proceedNow();
            },label: 'payment proceed now',width: Get.width),
          ],
        ),
      ),
    );
  }
}

class SummaryItem {
  late String head;
  dynamic value;
  SummaryItem({required this.head, required this.value});
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Styles/AppColors.dart';
import '../../Styles/ButtonStyles.dart';
import '../../Styles/Themes.dart';
import '../../Styles/TypographyStyles.dart';
import '../../components/Radios.dart';

class CardPayment extends StatelessWidget {
  CardPayment(double total);

  @override
  Widget build(BuildContext context) {
    TextEditingController cardNumberController = new TextEditingController();
    TextEditingController cardHolderController = new TextEditingController();
    TextEditingController expireMonthController = new TextEditingController();
    TextEditingController csvController = new TextEditingController();

    RxInt cardType = 1.obs;
    RxBool agree = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body:  Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image.asset("assets/images/credit_cards.png"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          cardType.value = 1;
                        },
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.primary2Color),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            width: (Get.width / 2) - 24,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Image.asset("assets/icons/visaCard.png"),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Visa",
                                      style: TypographyStyles.text(16),
                                    ),
                                    cardType == 1
                                        ? Radios.radioChecked()
                                        : Radios.radio(),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          cardType.value = 2;
                        },
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.primary2Color),
                          child: Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            width: (Get.width / 2) - 24,

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Image.asset("assets/icons/masterCard.png"),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Master",
                                      style: TypographyStyles.text(16),
                                    ),
                                    cardType == 2
                                        ? Radios.radioChecked()
                                        : Radios.radio(),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                  TextField(
                    controller: cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: cardHolderController,
                    decoration: InputDecoration(
                      labelText: 'Card Holder Name',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: (Get.width * 0.5)-24,
                        child: TextField(
                          controller: expireMonthController,
                          decoration: InputDecoration(
                            labelText: 'MM/YY',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      Container(
                        width: (Get.width * 0.5)-24,
                        child: TextField(
                          controller: csvController,
                          decoration: InputDecoration(
                            labelText: 'CSV',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(value: agree.value, onChanged: (bool? newValue){agree.value = newValue!;}),
                      GestureDetector(onTap:(){agree.value=!agree.value;},child: Text("I ‘ve read and agree ",style: TypographyStyles.textWithWeight(14,FontWeight.w300),)),
                      Text("Terms",style: TypographyStyles.textWithWeightUnderLine(14,FontWeight.w300),),
                      GestureDetector(onTap:(){agree.value=!agree.value;},child: Text(" and ",style: TypographyStyles.textWithWeight(14,FontWeight.w300),)),
                      Text("Privacy Policy",style: TypographyStyles.textWithWeightUnderLine(14,FontWeight.w300),),
                    ],
                  ),
                  SizedBox(height: 40,),
                  Container(
                    height: 44,
                    width: Get.width,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () async {},

                      style: ButtonStyles.matButton(
                          Themes.mainThemeColor.shade500, 0),
                      child: Text(
                        'PAY now',
                        style: TextStyle(
                          color: AppColors.textColorLight,
                          fontSize: 20,
                          fontFamily: 'Bebas Neue',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height:16),
                  Container(
                    height: 44,
                    width: Get.width - 64,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: AppColors.accentColor,
                        width: 1.25,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'close',
                        style: TypographyStyles.smallBoldTitle(20),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),)
    );
  }
}

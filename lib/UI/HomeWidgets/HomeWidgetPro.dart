import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/ProModel.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/CouponApply.dart';

class HomeWidgetPro extends StatelessWidget {
  HomeWidgetPro({Key? key, this.extend = false}) : super(key: key);
  final bool extend;

  @override
  Widget build(BuildContext context) {
    print(extend);
    RxList plansList = [].obs;

    RxInt _current = 0.obs;
    RxBool ready = true.obs;
    RxMap walletData = {}.obs;
    RxBool check = false.obs;
    ProList _proList = ProList();
    RxInt selectedPackage = 0.obs;

    RxDouble couponValue = 0.0.obs;
    RxInt couponPercentage = 0.obs;

    TextEditingController couponController = new TextEditingController();
    void applyCoupon() async {
      if (couponPercentage.value > 0) {
        couponPercentage.value = 0;
        return;
      }
      const data = {
        "code": "Hello test",
        "coupon_type": 2,
        "coupon_type_id": 18
      };
      var res = await httpClient.couponApply(data);
      if (couponController.text.toLowerCase() == "excode") {
        couponPercentage.value = 10;
      }
    }

    void getPlansList() async {
      ready.value = false;
      Map res = await httpClient.getPlansList();
      print('plan list =---> $res');
      if (res['code'] == 200) {
        List temp = res['data'];
        if (authUser.user['trial_used'] == true) {
          temp.removeWhere((element) => element['price'] == 0);
        }

        plansList.value = temp;
      } else {
        print(res);
      }
      ready.value = true;
    }

    double getPlanPrice(Map plan) {
      double price = double.parse(plan['price'].toString());
      if (plan['discounted']) {
        price = price - (price * plan['discounted_percentage'] / 100);
      }
      return price;
    }

    void subscribeNow(Map plan) async {
      ready.value = false;
      Map durationsMap = {'month': 1, 'year': 12, 'lifetime': 9999};
      int durationAmountMultiplier = durationsMap[plan['duration_unit']];
      int months = plan['duration_amount'] * durationAmountMultiplier;

      Map res = await httpClient.subscribeNow({
        'months': months,
        'user_id': authUser.id,
        'amount': getPlanPrice(plan)
      });
      print('printing price ${getPlanPrice(plan)}');
      print(res);
      if (res['code'] == 200) {
        print(res['data']['url']);
        await launchUrl(Uri.parse(res['data']['url']),
            mode: LaunchMode.externalApplication);
        check.value = true;
      } else {
        print(res);
      }
      ready.value = true;
    }

    void confirmAndPay(Map plan) async {
      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
      } else {
        print(res);
      }

      Get.defaultDialog(
          radius: 8,
          title: '',
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          content: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PURCHASE SUMMARY",
                    style: TypographyStyles.boldText(
                      16,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade100
                          : colors.Colors().lightBlack(1),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected Plan',
                        style: TypographyStyles.normalText(
                            16, Themes.mainThemeColorAccent.shade300),
                      ),
                      Text(
                        '${plan['name']}',
                        style: TypographyStyles.boldText(
                          16,
                          Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade100
                              : colors.Colors().lightBlack(1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Divider(
                    thickness: 1,
                    color:
                        Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total To be Paid',
                        style: TypographyStyles.normalText(
                            16, Themes.mainThemeColorAccent.shade300),
                      ),
                      Text(
                        'MVR ${getPlanPrice(plan) - couponValue.value}',
                        style: TypographyStyles.boldText(
                          16,
                          Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade100
                              : colors.Colors().lightBlack(1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(
                    thickness: 1,
                    color:
                        Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
                  ),

                  SizedBox(height: 30),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'By clicking Pay with Card, you are agreeing to our ',
                      style: TypographyStyles.normalText(
                        12,
                        Get.isDarkMode
                            ? Themes.mainThemeColorAccent.shade100
                            : colors.Colors().lightBlack(1),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TypographyStyles.normalText(
                              12, Themes.mainThemeColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(Uri.parse(
                                'https://northstar.mv/terms-conditions/')),
                        ),
                        TextSpan(
                          text: " & ",
                          style: TypographyStyles.normalText(
                              12,
                              Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade100
                                  : colors.Colors().lightBlack(1)),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TypographyStyles.normalText(
                              12, Themes.mainThemeColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(Uri.parse(
                                'https://northstar.mv/privacy-policy')),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextField(
                  //         readOnly: couponPercentage.value>0,
                  //         controller: couponController,
                  //         decoration: InputDecoration(
                  //           label: Text("Coupon Code"),
                  //           hintText: "EXCODE",
                  //         ),
                  //
                  //       ),
                  //     ),
                  //     SizedBox(width: 10,),
                  //     Container(height:48,child: ElevatedButton(onPressed: applyCoupon, child: Text(couponPercentage.value>0?"clear":"apply",style: TextStyle(
                  //       color: Color(0xFF1B1F24),
                  //       fontSize: 20,
                  //       fontFamily: 'Bebas Neue',
                  //       fontWeight: FontWeight.w400,
                  //       height: 0,
                  //     ),),))
                  //   ],
                  // ),
                  CouponApply(
                      type: 1, typeId: plan['id'], couponValue: couponValue)
                ],
              )),
          actions: [
            Container(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () async {
                  print(_current.value);
                  print(plansList[_current.value]);
                  if (plansList[_current.value]['real_price'] / 100 <=
                      walletData['balance']) {
                    List temp = [];
                  } else {
                    showSnack('Insufficient Balance',
                        'You do not have sufficient balance to pay for this booking.');
                  }
                },
                style:
                    ButtonStyles.matButton(Themes.mainThemeColor.shade500, 0),
                child: Obx(() => ready.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pay with eWallet',
                              style:
                                  TypographyStyles.boldText(16, Colors.black),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              '(eWallet Balance: ${walletData['balance'].toStringAsFixed(2)})',
                              style:
                                  TypographyStyles.normalText(13, Colors.black),
                            ),
                          ],
                        ),
                      )
                    : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              width: Get.width,
              padding: EdgeInsets.only(top: 3),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  subscribeNow(plan);
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
                              Text(
                                'Pay with Card',
                                style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontSize: 20,
                                  fontFamily: 'Bebas Neue',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              )
                            ]),
                      )
                    : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              height: 48,
              width: Get.width,
              child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TypographyStyles.boldText(
                      14,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade100
                          : colors.Colors().lightBlack(1),
                    ),
                  )),
            ),
            SizedBox(height: 5),
          ]);
    }

    void verifyAndGoHome() async {
      ready.value = false;
      Map res = await httpClient.getMyProfile();
      if (res['code'] == 200) {
        print(res['data']['subscription']);

        if (authUser.role == 'client') {
          authUser.saveUser(res['data']['user']);
        } else {
          authUser.saveUser(res['data']);
        }
        if (res['data']['subscription'] != null) {
          DateTime expDate =
              DateTime.parse(res['data']['subscription']['valid_till']);
          if (expDate.isBefore(DateTime.now())) {
            print('Subscription expired');
            check.value = false;
            showSnack('No Subscription Found or Payment Not Verified Yet!',
                'If you just purchased the Pro Version please await for the Bank to Verify the Payment!');
          } else {
            print('Subscription valid');
            Get.offAll(() => Layout());
            showSnack('Pro Version Unlocked!',
                'You have successfully subscribed to the Pro version.');
            Get.defaultDialog(
                radius: 8,
                title: 'Pro Version Unlocked!',
                content: Text(
                    'You have successfully subscribed to the Pro version.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('OK')),
                ]);
          }
        } else {
          check.value = false;
          showSnack('No Subscription Found or Not Verified Yet!',
              'If you just purchased the Pro Version please await for the Bank to Verify the Payment!');
        }
      } else {
        print(res);
        showSnack('Something went wrong!', 'Please contact support.');
      }
      ready.value = true;
    }

    void activateFreeTrial() async {
      ready.value = false;
      Map res = await httpClient.activateFreeTrail();
      if (res['code'] == 200) {
        verifyAndGoHome();
      } else {
        print(res);
      }
      ready.value = true;
    }

    //checkIfUsedFreeTrial();

    getPlansList();

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Obx(() => check.value
                ? Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFFFDB800),
                              Color(0xFFF38F00),
                            ],
                          ),
                        ),
                        child: MaterialButton(
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Verify Payment',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () async {
                            verifyAndGoHome();
                          },
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 3),
                              height: 370,
                              viewportFraction: 1.0,
                              onPageChanged: (index, reason) {
                                _current.value = index;
                              },
                            ),
                            items: _proList.list.map((Pro slide) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Image.asset(
                                        "${slide.image}",
                                        fit: BoxFit.fitWidth,
                                        height: 230,
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        slide.feature,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        slide.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Get.isDarkMode
                                                    ? Colors.white70
                                                    : Colors.grey[500]),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 50,
                                      ),
                                    ],
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _proList.list.map((Pro slide) {
                                return Container(
                                  width: 9.0,
                                  height: 9.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    color: _current.value ==
                                            _proList.list.indexOf(slide)
                                        ? colors.Colors().deepYellow(1)
                                        : Get.isDarkMode
                                            ? Colors.white12
                                            : Colors.grey[300],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Obx(() => ready.value
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: plansList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Obx(() => ElevatedButton(
                                          style: selectedPackage.value == index
                                              ? ButtonStyles.selectedButton()
                                              : ButtonStyles
                                                  .notSelectedButton(),
                                          child: Padding(
                                            padding: index == 0
                                                ? EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                    vertical: 10)
                                                : EdgeInsets.symmetric(
                                                    horizontal: 18),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  plansList[index]['name'],
                                                  textAlign: TextAlign.left,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge!
                                                      .copyWith(fontSize: 16),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        plansList[index]
                                                                ['discounted']
                                                            ? Text(
                                                                'MVR ${plansList[index]['price']}',
                                                                style: TextStyle(
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    color: Colors
                                                                        .orange,
                                                                    fontSize:
                                                                        12))
                                                            : SizedBox(),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'MVR ${getPlanPrice(plansList[index])}',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelLarge!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          16),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Visibility(
                                                      child: Chip(
                                                        label: Text(
                                                          plansList[index]
                                                                  ['discounted']
                                                              ? 'Save ${plansList[index]['discounted_percentage']}%'
                                                              : '',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .labelLarge!
                                                              .copyWith(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                        backgroundColor:
                                                            colors.Colors()
                                                                .deepYellow(1),
                                                        padding:
                                                            EdgeInsets.zero,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        labelPadding: EdgeInsets
                                                            .symmetric(
                                                                vertical: -7,
                                                                horizontal: 10),
                                                      ),
                                                      visible: plansList[index]
                                                          ['discounted'],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          onPressed: () {
                                            selectedPackage.value = index;
                                          },
                                        )),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                );
                              },
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colors.Colors().deepYellow(1)),
                              ),
                            )),
                      Visibility(
                        visible: !check.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                  visible: couponPercentage.value > 0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Coupon Applied",
                                          style: TypographyStyles.text(16),
                                        ),
                                        Text("10% Discount",
                                            style: TypographyStyles.title(16)),
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFFFDB800),
                                      Color(0xFFF38F00),
                                    ],
                                  ),
                                ),
                                child: MaterialButton(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17,
                                  ),
                                  minWidth: double.infinity,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    child: Obx(() => ready.value
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/crown.png',
                                                height: 30,
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Text(
                                                extend ? 'EXTEND' : 'UPGRADE',
                                                textAlign: TextAlign.left,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge!
                                                    .copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )),
                                  ),
                                  onPressed: () async {
                                    if (plansList[selectedPackage.value]
                                            ['price'] >
                                        0) {
                                      couponValue.value = getPlanPrice(
                                              plansList[
                                                  selectedPackage.value]) *
                                          couponPercentage.value /
                                          100;
                                      confirmAndPay(
                                          plansList[selectedPackage.value]);
                                    } else {
                                      CommonConfirmDialog.confirm(
                                              'Activate Free Trial')
                                          .then((value) {
                                        activateFreeTrial();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ))),
      ),
      // bottomNavigationBar: SingleChildScrollView(
      //   child: Obx(() => ),
      // ),
    );
  }
}

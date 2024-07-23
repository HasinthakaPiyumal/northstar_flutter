import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/TaxController.dart';
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
import 'package:north_star/components/MaterialBottomSheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/Buttons.dart';
import '../../components/CouponApply.dart';
import '../SharedWidgets/PaymentSummary.dart';
import '../SharedWidgets/PaymentVerification.dart';
import 'PurchaseSummary.dart';

class HomeWidgetPro extends StatelessWidget {
  HomeWidgetPro({Key? key, this.extend = false}) : super(key: key);
  final bool extend;

  @override
  Widget build(BuildContext context) {
    print(extend);
    RxList plansList = [].obs;
    final ScrollController scrollController = ScrollController();

    RxInt _current = 0.obs;
    RxBool ready = true.obs;
    RxMap walletData = {}.obs;
    RxBool check = false.obs;
    ProList _proList = ProList();
    RxInt selectedPackage = 0.obs;
    RxBool isAgree = false.obs;

    RxString currentTransactionId = "".obs;

    RxDouble couponValue = 0.0.obs;
    RxString couponCode = "--".obs;

    void scrollTOBottom(){
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
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
      double price = double.parse(plan['real_price'].toString());
      // if (plan['discounted']) {
      //   price = price - (price * plan['discounted_percentage'] / 100);
      // }
      return price;
    }
    DateTime addTimeUnitToDate(DateTime date, int amount, String unit) {
      switch (unit) {
        case 'day':
          return date.add(Duration(days: amount));
        case 'month':
          int year = date.year + (date.month + amount) ~/ 12;
          int month = (date.month + amount) % 12;
          int day = date.day;
          int daysInMonth = DateTime(year, month + 1, 0).day;
          if (day > daysInMonth) {
            day = daysInMonth;
          }
          return DateTime(year, month, day, date.hour, date.minute, date.second,
              date.millisecond, date.microsecond);
        case 'year':
          return DateTime(date.year + amount, date.month, date.day, date.hour,
              date.minute, date.second, date.millisecond, date.microsecond);
        default:
          throw ArgumentError('Invalid unit. Must be "day", "month", or "year".');
      }
    }

    void showPurchaseSummary(onSuccess,type){
      dynamic plan = plansList[selectedPackage.value];
      var formatter = DateFormat('yyyy-MM-dd');
      String valid = authUser.user['subscription']!=null?authUser.user['subscription']['valid_till']:formatter.format(DateTime.now().toLocal());
      var data = {
        "plan_name":plan['name'],
        "price":getPlanPrice(plan).toStringAsFixed(2),
        "pay_type":type,
        "discount_percentage":((couponValue.value)/getPlanPrice(plan)*100).toStringAsFixed(2),
        "discount_amount":(getPlanPrice(plan)-couponValue.value).toStringAsFixed(2),
        "tax":(type==2?0:taxController.getCalculatedTax(getPlanPrice(plan) - couponValue.value)).toStringAsFixed(2),
        "total":(getPlanPrice(plan) - couponValue.value + (type==2?0:taxController.getCalculatedTax(getPlanPrice(plan) - couponValue.value))).toStringAsFixed(2),
        "validation":plan['duration_unit']=='lifetime'?'Life Time':"${plan['duration_amount']} ${plan['duration_unit']}",
        "starting_date":valid,
        "expire_date":plan['duration_unit']=='lifetime'?'Life Time':formatter.format(addTimeUnitToDate(DateTime.parse(valid),plan['duration_amount'],plan['duration_unit']).toLocal()).toString(),
      };
      Get.to(()=>PurchaseSummary(onSuccess: onSuccess, data: data,));
    }

    void subscribeNow(Map plan, VoidCallback callback) async {
      print("subscribeNow calling");
      ready.value = false;
      Map durationsMap = {'month': 1, 'year': 12, 'lifetime': 9999};
      int durationAmountMultiplier = durationsMap[plan['duration_unit']];
      int months = plan['duration_amount'] * durationAmountMultiplier;
      var data = {
        'planId':plansList[selectedPackage.value]['id'],
        'couponCode': '${couponCode.value}',
        'payment_type':1
      };
      Map res = await httpClient.proMemberActivate(data);
      // Map res = await httpClient.subscribeNow({
      //   'months': months,
      //   'user_id': authUser.id,
      //   'planId':plansList[_current.value]['id'],
      //   'amount': getPlanPrice(plan) - couponValue.value + taxController.getCalculatedTax(getPlanPrice(plan) - couponValue.value)
      // });
      print('printing price ${getPlanPrice(plan)}');
      print(res);
      if (res['code'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        callback();
        Get.to(()=>PaymentVerification());
        // check.value = true;
      } else {
        print(res);
        callback();
        showSnack("Booking Failed",res['data']['message'] );
      }
      ready.value = true;
    }

    void validateAndGo(Map plan){

      dynamic plan = plansList[selectedPackage.value];
      var formatter = DateFormat('yyyy-MM-dd');
      String valid = authUser.user['subscription']!=null?authUser.user['subscription']['valid_till']:formatter.format(DateTime.now().toLocal());
      var data = {
        "plan_name":plan['name'],
        "price":getPlanPrice(plan).toStringAsFixed(2),
        "discount_percentage":((couponValue.value)/getPlanPrice(plan)*100).toStringAsFixed(2),
        "discount_amount":(getPlanPrice(plan)-couponValue.value).toStringAsFixed(2),
        "validation":plan['duration_unit']=='lifetime'?'Life Time':"${plan['duration_amount']} ${plan['duration_unit']}",
        "starting_date":valid,
        "expire_date":plan['duration_unit']=='lifetime'?'Life Time':formatter.format(addTimeUnitToDate(DateTime.parse(valid),plan['duration_amount'],plan['duration_unit']).toLocal()).toString(),
      };
      Widget headerWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Get.isDarkMode?AppColors.primary2Color:Colors.white,borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Plan",style: TypographyStyles.title(16),),
              SizedBox(height: 10,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Plan Name",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text(data['plan_name'],style:TypographyStyles.text(16))]),
              SizedBox(height: 8,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Plan Validation",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text(data['validation'],style:TypographyStyles.text(16))]),
              SizedBox(height: 8,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Starting Date",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text(data['starting_date'],style:TypographyStyles.text(16))]),
              SizedBox(height: 8,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Expire Date",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text(data['expire_date'],style:TypographyStyles.text(16))]),
            ],
          ),),
      );

      Get.to(()=>PaymentSummary(
        orderDetails: [
           SummaryItem(head: 'Plan Price',value: "MVR ${data['price']}",),
        ],
        total: getPlanPrice(plan),//storeHelper.getCartTotal(),
        payByCard: (){subscribeNow(plan,(){});},
        payByWallet: ()async{
          var data = {
            'planId': plansList[selectedPackage.value]['id'],
            'couponCode': '${couponCode.value}',
            'payment_type': 2
          };
          Map res = await httpClient.proMemberActivate(data);
          print(res);
          if (res['code'] == 200) {
            Get.to(() => Layout());
            showSnack('Successfully Subscribed',
                'You have successfully upgraded your membership plan.');
          } else {
            showSnack('Error', 'Something went wrong.');
          }
        },
        headerWidget:headerWidget ,
        isCouponAvailable: true,
      ));
    }

    void confirmAndPay(Map plan) async {
      Map res = await httpClient.getWallet();
      print(plan);

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
                        'Discount',
                        style: TypographyStyles.normalText(
                            16, Themes.mainThemeColorAccent.shade300),
                      ),
                      Text(
                        'MVR ${couponValue.value}',
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
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: (){
                      isAgree.value = !isAgree.value;
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(value: isAgree.value, onChanged: (val){
                          isAgree.value = val!;
                        },splashRadius: 20,),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              text:
                                  'You are agreeing to our ',
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CouponApply(
                      type: 1,
                      typeId: plan['id'],
                      couponCode: couponCode,
                      couponValue: couponValue,
                      payingAmount: getPlanPrice(plan))
                ],
              )),
          actions: [
            Container(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () async {
                  if(!isAgree.value){
                    showSnack('Terms and Conditions','Please accept the terms and conditions.');
                    return;
                  }
                  if (plansList[selectedPackage.value]['real_price']-couponValue.value <=
                      walletData['balance']) {
                        showPurchaseSummary((VoidCallback callback)async{
                          var data = {
                            'planId': plansList[selectedPackage.value]['id'],
                            'couponCode': '${couponCode.value}',
                            'payment_type': 2
                          };
                          Map res = await httpClient.proMemberActivate(data);
                          print(res);
                          if (res['code'] == 200) {
                            callback();
                            Get.to(() => Layout());
                            showSnack('Successfully Subscribed',
                                'You have successfully upgraded your membership plan.');
                          } else {
                            callback();
                            showSnack('Error', 'Something went wrong.');
                          }
                        }, 2);
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
                              'Pay with E-gift',
                              style:
                                  TypographyStyles.boldText(16, Colors.black),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              '(E-gift Balance: ${walletData['balance'].toStringAsFixed(2)})',
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
                  if(!isAgree.value){
                    showSnack('Terms and Conditions','Please accept the terms and conditions.');
                    return;
                  }
                  Get.back();
                  showPurchaseSummary((VoidCallback callback){subscribeNow(plan,callback);},1);
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
                                    'Tax amount: MVR ${(taxController.getCalculatedTax(getPlanPrice(plan) - couponValue.value)).toStringAsFixed(2)}',
                                    style: TypographyStyles.text(10),
                                  )
                                ],
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

    void verifyAndGoHome({bool trial = false}) async {
      ready.value = false;
      print("paymentStatus out");
      if(!trial){
        Map paymentStatus = await httpClient.paymentVerify(currentTransactionId.value);
        print("paymentStatus");
        print(paymentStatus);
        if(paymentStatus['code']!=200){
          showSnack('Payment Not Verified Yet!',
              'If you just purchased the Pro Version please await for the Bank to Verify the Payment!');
          return;
        }else{
          if(!paymentStatus['data']['confirmed']) {
            showSnack('Payment Not Verified Yet!',
                'If you just purchased the Pro Version please await for the Bank to Verify the Payment!');
            return;
          }
        }
      }
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
        verifyAndGoHome(trial:true);
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
        controller: scrollController,
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
                                                Expanded(
                                                  child: Text(
                                                    plansList[index]['name'],
                                                    textAlign: TextAlign.left,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge!
                                                        .copyWith(fontSize: 16),
                                                  ),
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
                                                                'MVR ${plansList[index]['price']*plansList[index]['duration_amount']}',
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
                                                          'MVR ${plansList[index]['real_price']}',
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
                                            scrollTOBottom();
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
                                child: Buttons.yellowTextIconButton(
                                  label:extend ? 'EXTEND' : 'UPGRADE',
                                  onPressed: () async {
                                    if (plansList[selectedPackage.value]
                                            ['price'] >
                                        0) {
                                      validateAndGo(
                                          plansList[selectedPackage.value]);
                                    } else {
                                      CommonConfirmDialog.confirm(
                                              'Activate Free Trial')
                                          .then((value) {
                                        activateFreeTrial();
                                      });
                                    }
                                  },
                                    icon: Icons.accessibility_new_outlined,
                                  svg:'assets/svgs/upgrade.svg',
                                  width: Get.width
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

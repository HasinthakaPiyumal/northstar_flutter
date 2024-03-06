import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/CircularProgressBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../Models/HttpClient.dart';
import '../../components/Buttons.dart';
import '../Layout.dart';

class PaymentVerification extends StatefulWidget {
  const PaymentVerification();

  @override
  State<PaymentVerification> createState() => _PaymentVerificationState();
}

class _PaymentVerificationState extends State<PaymentVerification> {
  late Timer timer1;
  late Timer timer2;
  @override
  void dispose() {
    // TODO: implement dispose
    timer1.cancel();
    timer2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RxString transactionId = "".obs;
    RxString transactionUrl = "".obs;

    const int timeOutSeconds = 20;

    RxInt seconds = timeOutSeconds.obs;
    RxBool isReady = false.obs;
    RxBool isConfirmed = false.obs;

    void checkPayment({bool notify = false}) async {
      isReady.value = false;
      Map res = await httpClient.paymentVerify(transactionId.value);
      print('print paymentStatus');
      print(res);
      if (res['code'] == 200) {
        isReady.value = true;
        isConfirmed.value = res['data']['confirmed'];
        if(isConfirmed.value){
          Future.delayed(Duration(seconds: 2),()=>Get.offAll(Layout()));
        }
        if (notify) {
          showSnack(
              "Payment Status",
              isConfirmed.value
                  ? "Payment completed successfully"
                  : "Payment is still pending");
        }
      } else {
        isReady.value = true;
        Get.back();
        showSnack("Something Went Wrong", res['data']['error']);
      }
    }

    void startTimer() {
      checkPayment();
      timer1 = Timer.periodic(Duration(seconds: timeOutSeconds + 1), (timer) {
        seconds.value = timeOutSeconds + 1;
        checkPayment();
      });
      timer2 = Timer.periodic(Duration(seconds: 1), (timer) {
        seconds.value = seconds.value - 1;
        if(isConfirmed.value){
          timer1.cancel();
          timer2.cancel();
        }
      });
    }

    void getTransaction() async {
      isReady.value = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      transactionId.value = prefs.getString("lastTransactionId")!;
      transactionUrl.value = prefs.getString("lastTransactionUrl")!;
      if(transactionId.value.isEmpty || transactionUrl.value.isEmpty){
        showSnack("Something went wrong", "Something went wrong. Please try again shortly.");
        return;
      }
      await launchUrlString(transactionUrl.value);
      startTimer();
      isReady.value = true;
    }

    getTransaction();
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Payment"),
      ),
      body: Obx(() => isReady.value
          ? isConfirmed.value
              ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lotties/payment_done.json',
                          repeat: false),
                      Text(
                        "Payment Success",
                        style: TypographyStyles.title(20),
                      ),
                      SizedBox(height: 40,)
                    ],
                  ),
              )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        
                        height: 270,
                        width: Get.width - 40,
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                            color: Get.isDarkMode
                            ? AppColors.primary2Color
                            : Colors.white),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                  'assets/lotties/processing_payment.json',
                                  width: 150),
                              // SizedBox(height: 20,),
                              Text(
                                "Waiting for your Payment",
                                style: TypographyStyles.title(20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '#${transactionId.value}',
                                style: TextStyle(
                                    color: AppColors.accentColor,
                                    decoration: TextDecoration.underline),
                              )
                            ]),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Auto-check payment in a few seconds",
                        style: TypographyStyles.text(14),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: (timeOutSeconds - seconds.value) /
                                  timeOutSeconds,
                              strokeWidth: 8.0,
                              backgroundColor: Color(0x1167FB7F),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF67FB7F)),
                            ),
                          ),
                          Obx(() => Container(
                                width: 100,
                                height: 100,
                                child: Center(
                                  child: Text(
                                    seconds.value.toString(),
                                    style: TypographyStyles.title(30),
                                  ),
                                ),
                              )),
                        ],
                      )
                    ],
                  ),
                )
          : LoadingAndEmptyWidgets.loadingWidget()),
      bottomNavigationBar: Obx(
        () => Visibility(
          visible: isReady.value && !isConfirmed.value,
          child: Padding(
            padding: EdgeInsets.fromLTRB(36, 5, 36, 15),
            child:
                Buttons.yellowFlatButton(onPressed: () {checkPayment(notify: true);}, label: "Verify Now",isLoading: !isReady.value),
          ),
        ),
      ),
    );
  }
}

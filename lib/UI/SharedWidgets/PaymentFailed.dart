import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/components/Buttons.dart';

class PaymentFailed extends StatelessWidget {
  const PaymentFailed();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Unsuccessful"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16),
              child: Lottie.asset(
                'assets/lotties/payment-failed.json',
                // Replace with your animation file path
                width: Get.width,
                fit: BoxFit.fill,
              ),
            ),
            Text(
              "Ohh No\nSomething Went Wrong",
              style: TypographyStyles.title(20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            Text(
              "We aren’t able to process your payment. Please try again.",
              style: TypographyStyles.text(14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40,),
            Buttons.outlineButton(onPressed: (){Get.back();},label: "Close",width: Get.width)
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/MaterialBottomSheet.dart';

import 'Buttons.dart';

class CouponApply extends StatelessWidget {
  int type = 1;
  int typeId = 0;
  RxString couponCode = "".obs;
  RxDouble couponValue = 0.0.obs;
  dynamic payingAmount = 0;

  CouponApply(
      {required this.type,
      required this.typeId,
      required this.couponValue,
      required this.payingAmount, required this.couponCode});

  TextEditingController coupon = new TextEditingController();

  FocusNode couponFn = FocusNode();

  void apply() async {
    var data = {
      "code": coupon.text,
      "coupon_type": type,
      "coupon_type_id": typeId
    };
    dynamic response = await httpClient.couponApply(data);

    print(data);
    print(response);
    if (response['code'] == 200) {
      if (response['data'] != null) {
        double couponPercentage = double.parse(
            (response['data']['discount_percentage']).toStringAsFixed(2));
        double maximumSaving = double.parse(
            (response['data']['max_value']).toStringAsFixed(2));
        double saving = double.parse((payingAmount * couponPercentage/100).toStringAsFixed(2));
        if(saving>maximumSaving){
          saving = maximumSaving;
        }
        couponValue.value = saving;
        couponCode.value = response['data']['code'];
        print(couponValue.value);
        Get.back();
        showSnack("Success", 'Successfully applied coupon');
      }
    } else {
      showSnack("Coupon Error", '${response['data'][0]['message']}');
      return;
    }
  }

  void open() {
    MaterialBottomSheet(
      "Apply Coupon",
      child: Column(
        children: [
          TextField(
            controller: coupon,
            focusNode: couponFn,
            decoration: InputDecoration(
                labelText: 'Coupon',
                prefixIcon: Icon(Icons.confirmation_number)),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Buttons.outlineButton(
                    onPressed: () {
                      Get.back();
                    },
                    label: "Cancel"),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Buttons.yellowFlatButton(
                    onPressed: () {
                      apply();
                    },
                    label: "Apply"),
              ),
            ],
          ),
        ],
      ),
    );
    Future.delayed(Duration(milliseconds: 100), () {
      couponFn.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Buttons.yellowTextIconButton(
        icon: couponValue.value > 0 ?Icons.clear:Icons.confirmation_number,
        backgroundColor: couponValue.value > 0 ?Colors.redAccent:AppColors.accentColor ,
        textColor: couponValue.value > 0 ?Colors.white:AppColors.textOnAccentColor,
        onPressed: () {
          couponValue.value > 0 ? couponValue.value = 0:open() ;
        },
        label: couponValue.value > 0 ? "Remove coupon" : "Apply Coupon",
        width: Get.width);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/MaterialBottomSheet.dart';

import 'Buttons.dart';

class CouponApply extends StatelessWidget {
  int type = 1;
  int typeId = 0;
  RxDouble couponValue = 0.0.obs;
  CouponApply({required this.type,required this.typeId,required this.couponValue});
  TextEditingController coupon = new TextEditingController();

  FocusNode couponFn = FocusNode();

  void apply() async {
    var data = {
      "code": coupon.text,
      "coupon_type": type,
      "coupon_type_id":typeId
    };
    dynamic response = await httpClient.couponApply(data);

    print(data);
    print(response);
    if(response['code']==200){
      if(response['data'][0]['status']){
        showSnack("Success", 'Successfully applied coupon');
      }
    }else{
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
              prefixIcon: Icon(Icons.confirmation_number)
            ),
          ),
          SizedBox(height: 20,),
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
        icon: Icons.confirmation_number,
        onPressed: () {
          open();
        },
        label: "Apply Coupon",
        width: Get.width);
  }
}

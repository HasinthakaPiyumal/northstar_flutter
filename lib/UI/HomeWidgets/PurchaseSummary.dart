import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import '../../components/Buttons.dart';

typedef Callback = void Function(VoidCallback);
class PurchaseSummary extends StatelessWidget {
  final Callback onSuccess;
  final Map data;
  const PurchaseSummary({required this.onSuccess,required this.data});

  @override
  Widget build(BuildContext context) {
    RxBool isReady = true.obs;
    return Scaffold(
      appBar: AppBar(title: Text("Purchase Summary"),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Get.isDarkMode?AppColors.primary2Color:Colors.white,borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Choose Plan",style: TypographyStyles.title(16),),
                  SizedBox(height: 10,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Plan Type",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text("${data['plan_name']}",style:TypographyStyles.text(16))]),
                  SizedBox(height: 8,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Amount",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text("MVR ${data['price']}",style:TypographyStyles.text(16))]),
                  ],
              ),),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Get.isDarkMode?AppColors.primary2Color:Colors.white,borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payment Details",style: TypographyStyles.title(16),),
                  SizedBox(height: 10,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Payment Method",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text(data['pay_type']==1?"Card Payment":"E-Wallet",style:TypographyStyles.text(16))]),
                  SizedBox(height: 8,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Discount Amount(${data['discount_percentage']}%)",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text("MVR ${data['discount_amount']}",style:TypographyStyles.text(16))]),
                  SizedBox(height: 8,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Tax",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text("MVR ${data['tax']}",style:TypographyStyles.text(16))]),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Total",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text("MVR ${data['total']}",style:TypographyStyles.text(16))]),
                  ],
              ),),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Get.isDarkMode?AppColors.primary2Color:Colors.white,borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Plan Validation",style: TypographyStyles.title(16),),
                  SizedBox(height: 10,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Plan Validation",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text(data['validation'],style:TypographyStyles.text(16))]),
                  SizedBox(height: 8,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Starting Date",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text(data['starting_date'],style:TypographyStyles.text(16))]),
                  SizedBox(height: 8,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text("Expire Date",style: TextStyle(fontSize: 16,color: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5))),Text(data['expire_date'],style:TypographyStyles.text(16))]),
                  ],
              ),),
            ]
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(()=> Buttons.yellowFlatButton(onPressed: (){isReady.value=false;onSuccess((){isReady.value=true;});},label: 'Purchase now',isLoading: isReady.isFalse)),
      ),
    );
  }
}

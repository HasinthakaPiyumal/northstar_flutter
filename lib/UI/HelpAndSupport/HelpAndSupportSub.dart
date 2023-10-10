import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'HelpAndSupportView.dart';
import 'ListItem.dart';

class HelpAndSupportSub extends StatelessWidget {
  const HelpAndSupportSub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("account and payment option".capitalize as String),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select your issue',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6399999856948853),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              SizedBox(height: 16,),
              ListItem(text: "account and payment option",onTap: (){Get.to(()=>HelpAndSupportView());},),
              ListItem(text: "billing statement",onTap: (){Get.to(()=>HelpAndSupportView());},),
              ListItem(text: "subscription plan",onTap: (){Get.to(()=>HelpAndSupportView());},),
              ListItem(text: "free trial and promotions",onTap: (){Get.to(()=>HelpAndSupportView());},),
              ListItem(text: "billing support contact",onTap: (){Get.to(()=>HelpAndSupportView());},)
            ],
          ),
        ),
      ),
    );
  }
}

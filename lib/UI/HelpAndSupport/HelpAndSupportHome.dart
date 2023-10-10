import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/UI/HelpAndSupport/HelpAndSupportSub.dart';

import 'ListItem.dart';

class HelpAndSupportHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help And Support'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListItem(text: "account and payment option",onTap: (){Get.to(()=>HelpAndSupportSub());},),
              ListItem(text: "getting started",onTap: (){Get.to(()=>HelpAndSupportSub());},),
              ListItem(text: "Troubleshooting and Technical Issues",onTap: (){Get.to(()=>HelpAndSupportSub());},),
              ListItem(text: "Billing and Subscription",onTap: (){Get.to(()=>HelpAndSupportSub());},),
              ListItem(text: "Privacy and Security",onTap: (){Get.to(()=>HelpAndSupportSub());},)
            ],
          ),
        ),
      ),
    );
  }
}

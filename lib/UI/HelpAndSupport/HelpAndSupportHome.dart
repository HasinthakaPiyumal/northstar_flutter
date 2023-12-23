import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/UI/HelpAndSupport/HelpAndSupportSub.dart';

import 'ListItem.dart';

class HelpAndSupportHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RxList faq = [].obs;
    void getFaqs() async {
      Map res = await httpClient.getFaqs();
      print(res);
      if(res['code']==200){
        faq.value = res['data'];
      }
    }

    getFaqs();
    return Scaffold(
      appBar: AppBar(
        title: Text('Help And Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => ListView.builder(
            itemCount: faq.length,
            itemBuilder: (BuildContext context, int index) {
              return ListItem(
                  text: faq[index]['title'],
                  onTap: () {
                    Get.to(() => HelpAndSupportSub(faq[index]));
                  });
            })),
      ),
    );
  }
}

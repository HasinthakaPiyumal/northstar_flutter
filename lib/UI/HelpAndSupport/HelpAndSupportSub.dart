import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'HelpAndSupportView.dart';
import 'ListItem.dart';

class HelpAndSupportSub extends StatelessWidget {
  final faq;
  HelpAndSupportSub(this.faq, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List subFaq = faq['subfaq'];
    return Scaffold(
      appBar: AppBar(
        title: Text('${faq['title'].toString().capitalize  }'),
      ),
      body: Padding(
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
            Expanded(
              child: ListView.builder(
                  itemCount: subFaq.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListItem(
                        text: subFaq[index]['title'],
                        onTap: () {
                          Get.to(() => HelpAndSupportView(subFaq[index]));
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }
}

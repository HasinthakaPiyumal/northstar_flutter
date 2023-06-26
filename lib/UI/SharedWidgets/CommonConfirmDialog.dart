import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonConfirmDialog {

  static Future<bool> confirm(String reason) async{
    bool status = false;
    await Get.defaultDialog(
      radius: 6,
      title: 'Confirm Action',
      content: Text('Are you sure you want to $reason?',
        textAlign: TextAlign.justify,
      ),
      titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: (){
              status = false;
              Get.back();
            }, child: Text('Cancel')),
            TextButton(onPressed: (){
              status = true;
              Get.back();
            }, child: Text('${reason.capitalizeFirst}')),
          ],
        )
      ]
    );

    return status;

  }
}

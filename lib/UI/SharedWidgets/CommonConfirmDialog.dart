import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';

import '../../components/Buttons.dart';

class CommonConfirmDialog {

  static Future<bool> confirm(String reason,{bool isSameButton = true,String buttonText = ''}) async{
    bool status = false;
    await Get.defaultDialog(
      radius: 6,
      title: 'Confirm Action',
      content: Column(
        children: [
          Text('Are you sure you want to $reason?',
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ButtonStyles.primaryButton(),
                    onPressed: (){
                      status = true;
                      Get.back();
                    }, child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('${isSameButton?reason.capitalizeFirst:buttonText}'),
                )),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                    style: ButtonStyles.primaryOutlineButton(),
                    onPressed: (){
                      status = false;
                      Get.back();
                    },child: Text("Cancel")),
              )
            ],
          )
        ],
      ),
      backgroundColor: AppColors.primary2Color,
      titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),

    );

    return status;

  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import 'Buttons.dart';

class ConfirmDialogs{
  ConfirmDialogs({required String buttonLabel,required String action,required VoidCallback onPressed }){
    Get.defaultDialog(title: "Confirm Your Action",radius: 10,
        contentPadding:EdgeInsets.symmetric(horizontal: 16),
        content: Column(
      children: [
        SizedBox(height: 10,),
        Text("are you sure want to $action".capitalize as String,style: TypographyStyles.textWithWeight(14, FontWeight.w300),),
        SizedBox(height: 20,),
        Row(children: [
          Expanded(child: Buttons.outlineButton(onPressed: (){Get.back();},label: "Cancel")),
          SizedBox(width: 10,),
          Expanded(child: Buttons.yellowFlatButton(onPressed: onPressed,label: buttonLabel))
        ],),
      ],
    ));
  }
}
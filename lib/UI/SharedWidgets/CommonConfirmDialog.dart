import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import '../../components/Buttons.dart';

class CommonConfirmDialog {
  static Future<bool> confirm(String reason,
      {bool isSameButton = true,
      String buttonText = '',
      String hintText = '',
      String message = ''}) async {
    bool status = false;
    await Get.defaultDialog(
      radius: 6,
      title: 'Confirm Action',
      content: Column(
        children: [
          Text(
            message == '' ? 'Are you sure you want to $reason?' : message,
            textAlign: TextAlign.justify,
          ),
          SizedBox(
            height: 10,
          ),
          Visibility(
              visible: hintText != '',
              child: Text(hintText,
                  style: TypographyStyles.text(12).copyWith(
                    color: AppColors.accentColor,
                  ),
                  textAlign: TextAlign.center)),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ButtonStyles.primaryOutlineButton(),
                    onPressed: () {
                      status = false;
                      Get.back();
                    },
                    child: Text("Cancel")),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                    style: ButtonStyles.primaryButton(),
                    onPressed: () {
                      status = true;
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                          '${isSameButton ? reason.capitalizeFirst : buttonText}'),
                    )),
              ),
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

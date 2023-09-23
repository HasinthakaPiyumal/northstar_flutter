import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import '../Styles/AppColors.dart';
import 'Buttons.dart';

class MaterialBottomSheet {
  final Widget child;
  MaterialBottomSheet(String title,{required this.child}){
    Get.bottomSheet(
      SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.only(top: 10.0),
          decoration: BoxDecoration(
            color: Get.isDarkMode?AppColors.primary2Color:Colors.white, // Replace with your desired color
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:AppColors.accentColor, // Replace with your desired color
                ),
                width: 60,
                height: 5,
              ),
              SizedBox(height: 20),
              Text(
                title.capitalize as String,
                style: TypographyStyles.title(20),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: this.child,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: true,
      persistent: false,
    );
  }
}
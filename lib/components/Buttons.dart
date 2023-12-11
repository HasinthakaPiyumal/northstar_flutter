import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';

import '../Styles/TypographyStyles.dart';

class Buttons {
  static Widget yellowFlatButton({
    String label = 'Button',
    required VoidCallback onPressed,
    double width = 264,
    double height = 44,
    String fontFamily = 'Bebas Neue',
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w400,
    Color backgroundColor = AppColors.accentColor,
    Color textColor = AppColors.textOnAccentColor,
    bool buttonFit = false
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.yellow,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Container(
            width: buttonFit?null:width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                  fontWeight: fontWeight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  static Widget yellowTextIconButton({
    String label = 'Button',
    required VoidCallback onPressed,
    double width = 264,
    double height = 44,
    String fontFamily = 'Bebas Neue',
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w400,
    Color backgroundColor = AppColors.accentColor,
    Color textColor = AppColors.textOnAccentColor,
    bool buttonFit = false,
    required IconData icon
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.yellow,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Container(
            width: buttonFit?null:width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,color:AppColors.textOnAccentColor),
                  SizedBox(width: 5,),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontFamily: fontFamily,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  static Widget outlineButton({
    String label = 'Button',
    required VoidCallback onPressed,
    double width = 264,
    double height = 42,
    Color backgroundColor = AppColors.accentColor,
    bool buttonFit = false
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: AppColors.accentColor,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          decoration: ShapeDecoration(
            // color: backgroundColor,

            shape:
                RoundedRectangleBorder(side:BorderSide(color: AppColors.accentColor,width: 2),borderRadius: BorderRadius.circular(5)),
          ),
          child: Container(
            width: buttonFit?null:width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TypographyStyles.title(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
  static Widget outlineTextIconButton({
    String label = 'Button',
    required VoidCallback onPressed,
    double width = 264,
    double height = 44,
    Color backgroundColor = AppColors.accentColor,
    bool buttonFit = false,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: AppColors.accentColor,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          decoration: ShapeDecoration(
            // color: backgroundColor,

            shape:
                RoundedRectangleBorder(side:BorderSide(color: AppColors.accentColor,width: 2),borderRadius: BorderRadius.circular(5)),
          ),
          child: Container(
            width: buttonFit?null:width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,color:Get.isDarkMode?AppColors.textColorDark:AppColors.textColorLight),
                SizedBox(width: 10,),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TypographyStyles.smallBoldTitle(20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,

  }) {
    return Material(
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onPressed,
        child: Ink(
          padding: EdgeInsets.all(10),
          decoration:
          ShapeDecoration(shape: CircleBorder(),color: AppColors.primary2Color,),
          child: Icon(
            icon,
            color: AppColors.accentColor,
          ),
        ),
      ),
    );
  }
}

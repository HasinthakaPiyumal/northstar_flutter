import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';

import '../Styles/TypographyStyles.dart';

class Buttons {
  static Widget yellowFlatButton(
      {String label = 'Button',
      required VoidCallback onPressed,
      double width = 264,
      double height = 44,
      String fontFamily = 'Bebas Neue',
      double fontSize = 20,
      FontWeight fontWeight = FontWeight.w400,
      Color backgroundColor = AppColors.accentColor,
      Color textColor = AppColors.textOnAccentColor,
      bool buttonFit = false,
      bool disabled = false,
      bool isLoading = false,
        bool useDefaultFont = false
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? () {} : onPressed,
        splashColor: disabled ? Colors.transparent : Colors.yellow,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          decoration: ShapeDecoration(
            color:
                disabled ? backgroundColor.withOpacity(0.3) : backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Container(
            width: buttonFit ? null : width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator(
                      color: AppColors.textOnAccentColor,
                    )
                  : Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: useDefaultFont?16:fontSize,
                        fontFamily: useDefaultFont?'poppins':fontFamily,
                        fontWeight: fontWeight,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget yellowTextIconButton(
      {String label = 'Button',
      required VoidCallback onPressed,
      double width = 264,
      double height = 44,
      String fontFamily = 'Bebas Neue',
      double fontSize = 20,
      FontWeight fontWeight = FontWeight.w400,
      Color backgroundColor = AppColors.accentColor,
      Color textColor = AppColors.textOnAccentColor,
      bool buttonFit = false,
      bool isLoading = false,
      required IconData icon}) {
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
            width: buttonFit ? null : width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLoading
                      ? SizedBox()
                      : Icon(icon,
                          color: textColor), //AppColors.textOnAccentColor),
                  isLoading
                      ? SizedBox()
                      : SizedBox(
                          width: 5,
                        ),
                  isLoading
                      ? Container(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            color: AppColors.textOnAccentColor,
                          ))
                      : Container(
                          margin: EdgeInsets.only(top: 5),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget outlineButton(
      {String label = 'Button',
      required VoidCallback onPressed,
      double width = 264,
      double height = 40,
      Color backgroundColor = AppColors.accentColor,
      bool buttonFit = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: AppColors.accentColor,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          decoration: ShapeDecoration(
            // color: backgroundColor,

            shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.accentColor, width: 2),
                borderRadius: BorderRadius.circular(5)),
          ),
          child: Container(
            width: buttonFit ? null : width,
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
    double height = 40,
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

            shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.accentColor, width: 2),
                borderRadius: BorderRadius.circular(5)),
          ),
          child: Container(
            width: buttonFit ? null : width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: Get.isDarkMode
                          ? AppColors.textColorDark
                          : AppColors.textColorLight),
                  SizedBox(
                    width: 10,
                  ),
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
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            color: AppColors.primary2Color,
          ),
          child: Icon(
            icon,
            color: AppColors.accentColor,
          ),
        ),
      ),
    );
  }

  static BottomNavigationBarItem bottomNavbarButton({
    required String pathname,
    required String label,
  }) {
    return BottomNavigationBarItem(
      label: '',
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            SvgPicture.asset(
              "assets/svgs/${pathname}",
              width: 24,
              height: 24,
              color: Get.isDarkMode?Colors.white:AppColors.textOnAccentColor,
            ),
            SizedBox(height: 6,),
            Text(label,style: TextStyle(fontSize: 15),),
            SizedBox(height: 6,),
            SvgPicture.asset(
              "assets/svgs/bottom-line.svg",
              width: 16,
              height: 3,
              color: Get.isDarkMode?Colors.white:AppColors.textOnAccentColor,
            ),

          ],
        ),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            SvgPicture.asset(
              "assets/svgs/${pathname}",
              width: 24,
              height: 24,
              color: AppColors.accentColor,
            ),
            SizedBox(height: 6,),
            Text(label,style: TextStyle(fontSize: 15),),
            SizedBox(height: 6,),
            SvgPicture.asset(
              "assets/svgs/bottom-line.svg",
              width: 16,
              height: 3,
              color: AppColors.accentColor,
            ),

          ],
        ),
      ),
    );
  }
}

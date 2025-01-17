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
        String svg = '',
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
                  ? SizedBox(
                width: height-10, // Width of the indicator
                height:  height-10, // Height of the indicator
                child: CircularProgressIndicator(
                  color: AppColors.textOnAccentColor,
                ),
              )
                  : svg==''?Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: useDefaultFont?16:fontSize,
                        fontFamily: useDefaultFont?'poppins':fontFamily,
                        fontWeight: fontWeight,
                      ),
                    ):SvgPicture.asset(svg,width: fontSize,height: fontSize,),
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
        String svg = "",
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
                      : svg==""?Icon(icon,
                          color: textColor):SvgPicture.asset(svg,width: 24,height: 24,color: textColor), //AppColors.textOnAccentColor),
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
        int fontSize = 16,
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
                style: TypographyStyles.title(fontSize),
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
    Color textColor = AppColors.textOnAccentColor,
    bool buttonFit = false,
    String svg = "",
    String fontFamily = 'Bebas Neue',
    double fontSize = 20,
    double borderWidth = 2,
    Color outlineColor = AppColors.accentColor,
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
                side: BorderSide(color: outlineColor, width: borderWidth),
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

                  svg==""?Icon(icon,
                      color: Get.isDarkMode
                          ? AppColors.textColorDark
                          : AppColors.textColorLight):SvgPicture.asset(svg,width: 24,height: 24,color: Get.isDarkMode
                      ? AppColors.textColorDark
                      : AppColors.textColorLight),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      color:Get.isDarkMode?Colors.white:Color(0xFF1B1F24),
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w400,
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

  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = AppColors.primary2Color,
    Color iconColor = AppColors.accentColor,
    double iconSize = 24,
    double padding = 10,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onPressed,
        child: Ink(
          padding: EdgeInsets.all(padding),
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            color: backgroundColor,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
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

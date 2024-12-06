import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 30, width: Get.width,),
              SizedBox(
                height: Get.height/100*6,
                child: Image.asset("assets/logo_white.png",
                  color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                  fit: BoxFit.fitHeight,
                ),
              ),
              SizedBox(height: 30,),
              Text("North Star Private Limited.",
                style: TypographyStyles.boldText(24, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              ),
              SizedBox(height: 30,),
              Text("Registration Number",
                style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300.withOpacity(0.6) : colors.Colors().darkGrey(0.6),),
              ),
              SizedBox(height: 5,),
              Text("#C05482020",
                style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              ),
              SizedBox(height: 30,),
              Text("Address",
                style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300.withOpacity(0.6) : colors.Colors().darkGrey(0.6),),
              ),
              SizedBox(height: 5,),
              Text("Vinares 9/ Hulhumale phase 2",
                style: TypographyStyles.boldText(18,Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30,),
              Text("Contact Number",
                style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300.withOpacity(0.6) : colors.Colors().darkGrey(0.6),),
              ),
              SizedBox(height: 5,),
              Text("+960 9590888",
                style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              ),
              SizedBox(height: 30,),
              Text("Email Address",
                style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300.withOpacity(0.6) : colors.Colors().darkGrey(0.6),),
              ),
              SizedBox(height: 5,),
              Text("info@northstar.mv",
                style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              ),
              SizedBox(height: 30,),
              Text("Website",
                style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300.withOpacity(0.6) : colors.Colors().darkGrey(0.6),),
              ),
              SizedBox(height: 5,),
              Text("https://northstar.mv/",
                style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

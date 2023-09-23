import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetServices/BMICalculator.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetServices/BloodPressureCalculator.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetServices/BloodSugarCalculator.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetServices/BodyFatCalculator.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class HomeWidgetServices extends StatelessWidget {
  const HomeWidgetServices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Services")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Container(
              width: Get.width,
              height: Get.height/100*15,
              child: TextButton(
                style: ButtonStyles.healthServiceButton(Color(0xFF1E3A5F)),
                onPressed: (){
                  Get.to(()=>BMICalculator());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 70,
                            child: Image.asset("assets/cliparts/bmi.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          SizedBox(width: 25,),
                          Text('BMI Calculator',
                            textAlign: TextAlign.center,
                            style: TypographyStyles.boldText(18, Themes.mainThemeColorAccent.shade100),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                        color: Themes.mainThemeColorAccent.shade100,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: Get.width,
              height: Get.height/100*15,
              child: TextButton(
                style: ButtonStyles.healthServiceButton(Color(0xFF5B2222)),
                onPressed: (){
                  Get.to(()=>BloodPressureCalculator());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 70,
                            child: Image.asset("assets/cliparts/pressure.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          SizedBox(width: 25,),
                          Text('Blood Pressure\nCalculator',
                            textAlign: TextAlign.left,
                            style: TypographyStyles.boldText(18, Themes.mainThemeColorAccent.shade100),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                        color: Themes.mainThemeColorAccent.shade100,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: Get.width,
              height: Get.height/100*15,
              child: TextButton(
                style: ButtonStyles.healthServiceButton(Color(0xFF345920)),
                onPressed: (){
                  Get.to(()=>BodyFatCalculator());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 70,
                            child: Image.asset("assets/cliparts/bodyfat.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          SizedBox(width: 25,),
                          Text('Body Fat\nCalculator',
                            textAlign: TextAlign.left,
                            style: TypographyStyles.boldText(18, Themes.mainThemeColorAccent.shade100),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                        color: Themes.mainThemeColorAccent.shade100,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: Get.width,
              height: Get.height/100*15,
              child: TextButton(
                style: ButtonStyles.healthServiceButton(Color(0xFF640E31)),
                onPressed: (){
                  Get.to(()=>BloodSugarCalculator());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 70,
                            child: Image.asset("assets/cliparts/sugar.png",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          SizedBox(width: 25,),
                          Text('Blood Sugar\nCalculator',
                            textAlign: TextAlign.left,
                            style: TypographyStyles.boldText(18, Themes.mainThemeColorAccent.shade100),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                        color: Themes.mainThemeColorAccent.shade100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

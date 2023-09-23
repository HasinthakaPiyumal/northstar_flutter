import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:http/http.dart' as http;
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../../components/Buttons.dart';

class BMICalculator extends StatelessWidget {

  const BMICalculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = true.obs;
    RxMap result = {}.obs;

    RxBool isMetric = true.obs;

    TextEditingController weightController = new TextEditingController();
    TextEditingController heightController = new TextEditingController();

    void getBMIPI(String weight, String height) async {
      ready.value = true;
      var request = http.Request(
          'POST',
          Uri.parse(HttpClient.baseURL + '/api/fitness/static/health-services/bmi-pi'));
          request.headers.addAll(client.getHeader());
          request.body = jsonEncode(
          {'weight': weight, 'height': height});

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = jsonDecode(await response.stream.bytesToString());
        print(res);
        result.value = res;
        ready.value = true;
      } else {
        var dt = jsonDecode(await response.stream.bytesToString());
        print(dt);
        print(response.reasonPhrase);
        ready.value = true;
      }
    }

    Widget cardHealth(value, category, unit, isBMI) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Utils.colorBMI(category)[0],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit,
                    style: TypographyStyles.normalText(
                        14, Utils.colorBMI(category)[1])),
                Text(category,
                    style: TypographyStyles.boldText(
                        16, Utils.colorBMI(category)[1]))
              ],
            ),
            RichText(
              text: TextSpan(
                text: value.toString(),
                style: TypographyStyles.boldText(24, Utils.colorBMI(category)[1]),
                children: <TextSpan>[
                  TextSpan(text: isBMI ? " kg/m²" : " kg/m³",
                    style: TypographyStyles.boldText(24, Utils.colorBMI(category)[1]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('BMI and PI Calculator'),),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 15),
              Text("SELECT UNIT", style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),),
              SizedBox(height: 15),
              Row(
                children: [
                  Obx(()=>Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        isMetric.value = true;
                        weightController.clear();
                        heightController.clear();
                      },
                      style: isMetric.value ? ButtonStyles.selectedButton() : ButtonStyles.notSelectedButton(),
                      child: Text("Metric",
                        style: TypographyStyles.boldText(16, isMetric.value ? Get.isDarkMode ? Themes.mainThemeColor.shade500 : colors.Colors().lightBlack(1) : Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                      ),
                    ),
                  ),),
                  SizedBox(width: 10,),
                  Obx(()=>Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        isMetric.value = false;
                        weightController.clear();
                        heightController.clear();
                      },
                      style: !isMetric.value ? ButtonStyles.selectedButton() : ButtonStyles.notSelectedButton(),
                      child: Text("Imperial",
                        style: TypographyStyles.boldText(16, isMetric.value ? Get.isDarkMode ? Themes.mainThemeColor.shade500 : colors.Colors().lightBlack(1) : Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                      ),
                    ),
                  ),),
                ],
              ),
              SizedBox(height: 16),
              Obx(()=>Text(isMetric.value ? "HEIGHT (cm)" : "HEIGHT (in)",
                style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              ),),
              SizedBox(height: 10),
              Obx(()=>TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: heightController,
                decoration: InputDecoration(
                  suffix: Text(isMetric.value ? "cm" : 'in',
                    style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
                  ),
                ),
              ),),
              SizedBox(height: 20,),
              Obx(()=>Text(isMetric.value ? "WEIGHT (Kg)" : "WEIGHT (lbs)",
                style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              ),),
              SizedBox(height: 10),
              Obx(()=>TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: weightController,
                decoration: InputDecoration(
                  suffix: Text(isMetric.value ? "Kg" : 'lbs',
                    style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
                  ),
                ),
              ),),
              SizedBox(height: 50),
              Container(
                  width: Get.width,
                  child: Buttons.yellowFlatButton(onPressed: () {
                    print(isMetric);
                    if(weightController.text != "" && heightController.text != ""){
                      if(isMetric.isTrue){
                        getBMIPI(weightController.text, heightController.text);
                      }else{
                        getBMIPI((double.parse(weightController.text) * 0.45359237).toString(), (double.parse(heightController.text) * 2.54).toString());
                      }
                    }else{
                      showSnack("No Inputs Found", "Please enter your weight and height");
                    }
                  },label: "calculate")),
              SizedBox(height: 20),
              Obx(()=>result['success'] != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  SizedBox(height: 8),
                  cardHealth(
                    result['BMI'],
                    result['BMICat'],
                    'Body Mass Index (BMI)',
                    true,
                  ),
                  SizedBox(height: 8),
                  cardHealth(
                    result['PI'],
                    result['PICat'],
                    'Ponderal Index (PI)',
                    false,
                  ),
                ],
              )
                  : Container(),),
              SizedBox(height: 20),
            ],
          ),
        ),
      )
    );
  }
}

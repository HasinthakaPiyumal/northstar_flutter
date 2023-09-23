import 'package:flutter/material.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'dart:convert';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:get/get.dart';
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:http/http.dart' as http;

import '../../../components/Buttons.dart';

class BloodSugarCalculator extends StatelessWidget {
  const BloodSugarCalculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    TextEditingController fbs = new TextEditingController();
    TextEditingController rbs = new TextEditingController();
    RxMap result = {}.obs;

    void getBS() async {
      ready.value = true;
      var request = http.Request(
          'POST',
          Uri.parse(HttpClient.baseURL + '/api/fitness/static/health-services/blood-sugar'));
      request.headers.addAll(client.getHeader());

      request.body = jsonEncode({
        'fbs': fbs.text,
        'rbs': rbs.text,
      });

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

    Widget cardHealth(value, category, unit) {
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
            Text(value.toString(),
                style:
                TypographyStyles.boldText(24, Utils.colorBMI(category)[1])),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Sugar Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[

              Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("FBS - Fasting Blood Sugar",
                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                          ),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("Sugar Level")),
                              Container(
                                width: Get.width/3.5,
                                child: TextField(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  controller: fbs,
                                  decoration: InputDecoration(
                                    suffix: Text("mg/dl",
                                      style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColor.shade500 : colors.Colors().lightBlack(1),),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Get.isDarkMode ?  AppColors.primary2Color : Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("PBS - Post Blood Sugar",
                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                          ),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("Sugar Level")),
                              Container(
                                width: Get.width/3.5,
                                child: TextField(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  controller: rbs,
                                  decoration: InputDecoration(
                                    suffix: Text("mg/dl",
                                      style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColor.shade500 : colors.Colors().lightBlack(1)),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                  width: Get.width,
                  child: Buttons.yellowFlatButton(onPressed:  (){getBS();},label: "calculate")),

              SizedBox(height: 16),
              Obx(()=>result['success'] != null ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  SizedBox(height: 8),
                  cardHealth(result['FBS'], result['FBSCategory'], 'Fasting Blood Sugar'),
                  SizedBox(height: 8),
                  cardHealth(result['RBS'], result['RBSCategory'], 'Post Blood Sugar'),
                ],
              ) : Container(),),
            ],
          ),
        ),
      ),
    );
  }
}

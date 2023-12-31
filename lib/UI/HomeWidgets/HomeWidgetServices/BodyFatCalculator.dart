import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../../components/Buttons.dart';

class BodyFatCalculator extends StatelessWidget {
  const BodyFatCalculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxMap result = {}.obs;
    TextEditingController weightController = new TextEditingController();

    ScrollController _scrollController = ScrollController();

    TextEditingController frontUA = new TextEditingController();
    TextEditingController backUA = new TextEditingController();
    TextEditingController sideW = new TextEditingController();
    TextEditingController backBS = new TextEditingController();
    TextEditingController age = TextEditingController();

    FocusNode frontUAFN = FocusNode();
    FocusNode backUAFN = FocusNode();
    FocusNode sideWFN = FocusNode();
    FocusNode backBSFN = FocusNode();
    FocusNode ageFN = FocusNode();
    FocusNode weightFN = FocusNode();

    FocusNode CardFocus = FocusNode();
    FocusNode CalculateFocus = FocusNode();
    RxString gender = 'Male'.obs;

    void clear() {
      result.value = {}.obs;
      frontUA.clear();
      backUA.clear();
      sideW.clear();
      backBS.clear();
      age.clear();
      weightController.clear();
    }
    FocusScope.of(context).requestFocus(CardFocus);
    void getFATMM() async {
      ready.value = true;

      var request = http.Request(
          'POST',
          Uri.parse(HttpClient.baseURL +
              '/api/fitness/static/health-services/fat-mm'));
      request.headers.addAll(client.getHeader());
      request.body = jsonEncode({
        'front_upper_arm': frontUA.text,
        'back_upper_arm': backUA.text,
        'side_of_waist': sideW.text,
        'back_below_shoulder': backBS.text,
        'age': age.text,
        'gender': gender.value,
        'weight': weightController.text,
      });

      http.StreamedResponse response = await request.send();
      print(response);
      if (response.statusCode == 200) {
        var res = jsonDecode(await response.stream.bytesToString());
        print(res);
        result.value = res;
        ready.value = true;
        FocusScope.of(context).requestFocus(CardFocus);
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
      appBar: AppBar(),
      body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Body Fat Calculator &\nMuscles Mass",
                  style: TypographyStyles.boldText(
                    22,
                    Get.isDarkMode
                        ? Themes.mainThemeColorAccent.shade100
                        : colors.Colors().lightBlack(1),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(() => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gender'),
                        Row(
                          children: [
                            Radio(
                              groupValue: gender.value,
                              onChanged: (value) {
                                gender.value = value.toString();
                              },
                              value: 'Male',
                              activeColor: Themes.mainThemeColor.shade500,
                            ),
                            Text('Male'),
                            Radio(
                              groupValue: gender.value,
                              onChanged: (value) {
                                gender.value = value.toString();
                              },
                              value: 'Female',
                              activeColor: Themes.mainThemeColor.shade500,
                            ),
                            Text('Female'),
                          ],
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(child: Text("Age")),
                        Container(
                          width: Get.width / 3.5,
                          child: TextField(
                            controller: age,
                            focusNode: ageFN,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onSubmitted: (value) {
                              print("Submittion");
                              ageFN.unfocus();
                              FocusScope.of(context).requestFocus(frontUAFN);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(
                      thickness: 1,
                      color: Get.isDarkMode
                          ? colors.Colors().darkGrey(1)
                          : colors.Colors().selectedCardBG,
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: Text("Front of Upper Arm")),
                        Container(
                          width: Get.width / 3.5,
                          child: TextField(
                            controller: frontUA,
                            focusNode: frontUAFN,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              suffix: Text(
                                "mm",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColor.shade500),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onSubmitted: (value) {
                              frontUAFN.unfocus();
                              FocusScope.of(context).requestFocus(backUAFN);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text("Back of Upper Arm")),
                        Container(
                          width: Get.width / 3.5,
                          child: TextField(
                            controller: backUA,
                            focusNode: backUAFN,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              suffix: Text(
                                "mm",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColor.shade500),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onSubmitted: (value) {
                              backUAFN.unfocus();
                              FocusScope.of(context).requestFocus(sideWFN);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text("Side of Waist")),
                        Container(
                          width: Get.width / 3.5,
                          child: TextField(
                            controller: sideW,
                            focusNode: sideWFN,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              suffix: Text(
                                "mm",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColor.shade500),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onSubmitted: (value) {
                              sideWFN.unfocus();
                              FocusScope.of(context).requestFocus(backBSFN);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text("Back Below Shoulder")),
                        Container(
                          width: Get.width / 3.5,
                          child: TextField(
                            controller: backBS,
                            focusNode: backBSFN,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              suffix: Text(
                                "mm",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColor.shade500),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onSubmitted: (value) {
                              backBSFN.unfocus();
                              FocusScope.of(context).requestFocus(weightFN);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(
                      thickness: 1,
                      color: Get.isDarkMode
                          ? colors.Colors().darkGrey(1)
                          : colors.Colors().selectedCardBG,
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: Text("Weight")),
                        Container(
                          width: Get.width / 3.5,
                          child: TextField(
                            controller: weightController,
                            focusNode: weightFN,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              suffix: Text(
                                "kg",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColor.shade500),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(CalculateFocus);
                              getFATMM();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Focus(
                focusNode: CalculateFocus,
                child: Container(
                    width: Get.width,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Buttons.yellowFlatButton(
                        onPressed: () {
                          getFATMM();
                        },
                        label: "calculate")),
              ),
              Obx(() => Visibility(
                    visible: result['success'] != null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Buttons.outlineButton(
                          onPressed: () {
                            clear();
                          },
                          label: "Clear",
                          width: Get.width),
                    ),
                  )),
              SizedBox(height: 8),
              Obx(
                () => result['success'] != null
                    ? Focus(
                        focusNode: CardFocus,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              SizedBox(height: 8),
                              cardHealth(result['BodyFat'].toString() + '%',
                                  result['BodyFatCategory'], 'Body Fat'),
                              SizedBox(height: 8),
                              cardHealth(result['MuscleMass'].toString() + '%',
                                  result['BodyFatCategory'], 'Muscle Mass'),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ),
              SizedBox(height: 10),
            ],
          )),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class CompleteUserProfile extends StatelessWidget {
  const CompleteUserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxMap userData = {}.obs;
    RxString marital = 'single'.obs;
    RxInt noOfChildren = 0.obs;
    RxList selectedHealthConditions = [].obs;
    RxList healthConditions = [
      'Eye Trouble / Eye Operation',
      'Heart Disease',
      'Hay Fever',
      'Hay Fever, Other Allergy',
      'Asthma Lung Disease',
      'Heart Or Vascular Troubles',
      'High Or Low Blood Pressure',
      'Psychological Trouble',
      'Positive HIV Test',
      'Musculoskeletal Illness',
      'Stomach Intestinal Trouble',
      'Head Injury Of Possession',
      'High Cholesterol Levels',
      'Dizziness Or Fainting Spells',
      'Unconsciousness For Any Reason',
      'Neurological Disorders',
      'Kidney Disease',
      'Diabetes',
      'Hormonal Disorders'
    ].obs;

    TextEditingController hController = new TextEditingController();

    void saveAdditionalData() async {
      ready.value = false;
      Map res = await httpClient.saveAdditionalData({
        "health_conditions": jsonEncode(selectedHealthConditions.value),
        "marital_status": marital.value,
        "children": noOfChildren.toString(),
      });

      if (res['code'] == 200) {
        authUser.user['client']['is_complete'] = 1;
        Get.back();
      } else {
        ready.value = true;
        showSnack('Something went wrong!', res.toString());
      }
    }



    void getProfile() async{
      ready.value = false;
      Map res = await httpClient.getMyProfile();
      if (res['code'] == 200) {
        userData.value = res['data'];
        print(userData.value);
        if(userData['marital_status'] != null){
          marital.value = userData['marital_status'];
        }

        if(userData['children'] != null){
          noOfChildren.value = userData['children'];
        }

        if(userData['health_conditions'] != null){
          selectedHealthConditions.value = userData['health_conditions'];

          userData['health_conditions'].forEach((element) {
            if(!healthConditions.value.contains(element)){
              healthConditions.value.add(element);
            }
          });
        }


        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getProfile();

    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile'),
      ),
      body: SingleChildScrollView(
        child: Obx(() => ready.value ? Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marital Status',
                    style: TypographyStyles.title(17),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Container(
                        width: Get.width,
                        child: ElevatedButton(
                          style: marital.value == 'single'
                              ? SignUpStyles.selectedButton()
                              : SignUpStyles.notSelectedButton(),
                          onPressed: () {
                            marital.value = 'single';
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Single',
                              style: TypographyStyles.text(17).copyWith(color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 13),
                      Container(
                        width: Get.width,
                        child: ElevatedButton(
                          style: marital.value == 'married'
                              ? SignUpStyles.selectedButton()
                              : SignUpStyles.notSelectedButton(),
                          onPressed: () {
                            marital.value = 'married';
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Married',
                              style: TypographyStyles.text(17),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Children Under 12',
                    style: TypographyStyles.title(17),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (noOfChildren.value > 0) noOfChildren.value--;
                        },
                        child: Icon(Icons.remove, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10),
                          backgroundColor: colors.Colors().deepGrey(1),
                          foregroundColor: colors.Colors().deepYellow(1),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(noOfChildren.value.toString(),
                          style: TypographyStyles.title(21)
                              .copyWith(color: Get.isDarkMode ? colors.Colors().deepYellow(1) : colors.Colors().lightBlack(1),)),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          noOfChildren.value++;
                        },
                        child: Icon(Icons.add, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10),
                          backgroundColor: colors.Colors().deepGrey(1),
                          foregroundColor: colors.Colors().deepYellow(1), // <-- Splash color
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Health Conditions',
                          style: TypographyStyles.title(17),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.defaultDialog(
                              radius: 8,
                              title: 'Health Conditions',
                              titlePadding: EdgeInsets.only(top: 15),
                              contentPadding: EdgeInsets.only(top: 15),
                              content: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [],
                                    ),
                                    TextField(
                                      controller: hController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Your Health condition',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        healthConditions.add(hController.text.trim());
                                        selectedHealthConditions.add(hController.text.trim());
                                        hController.text = '';
                                        Get.back();
                                      },
                                      child: Text('Add Condition'),
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                          child: Icon(Icons.add, color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(10),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            // <-- Button color
                            foregroundColor: colors.Colors()
                                .deepYellow(1), // <-- Splash color
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: 10,
                  ),
                  Obx(() => ListView.builder(
                        shrinkWrap: true,
                        itemCount: healthConditions.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (_, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Obx(()=>CheckboxListTile(
                              title: Text(healthConditions[index]),
                              tileColor: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                              onChanged: (bool? value) {
                                if(value == true){
                                  selectedHealthConditions.add(healthConditions[index]);
                                } else {
                                  selectedHealthConditions.remove(healthConditions[index]);
                                }
                              },
                              value: selectedHealthConditions.contains(healthConditions[index]),
                              checkColor: Colors.white,
                              activeColor: colors.Colors().deepYellow(1),
                            )),
                          );
                        },
                      ))
                ],
              ),
            ): LoadingAndEmptyWidgets.loadingWidget()),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: ElevatedButton(
          style: ButtonStyles.bigBlackButton(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('SAVE & COMPLETE')],
            ),
          ),
          onPressed: () {
            saveAdditionalData();
          },
        ),
      ),
    );
  }
}

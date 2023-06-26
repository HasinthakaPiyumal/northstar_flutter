import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/SelectedPlan.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;


class PurchaseGymSubscription extends StatelessWidget {
  const PurchaseGymSubscription({Key? key, this.gymObj}) : super(key: key);
  final gymObj;

  @override
  Widget build(BuildContext context) {
    RxInt selectedPlanType = 99.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Booking'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  "Select Plan",
                  style: TypographyStyles.normalText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1)),
                ),
                SizedBox(height: 8),
                Container(
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      selectedPlanType.value = 0;
                    },
                    style: selectedPlanType.value == 0 ? ButtonStyles.selectedButtonNoPadding() : ButtonStyles.notSelectedButtonNoPadding(),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Monthly Plan",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColor.shade500),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Themes.mainThemeColor.shade500,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    "SAVE MVR 120.00",
                                    style: TypographyStyles.boldText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "MVR ${gymObj['monthly_charge']}",
                                style: TypographyStyles.boldText(
                                    20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                              ),
                              Text(
                                "  +  GST",
                                style: TypographyStyles.normalText(
                                    14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Per Month",
                            style: TypographyStyles.normalText(
                                14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      selectedPlanType.value = 1;
                    },
                    style: selectedPlanType.value == 1
                        ? ButtonStyles.selectedButtonNoPadding()
                        : ButtonStyles.notSelectedButtonNoPadding(),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Weekly Plan",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColor.shade500),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "MVR ${gymObj['weekly_charge']}",
                                style: TypographyStyles.boldText(
                                    20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                              ),
                              Text(
                                "  +  GST",
                                style: TypographyStyles.normalText(
                                    14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Per 1 Week (7 Days)",
                            style: TypographyStyles.normalText(
                                14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      selectedPlanType.value = 2;
                    },
                    style: selectedPlanType.value == 2
                        ? ButtonStyles.selectedButtonNoPadding()
                        : ButtonStyles.notSelectedButtonNoPadding(),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Daily Plan",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColor.shade500),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "MVR ${gymObj['daily_charge']}",
                                style: TypographyStyles.boldText(
                                    20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                              ),
                              Text(
                                "  +  GST",
                                style: TypographyStyles.normalText(
                                    14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Per Day",
                            style: TypographyStyles.normalText(
                                14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ElevatedButton(
          style: ButtonStyles.bigBlackButton(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'PROCEED',
              style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade100),
            ),
          ),
          onPressed: () {
            if(selectedPlanType.value < 3){
              Get.to(() => SelectedPlan(
                selectedPlanID: selectedPlanType.value,
                gymObj: gymObj,
                selectedPlanType: selectedPlanType.value,
              ));
            }else{
              showSnack('Plan not selected', 'Please a Plan to continue');
            }
          },
        ),
      ),
    );
  }
}

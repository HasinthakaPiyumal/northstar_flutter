import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/SelectedPlan.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/components/Buttons.dart';

import '../../../Styles/AppColors.dart';


class PurchaseGymSubscription extends StatelessWidget {
  const PurchaseGymSubscription({Key? key, this.gymObj}) : super(key: key);
  final gymObj;



  @override
  Widget build(BuildContext context) {
    RxInt selectedPlanType = 0.obs;
    RxMap planObj = {}.obs;

    // Widget itemBuilder(dynamic obj){
    //   int id = 1;
    //   print("obj");
    //
    // }
    print(gymObj['com_gym_plans'].length);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Booking'),
      ),
      // body: Column(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      //   Obx(() =>
      //       Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 16),
      //         child: ListView(
      //         children: List.generate(gymObj['com_gym_plans'].length,(index) => itemBuilder()),
      //
      //         ),
      //           // children: [
      //           //   SizedBox(height: 16),
      //           //   Container(
      //           //     width: Get.width,
      //           //     child: ElevatedButton(
      //           //       onPressed: () {
      //           //         selectedPlanType.value = 0;
      //           //       },
      //           //       style: selectedPlanType.value == 0 ? ButtonStyles
      //           //           .selectedButtonNoPadding() : ButtonStyles
      //           //           .notSelectedButtonNoPadding(),
      //           //       child: Padding(
      //           //         padding:
      //           //         EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      //           //         child: Column(
      //           //           mainAxisSize: MainAxisSize.min,
      //           //           children: [
      //           //             Row(
      //           //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           //               children: [
      //           //                 Text(
      //           //                   "Monthly Plan",
      //           //                   style: TypographyStyles.smallBoldTitle(26),
      //           //                 ),
      //           //                 Container(
      //           //                   decoration: BoxDecoration(
      //           //                     borderRadius: BorderRadius.circular(50),
      //           //                     color: AppColors.accentColor,
      //           //                   ),
      //           //                   child: Padding(
      //           //                     padding: EdgeInsets.symmetric(
      //           //                       vertical: 10,
      //           //                       horizontal: 20,
      //           //                     ),
      //           //                     child: Text(
      //           //                       "SAVE MVR 120.00",
      //           //                       style: TypographyStyles.boldText(
      //           //                           12, AppColors.textOnAccentColor),
      //           //                     ),
      //           //                   ),
      //           //                 ),
      //           //               ],
      //           //             ),
      //           //             SizedBox(
      //           //               height: 20,
      //           //             ),
      //           //             Row(
      //           //               mainAxisAlignment: MainAxisAlignment.center,
      //           //               children: [
      //           //                 Text(
      //           //                   "MVR ${gymObj['monthly_charge']}",
      //           //                   style: TypographyStyles.boldText(
      //           //                       20, Get.isDarkMode ? Themes
      //           //                       .mainThemeColorAccent.shade100 : colors
      //           //                       .Colors().lightBlack(1)),
      //           //                 ),
      //           //                 Text(
      //           //                   "  +  GST",
      //           //                   style: TypographyStyles.normalText(
      //           //                       16, Get.isDarkMode ? Themes
      //           //                       .mainThemeColorAccent.shade100 : colors
      //           //                       .Colors().darkGrey(1)),
      //           //                 ),
      //           //               ],
      //           //             ),
      //           //             SizedBox(
      //           //               height: 5,
      //           //             ),
      //           //             Text(
      //           //               "Per Month",
      //           //               style: TypographyStyles.normalText(
      //           //                   14, Get.isDarkMode
      //           //                   ? AppColors.accentColor
      //           //                   : colors.Colors().lightBlack(1)),
      //           //             ),
      //           //             SizedBox(
      //           //               height: 10,
      //           //             ),
      //           //           ],
      //           //         ),
      //           //       ),
      //           //     ),
      //           //   ),
      //           //   SizedBox(height: 16),
      //           //   Container(
      //           //     width: Get.width,
      //           //     child: ElevatedButton(
      //           //       onPressed: () {
      //           //         selectedPlanType.value = 1;
      //           //       },
      //           //       style: selectedPlanType.value == 1
      //           //           ? ButtonStyles.selectedButtonNoPadding()
      //           //           : ButtonStyles.notSelectedButtonNoPadding(),
      //           //       child: Padding(
      //           //         padding:
      //           //         EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      //           //         child: Column(
      //           //           mainAxisSize: MainAxisSize.min,
      //           //           children: [
      //           //             Row(
      //           //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           //               children: [
      //           //                 Text(
      //           //                   "Weekly Plan",
      //           //                   style: TypographyStyles.smallBoldTitle(26),
      //           //                 ),
      //           //               ],
      //           //             ),
      //           //             SizedBox(
      //           //               height: 20,
      //           //             ),
      //           //             Row(
      //           //               mainAxisAlignment: MainAxisAlignment.center,
      //           //               children: [
      //           //                 Text(
      //           //                   "MVR ${gymObj['weekly_charge']}",
      //           //                   style: TypographyStyles.boldText(
      //           //                       20, Get.isDarkMode ? Themes
      //           //                       .mainThemeColorAccent.shade100 : colors
      //           //                       .Colors().lightBlack(1)),
      //           //                 ),
      //           //                 Text(
      //           //                   "  +  GST",
      //           //                   style: TypographyStyles.normalText(
      //           //                       16, Get.isDarkMode ? Themes
      //           //                       .mainThemeColorAccent.shade100 : colors
      //           //                       .Colors().darkGrey(1)),
      //           //                 ),
      //           //               ],
      //           //             ),
      //           //             SizedBox(
      //           //               height: 5,
      //           //             ),
      //           //             Text(
      //           //               "Per 1 Week (7 Days)",
      //           //               style: TypographyStyles.normalText(
      //           //                   14, Get.isDarkMode
      //           //                   ? AppColors.accentColor
      //           //                   : colors.Colors().darkGrey(1)),
      //           //             ),
      //           //             SizedBox(
      //           //               height: 10,
      //           //             ),
      //           //           ],
      //           //         ),
      //           //       ),
      //           //     ),
      //           //   ),
      //           //   SizedBox(height: 16),
      //           //   Container(
      //           //     width: Get.width,
      //           //     child: ElevatedButton(
      //           //       onPressed: () {
      //           //         selectedPlanType.value = 2;
      //           //       },
      //           //       style: selectedPlanType.value == 2
      //           //           ? ButtonStyles.selectedButtonNoPadding()
      //           //           : ButtonStyles.notSelectedButtonNoPadding(),
      //           //       child: Padding(
      //           //         padding:
      //           //         EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      //           //         child: Column(
      //           //           mainAxisSize: MainAxisSize.min,
      //           //           children: [
      //           //             Row(
      //           //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           //               children: [
      //           //                 Text(
      //           //                   "Daily Plan",
      //           //                   style: TypographyStyles.smallBoldTitle(26),
      //           //                 ),
      //           //               ],
      //           //             ),
      //           //             SizedBox(
      //           //               height: 20,
      //           //             ),
      //           //             Row(
      //           //               mainAxisAlignment: MainAxisAlignment.center,
      //           //               children: [
      //           //                 Text(
      //           //                   "MVR ${gymObj['daily_charge']}",
      //           //                   style: TypographyStyles.boldText(
      //           //                       20, Get.isDarkMode ? Themes
      //           //                       .mainThemeColorAccent.shade100 : colors
      //           //                       .Colors().lightBlack(1)),
      //           //                 ),
      //           //                 Text(
      //           //                   "  +  GST",
      //           //                   style: TypographyStyles.normalText(
      //           //                       16, Get.isDarkMode ? Themes
      //           //                       .mainThemeColorAccent.shade100 : colors
      //           //                       .Colors().darkGrey(1)),
      //           //                 ),
      //           //               ],
      //           //             ),
      //           //             SizedBox(
      //           //               height: 5,
      //           //             ),
      //           //             Text(
      //           //               "Per Day",
      //           //               style: TypographyStyles.normalText(
      //           //                   14, Get.isDarkMode
      //           //                   ? AppColors.accentColor
      //           //                   : colors.Colors().darkGrey(1)),
      //           //             ),
      //           //             SizedBox(
      //           //               height: 10,
      //           //             ),
      //           //           ],
      //           //         ),
      //           //       ),
      //           //     ),
      //           //   ),
      //           // ],
      //         // ),
      //       ),
      //   ),
      // ]),
      body: Obx(() =>Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
            children: List.generate(gymObj['com_gym_plans'].length,(index) {
              int id = gymObj['com_gym_plans'][index]['id'];
              dynamic obj = gymObj['com_gym_plans'][index];
              print(obj);
              return Container(
              width: Get.width,
              margin: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  selectedPlanType.value = id;
                  planObj.value =obj;
                },
                style: selectedPlanType.value == id ? ButtonStyles
                    .selectedButtonNoPadding() : ButtonStyles
                    .notSelectedButtonNoPadding(),
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: Get.width-92,
                            child: Text(
                              obj['name'],
                              softWrap: true,
                              textAlign: TextAlign.center,
                              // overflow: TextOverflow.ellipsis,
                              style: TypographyStyles.smallBoldTitle(26),
                            ),
                          ),
                          Visibility(
                            visible: obj["discounted"],
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Color(0xFF68FC80),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                child: Text(
                                  "SAVE MVR ${(obj['price']*obj['discounted_percentage']/100).toStringAsFixed(2)}",
                                  style: TypographyStyles.boldText(
                                      12, AppColors.textOnAccentColor),
                                ),
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
                            "MVR ${obj['real_price']}",
                            style: TypographyStyles.boldText(
                                20, Get.isDarkMode ? Themes
                                .mainThemeColorAccent.shade100 : colors
                                .Colors().lightBlack(1)),
                          ),
                          Text(
                            "  +  GST",
                            style: TypographyStyles.normalText(
                                16, Get.isDarkMode ? Themes
                                .mainThemeColorAccent.shade100 : colors
                                .Colors().darkGrey(1)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // Text(
                      //   "Per Month",
                      //   style: TypographyStyles.normalText(
                      //       14, Get.isDarkMode
                      //       ? AppColors.accentColor
                      //       : colors.Colors().lightBlack(1)),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ) ;
            }),
          ),
      ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        color: Theme
            .of(context)
            .scaffoldBackgroundColor,
        child: Buttons.yellowFlatButton(label: "Proceed",onPressed: () {
          if (selectedPlanType.value>0) {
            Get.to(() =>
                SelectedPlan(
                  selectedPlanID: selectedPlanType.value,
                  gymObj: gymObj,
                  plan: planObj,
                  selectedPlanType: selectedPlanType.value,
                ));
          } else {
            showSnack('Plan not selected', 'Please a Plan to continue');
          }
        },

      ),
    )
    ,
    );
  }
}

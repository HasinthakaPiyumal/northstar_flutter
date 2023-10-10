import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetPro.dart';
import 'package:north_star/UI/PrivateUser/CaloriesManager/EditMeal.dart';
import 'package:north_star/UI/PrivateUser/OverrideMacros.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/UI/SharedWidgets/RingsWidget.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../Styles/AppColors.dart';
import '../../components/Buttons.dart';

class UserCalories extends StatelessWidget {
  const UserCalories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxMap homeData = {}.obs;
    RxMap selectedDay = {'name': 'Today', 'value': '0'}.obs;

    void getHomeData() async {
      ready.value = false;
      Map res = await httpClient.getHomeData(selectedDay['value']);

      print(res);
      if (res['code'] == 200) {
        print("Calory data ---------");
        print(res['data']);
        homeData.value = res['data'];
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void selectDay() {
      Get.bottomSheet(Container(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 16),
                height: 56,
                width: Get.width * 0.9,
                child: ElevatedButton(
                  style: Get.isDarkMode
                      ? ButtonStyles.bigBlackButton()
                      : ButtonStyles.matRadButton(
                          colors.Colors().selectedCardBG, 0, 12),
                  onPressed: () {
                    selectedDay = {'name': 'Today', 'value': '0'}.obs;
                    getHomeData();
                    Get.back();
                  },
                  child: Text('Today'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                height: 56,
                width: Get.width * 0.9,
                child: ElevatedButton(
                  style: Get.isDarkMode
                      ? ButtonStyles.bigBlackButton()
                      : ButtonStyles.matRadButton(
                          colors.Colors().selectedCardBG, 0, 12),
                  onPressed: () {
                    selectedDay = {'name': 'Yesterday', 'value': '1'}.obs;
                    getHomeData();
                    Get.back();
                  },
                  child: Text('Yesterday'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                height: 56,
                width: Get.width * 0.9,
                child: ElevatedButton(
                  style: Get.isDarkMode
                      ? ButtonStyles.bigBlackButton()
                      : ButtonStyles.matRadButton(
                          colors.Colors().selectedCardBG, 0, 12),
                  onPressed: () {
                    selectedDay =
                        {'name': 'Day before Yesterday', 'value': '2'}.obs;
                    getHomeData();
                    Get.back();
                  },
                  child: Text('Day before Yesterday'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ));
    }

    getHomeData();

    checkIfUserHasTrainers() {
      print(authUser.role == 'trainer' ||
          ((authUser.user['client']['physical_trainer_id'] == null) &&
              (authUser.user['client']['diet_trainer_id'] == null)));
    }

    checkIfUserHasTrainers();

    return Scaffold(
        appBar: authUser.role == 'trainer'
            ? AppBar(
                actions: [
                  // IconButton(
                  //   onPressed: (){
                  //     int macroPlanId = homeData['macros'] == null ? -1 : homeData['macros']['id'];
                  //     Get.to(()=>OverrideMacros(macroPlanId: macroPlanId))?.then((value) => {
                  //       getHomeData()
                  //     });
                  //   },
                  //   icon: Icon(Icons.more_vert_rounded),
                  // ),
                ],
              )
            : null,
        body: SingleChildScrollView(
            child: Obx(() => authUser.user['subscription'] != null
                ? ready.value
                    ? homeData['macros'] != null
                        ? Column(children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 32,
                                        color: Color(0xFFFB3636),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Calories',
                                          style: TypographyStyles.title(20)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          selectDay();
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              selectedDay['name'],
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: Colors.white)
                                          ],
                                        ),
                                      ),
                                      authUser.role == 'trainer' ||
                                              ((authUser.user['client'][
                                                          'physical_trainer_id'] ==
                                                      null) &&
                                                  (authUser.user['client']
                                                          ['diet_trainer_id'] ==
                                                      null))
                                          ? Container(
                                              width: 32,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.all(0),
                                                ),
                                                onPressed: () {
                                                  int macroPlanId =
                                                      homeData['macros'] == null
                                                          ? -1
                                                          : homeData['macros']
                                                              ['id'];
                                                  Get.to(() => OverrideMacros(
                                                      macroPlanId:
                                                          macroPlanId))?.then(
                                                      (value) =>
                                                          {getHomeData()});
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.more_vert_rounded,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                                child: Obx(() => ready.value
                                    ? Card(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        color: Get.isDarkMode
                                            ? AppColors.primary2Color : Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('Eaten'),
                                                      Text(
                                                        homeData['macros'][
                                                                    'daily_calories']
                                                                .toString() +
                                                            ' Cal',
                                                        style: TypographyStyles
                                                            .title(24),
                                                      ),
                                                      SizedBox(height: 16),
                                                      Text('Target Calories'),
                                                      Text(
                                                        (homeData['macros'][
                                                                        'target_calories'])
                                                                .round()
                                                                .toString() +
                                                            ' Cal',
                                                        style: TypographyStyles
                                                            .title(24),
                                                      ),
                                                    ],
                                                  ),
                                                  //ringsWidget(homeData)
                                                  Container(
                                                    height: 150,
                                                    width: 150,
                                                    child: SafeArea(
                                                        child: ringsChart(
                                                            homeData)),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 16),
                                              IntrinsicHeight(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Container(
                                                      width: 4,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Carbs',
                                                            style:
                                                                TypographyStyles
                                                                    .title(14)),
                                                        SizedBox(height: 4),
                                                        Text(homeData['macros'][
                                                                    'daily_carbs']
                                                                .toStringAsFixed(
                                                                    1) +
                                                            ' / ' +
                                                            homeData['macros'][
                                                                    'target_carbs']
                                                                .toString() +
                                                            'g'),
                                                      ],
                                                    ),
                                                    VerticalDivider(width: 1),
                                                    Container(
                                                      width: 4,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Fat',
                                                            style:
                                                                TypographyStyles
                                                                    .title(14)),
                                                        SizedBox(height: 4),
                                                        Text(homeData['macros'][
                                                                    'daily_fat']
                                                                .toStringAsFixed(
                                                                    1) +
                                                            ' / ' +
                                                            homeData['macros'][
                                                                    'target_fat']
                                                                .toString() +
                                                            'g'),
                                                      ],
                                                    ),
                                                    VerticalDivider(width: 1),
                                                    Container(
                                                      width: 4,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Proteins',
                                                            style:
                                                                TypographyStyles
                                                                    .title(14)),
                                                        SizedBox(height: 4),
                                                        Text(homeData['macros'][
                                                                    'daily_protein']
                                                                .toStringAsFixed(
                                                                    1) +
                                                            ' / ' +
                                                            homeData['macros'][
                                                                    'target_protein']
                                                                .toString() +
                                                            'g'),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                            ],
                                          ),
                                        ))
                                    : LinearProgressIndicator())),
                            SizedBox(
                              height: 20,
                            ),
                            ready.value
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Obx(() => ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: homeData['meals'].length,
                                          itemBuilder: (_, index) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  Get.to(() => EditMeal(
                                                            mealID: homeData[
                                                                    'meals']
                                                                [index]['id'],
                                                            foodList: homeData[
                                                                        'meals']
                                                                    [index]
                                                                ['food_data'],
                                                            editMode: true,
                                                            selectedDay:
                                                                selectedDay,
                                                          ))
                                                      ?.then((value) =>
                                                          getHomeData());
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Get.isDarkMode
                                                        ? AppColors.primary2Color
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 15,
                                                            horizontal: 16),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    'Meal ' +
                                                                        (index +
                                                                                1)
                                                                            .toString(),
                                                                    style: TypographyStyles
                                                                        .title(
                                                                            16),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(homeData['meals'][index]
                                                                              [
                                                                              'calories']
                                                                          .toString() +
                                                                      ' Cal'),
                                                                ],
                                                              ),
                                                            ),
                                                            Icon(
                                                                Icons
                                                                    .add_circle,
                                                                size: 24),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )),
                                  )
                                : Container(),
                            SizedBox(height: 16),
                            Buttons.yellowTextIconButton(
                                onPressed: () {
                                  Get.to(() => EditMeal(
                                        foodList: [],
                                        mealID: -1,
                                        editMode: false,
                                        selectedDay: selectedDay,
                                      ))?.then((value) => {getHomeData()});
                                },
                                icon: Icons.add,
                                label: "add meal"),
                            SizedBox(height: 16),
                          ])
                        : Column(
                            children: [
                              SizedBox(height: 64),
                              Center(
                                child: Text('No Macro Profile is Active!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              SizedBox(height: 16),
                              Visibility(
                                visible: authUser.role != 'trainer',
                                child: Center(
                                  child: Text('Please contact your Trainer.'),
                                ),
                              ),
                              Visibility(
                                visible: authUser.role != 'trainer',
                                child: SizedBox(height: 16),
                              ),
                              Center(
                                child: Text('OR'),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(),
                                    onPressed: () {
                                      int macroPlanId =
                                          homeData['macros'] == null
                                              ? -1
                                              : homeData['macros']['id'];
                                      Get.to(() => OverrideMacros(
                                              macroPlanId: macroPlanId))
                                          ?.then((value) => {getHomeData()});
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 3, horizontal: 5),
                                      child: Text(
                                        'SET YOUR OWN GOALS',
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                    : Column(
                        children: [
                          SizedBox(height: Get.height * 0.25),
                          LoadingAndEmptyWidgets.loadingWidget(),
                        ],
                      )
                : Column(children: [
                    Row(
                      children: [
                        ready.value ? SizedBox(width: 16) : SizedBox(width: 0),
                      ],
                    ),
                    Image.asset(
                      'assets/home/pro.png',
                      height: Get.height * 0.25,
                    ),
                    Icon(Icons.lock_outline,
                        color: Colors.white.withOpacity(0.25), size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Purchase a Pro Subscription \nto unlock this feature.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.25),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Get.to(() => HomeWidgetPro());
                      },
                      child: Text("Upgrade To Pro"),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    )
                  ]))));
  }
}

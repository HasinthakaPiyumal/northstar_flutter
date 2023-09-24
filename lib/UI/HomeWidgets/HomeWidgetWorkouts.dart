import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/AddWorkouts.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/GymWorkouts.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/SelectedUserWorkouts.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkout.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkoutFeedBack.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/WorkoutPresets.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../components/CircularProgressBar.dart';

class HomeWidgetWorkouts extends StatelessWidget {
  const HomeWidgetWorkouts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList workouts = [].obs;
    RxBool ready = false.obs;

    void getWorkouts() async {
      ready.value = false;
      Map res = await httpClient.getWorkout();
      if (res['code'] == 200) {
        workouts.value = res['data'];
        print(res['data']);
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void deleteWorkouts(int id) async {
      ready.value = false;
      await httpClient.deleteWorkout(id);
      getWorkouts();
    }

    getWorkouts();

    return Scaffold(
      floatingActionButton: authUser.role == 'trainer'
          ? Container(
              height: 44,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Get.to(() => AddWorkouts(workoutList: [], workoutID: -1))
                      ?.then((value) {
                    Future.delayed(Duration(milliseconds: 500), () {
                      getWorkouts();
                    });
                  });
                },
                icon: Icon(Icons.add, color: AppColors.textOnAccentColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), //
                  // Set the desired radius
                ),
                label: Text(
                  'Workout',
                  style: TextStyle(
                    color: Color(0xFF1B1F24),
                    fontSize: 20,
                    fontFamily: 'Bebas Neue',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                backgroundColor: AppColors.accentColor,
              ),
            )
          : null,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Workouts',
            style: TypographyStyles.title(20),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //authUser.role == 'trainer' ? SizedBox(height: 15) : SizedBox(),
            authUser.role == 'trainer'
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyles.matRadButton(
                                Get.isDarkMode
                                    ? AppColors.primary2Color
                                    : Colors.white,
                                0,
                                10),
                            onPressed: () {
                              Get.to(() => WorkoutPresets());
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 64,
                                    child: Image.asset(
                                        "assets/icons/my_workout.png"),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'My Workouts',
                                    style: TypographyStyles.text(16),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyles.matRadButton(
                                Get.isDarkMode
                                    ? AppColors.primary2Color
                                    : Colors.white,
                                0,
                                10),
                            onPressed: () {
                              Get.to(() => GymWorkouts());
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 64,
                                    child: Image.asset(
                                        "assets/icons/gym_bank.png"),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Gym Bank',
                                    style: TypographyStyles.text(16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),

            authUser.role == 'trainer' ? SizedBox(height: 20) : SizedBox(),

            authUser.role == 'trainer'
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text('Workout Dashboard',
                            style: TypographyStyles.title(20)),
                      ],
                    ),
                  )
                : SizedBox(),

            SizedBox(height: 15),

            Obx(
              () => ready.value
                  ? workouts.length > 0
                      ? authUser.role == 'trainer'
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ListView.builder(
                                itemCount: workouts.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (_, index) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Get.isDarkMode
                                                ? AppColors.primary2Color
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 500),
                                          width: (workouts[index]
                                                      ['completed_steps'] /
                                                  workouts[index]
                                                      ['totalSteps']) *
                                              Get.width,
                                          height: 95,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: Get.isDarkMode
                                                  ? [
                                                      //Color(0xFF3E8F00),
                                                      Color(0xFF6EBB35),
                                                      Color(0xFF3E8F00),
                                                    ]
                                                  : [
                                                      Color(0xFFB6FF92),
                                                      Color(0xFFB6FF92),
                                                    ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                  radius: 24,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                    HttpClient.s3BaseUrl +
                                                        workouts[index]['user']
                                                            ['avatar_url'],
                                                  )),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    workouts[index]['user']
                                                            ['name']
                                                        .toString(),
                                                    style: TypographyStyles.boldText(
                                                        14,
                                                        Get.isDarkMode
                                                            ? Themes
                                                                .mainThemeColorAccent
                                                                .shade100
                                                            : colors.Colors()
                                                                .lightBlack(1)),
                                                  ),
                                                  Text(
                                                    "Steps - ${workouts[index]['completed_steps']}/${workouts[index]['totalSteps']}",
                                                    style: TypographyStyles
                                                        .normalText(
                                                            14,
                                                            Get.isDarkMode
                                                                ? Themes
                                                                    .mainThemeColorAccent
                                                                    .shade100
                                                                : colors.Colors()
                                                                    .lightBlack(
                                                                        1)),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  width: 20,
                                                ),
                                              ),
                                              CircularProgressBar(
                                                  progress: workouts[index]
                                                          ['completed_steps']
                                                       /
                                                          workouts[index]
                                                              ['totalSteps'])
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 95,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () {
                                                Get.to(() =>
                                                    SelectedUserWorkouts(
                                                        clientID:
                                                            workouts[index]
                                                                    ['user']
                                                                ['id']));
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ListView.builder(
                                itemCount: workouts.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (_, index) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: workouts[index]
                                                          ['completed_steps'] ==
                                                      workouts[index]
                                                          ['steps'] &&
                                                  workouts[index]['feedback'] ==
                                                      null
                                              ? 145
                                              : 95,
                                          decoration: BoxDecoration(
                                            color: Get.isDarkMode
                                                ? colors.Colors().deepGrey(1)
                                                : colors.Colors()
                                                    .selectedCardBG,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 500),
                                          width: (workouts[index]
                                                      ['completed_steps'] /
                                                  workouts[index]['steps']) *
                                              Get.width,
                                          height: 95,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: Get.isDarkMode
                                                  ? [
                                                      //Color(0xFF3E8F00),
                                                      Color(0xFF6EBB35),
                                                      Color(0xFF3E8F00),
                                                    ]
                                                  : [
                                                      Color(0xFFB6FF92),
                                                      Color(0xFFB6FF92),
                                                    ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    workouts[index]['title']
                                                        .toString(),
                                                    style: TypographyStyles
                                                        .boldText(
                                                      14,
                                                      Get.isDarkMode
                                                          ? Themes
                                                              .mainThemeColorAccent
                                                              .shade100
                                                          : colors.Colors()
                                                              .lightBlack(1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Steps - ${workouts[index]['completed_steps']}/${workouts[index]['steps']}",
                                                    style: TypographyStyles
                                                        .normalText(
                                                      14,
                                                      Get.isDarkMode
                                                          ? Themes
                                                              .mainThemeColorAccent
                                                              .shade100
                                                          : colors.Colors()
                                                              .lightBlack(1),
                                                    ),
                                                  ),
                                                  Text(
                                                    " Progress ${(workouts[index]['completed_steps'] / workouts[index]['steps'] * 100).toStringAsFixed(0)}%",
                                                    style: TypographyStyles
                                                        .normalText(
                                                      14,
                                                      Get.isDarkMode
                                                          ? Themes
                                                              .mainThemeColorAccent
                                                              .shade100
                                                          : colors.Colors()
                                                              .lightBlack(1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 95,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () {
                                                Get.to(() => ViewWorkout(
                                                    workoutData:
                                                        workouts[index]))?.then(
                                                    (value) => {getWorkouts()});
                                              },
                                            ),
                                          ),
                                        ),
                                        workouts[index]['completed_steps'] ==
                                                    workouts[index]['steps'] &&
                                                workouts[index]['feedback'] ==
                                                    null
                                            ? Positioned(
                                                right: 8,
                                                bottom: 0,
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        ElevatedButton(
                                                            style: ButtonStyles
                                                                .bigBlackButton(),
                                                            onPressed: () {
                                                              Get.to(
                                                                  () =>
                                                                      ViewWorkoutFeedback(
                                                                        data: workouts[
                                                                            index],
                                                                        viewOnly:
                                                                            false,
                                                                      ))?.then(
                                                                  (value) =>
                                                                      getWorkouts());
                                                            },
                                                            child: Text(
                                                                'Add Feedback'))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                      : LoadingAndEmptyWidgets.emptyWidget()
                  : LoadingAndEmptyWidgets.loadingWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

// Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//
//     Text(
//       " Progress ${(workouts[index]['completed_steps'] / workouts[index]['totalSteps'] * 100).toStringAsFixed(0)}%",
//       style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
//     ),
//   ],
// ),

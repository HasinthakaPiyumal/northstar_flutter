import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/ClientsWorkoutsController.dart';
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
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/WorkoutDays.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/WorkoutPresets.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/components/Buttons.dart';

import '../../components/CircularProgressBar.dart';
import 'HomeWidgetWorkouts/AdminWorkoutPreset.dart';

class HomeWidgetWorkouts extends StatelessWidget {
  const HomeWidgetWorkouts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList workouts = [].obs;
    RxMap myWorkouts = {}.obs;
    RxList myTodayWorkouts = [].obs;
    RxBool ready = false.obs;
    RxBool showAddWorkoutToClient = false.obs;
    RxBool showClientWorkouts = true.obs;

    void getWorkouts() async {
      ready.value = false;
      Map res = await httpClient.getWorkout();
      Map res2 = await httpClient.getMyWorkout();
      await ClientsWorkoutsController.getClientsWorkouts();
      Map user = await httpClient.getMyProfile();
      print(user);
      if (user['code'] == 200) {
        showAddWorkoutToClient.value =
            user['data']['physical_trainer_id'] == null &&
                user['data']['diet_trainer_id'] == null;
      }

      if (res['code'] == 200) {
        if (authUser.role == 'trainer') {
          workouts.value = ClientsWorkoutsController.workouts;
          if (!(res2['data'] is List<dynamic>)) {
            if (res2['data'].entries.length > 0) {
              Map tempWorkouts = res2['data'];
              myWorkouts.value = res2['data'];
              if (tempWorkouts.isNotEmpty) {
                myTodayWorkouts.value = tempWorkouts.entries.first.value;
              }
            }
          }
        } else {
          if (!(res['data'] is List<dynamic>)) {
            print('Map');
            if (res['data'].entries.length > 0) {
              Map tempWorkouts = res['data'];
              myWorkouts.value = res['data'];
              if (tempWorkouts.isNotEmpty) {
                myTodayWorkouts.value = tempWorkouts.entries.first.value;
              }
            }
          }
        }
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
      floatingActionButton: Obx(() {
        if ((showAddWorkoutToClient.value && authUser.role == 'client') ||
            authUser.role == 'trainer') {
          return Container(
            height: 44,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.to(
                        () => AddWorkouts(workoutList: [], workoutID: -1))
                    ?.then((value) {
                  getWorkouts();
                });
                if (result != null) {
                  // Only if a result is returned, perform the following actions.
                  getWorkouts();
                }
              },
              icon: Icon(Icons.add, color: AppColors.textOnAccentColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
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
          );
        } else {
          return SizedBox(); // Return an empty widget if the condition is not met.
        }
      }),
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Exercise Bank',
            style: TypographyStyles.title(20),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //authUser.role == 'trainer' ? SizedBox(height: 15) : SizedBox(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Visibility(
                    visible: (showAddWorkoutToClient.value &&
                            authUser.role == 'client') ||
                        authUser.role == 'trainer',
                    child: Expanded(
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
                                child:
                                    Image.asset("assets/icons/my_workout.png"),
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
                  ),
                  Visibility(
                      visible: (showAddWorkoutToClient.value &&
                              authUser.role == 'client') ||
                          authUser.role == 'trainer',
                      child: SizedBox(width: 15)),
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
                              child: Image.asset("assets/icons/gym_bank.png"),
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
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Buttons.yellowFlatButton(
                  onPressed: () {
                    Get.to(() => AdminWorkoutPresets());
                  },
                  width: Get.width,
                  label: "Admin Preset"),
            ),

            SizedBox(height: 20),

            // Buttons.outlineButton(
            //   width: Get.width - 43,
            //   label: "Today My Workouts",
            //     onPressed: (){
            //       Get.to(() => ViewWorkout(
            //           workoutData:
            //           myTodayWorkouts[index]));
            // }),
            //
            // SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Workout Dashboard', style: TypographyStyles.title(20)),
                ],
              ),
            ),

            SizedBox(height: 15),
            Obx(
              () => Visibility(
                visible: authUser.role == 'trainer',
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0,left: 20,right: 20),
                  child: Row(
                    children: [
                      toggleButton(
                          label: "My Workouts",
                          onPressed: () {
                            showClientWorkouts.value = false;
                          },
                          isChecked: showClientWorkouts.value),
                      SizedBox(width: 10,),
                      toggleButton(
                          label: "Client Workouts",
                          onPressed: () {
                            showClientWorkouts.value = true;
                          },
                          isChecked: !showClientWorkouts.value),
                    ],
                  ),
                ),
              ),
            ),

            Obx(() => ready.value
                ? workouts.length > 0 || myTodayWorkouts.length > 0
                    ? authUser.role == 'trainer' && showClientWorkouts.value
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.builder(
                              itemCount: workouts.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (_, index) {
                                if(workouts[index]['user']['id']==authUser.id)return SizedBox();
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
                                                workouts[index]['totalSteps']) *
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
                                                        ['completed_steps'] /
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
                                              Get.to(() => SelectedUserWorkouts(
                                                  workoutsData: workouts[index],
                                                  index: index))?.then((value) {
                                                getWorkouts();
                                              });
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
                              itemCount: myTodayWorkouts.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Card(
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(() => ViewWorkout(
                                            workoutData:
                                                myTodayWorkouts[index]))?.then((value){
                                                  getWorkouts();
                                        });
                                      },
                                      onLongPress: () {
                                        CommonConfirmDialog.confirm('delete')
                                            .then((value) {
                                          if (value) {
                                            deleteWorkouts(
                                                myTodayWorkouts[index]['id']);
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            color: Get.isDarkMode
                                                ? AppColors.primary2Color
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    myTodayWorkouts[index]
                                                        ['title'],
                                                    style:
                                                        TypographyStyles.title(
                                                            16),
                                                  ),
                                                  Text(
                                                    'Steps ${myTodayWorkouts[index]['completed_steps']}/${myTodayWorkouts[index]['steps']}',
                                                    style:
                                                        TypographyStyles.text(
                                                            14),
                                                  ),
                                                  myTodayWorkouts[index][
                                                              'completed_steps'] ==
                                                          myTodayWorkouts[index]
                                                              ['steps']
                                                      ? Container(
                                                          height: 44,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .black,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .accentColor,
                                                                  elevation: 0,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20))),
                                                              onPressed: () {
                                                                Get.to(
                                                                    () =>
                                                                        ViewWorkoutFeedback(
                                                                          data:
                                                                              myTodayWorkouts[index],
                                                                          viewOnly:
                                                                              false,
                                                                        ))?.then(
                                                                    (value) {
                                                                  getWorkouts();
                                                                });
                                                              },
                                                              child: Text(
                                                                'Add Feedback',
                                                                style: TextStyle(
                                                                    color: AppColors
                                                                        .textOnAccentColor),
                                                              )),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                              CircularProgressBar(
                                                  progress: myTodayWorkouts[
                                                              index]
                                                          ['completed_steps'] /
                                                      myTodayWorkouts[index]
                                                          ['steps'])
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                    : LoadingAndEmptyWidgets.emptyWidget()
                : LoadingAndEmptyWidgets.loadingWidget()),
            SizedBox(
              height: 100,
            )
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

class DummyData {
  Map data = {
    "2024-11-24": [{}]
  };
}

Widget toggleButton({required onPressed, required isChecked, required label}) {
  return isChecked
      ? Buttons.outlineButton(onPressed: onPressed, label: label, height: 30,width: 120,fontSize: 14)
      : Buttons.yellowFlatButton(
          onPressed: onPressed, label: label, height: 34,width: 140,fontSize: 18);
}

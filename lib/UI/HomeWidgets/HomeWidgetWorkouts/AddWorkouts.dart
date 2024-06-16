import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';

class AddWorkouts extends StatelessWidget {
  const AddWorkouts(
      {Key? key, required this.workoutList, required this.workoutID})
      : super(key: key);

  final List workoutList;
  final int workoutID;

  @override
  Widget build(BuildContext context) {
    RxList workoutPlan = [].obs;
    String title = '';
    String description = '';
    int days = 0;
    String lastUpdatedDate = '';
    RxList selectedUsers = authUser.role == 'client' ? [authUser].obs : [].obs;
    RxBool ready = false.obs;

    Future<List> searchWorkoutPresets(pattern) async {
      Map res = await httpClient.searchWorkoutPresets(pattern);

      if (res['code'] == 200) {
        return res['data'];
      } else {
        print(res['data']);
        return [];
      }
    }

    Future<List> searchClient(pattern) async {
      Map res = await httpClient.searchMembers(pattern,onlyPrimary: true);
      if (res['code'] == 200) {
        return res['data'];
      } else {
        print(res['data']);
        return [];
      }
    }

    void saveWorkout() async {
      ready.value = false;
      bool success = false;
      for (Map element in selectedUsers) {
        Map res = await httpClient.addWorkout({
          'workout_id': workoutID.toString(),
          'workouts': json.encode(workoutPlan),
          'count': workoutPlan.length.toString(),
          'client_name': element['name'].toString(),
          'client_email': element['email'].toString(),
          'user_id': element['id'],
          'trainer_id': authUser.id,
          'title': title,
          'description': description,
          'day_count':days
        });

        if (res['code'] == 200) {
          print(res['data']);
          success = true;
        } else {
          print(res['data']);
          showSnack("Something went wrong", res['data']['error']);
          return;
        }

        httpClient.sendNotification(
            element['id'],
            'New Workout Schedule Assigned!',
            'You have a new workout schedule assigned to you!',
            NSNotificationTypes.WorkoutsAssigned, {});
      }

      if (success) {
        Get.back();
        showSnack('Success!', 'Schedule has been added.');
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void addToMe() async {
      ready.value = false;
      bool success = false;

      Map res = await httpClient.addWorkout({
        'workout_id': workoutID.toString(),
        'workouts': json.encode(workoutPlan),
        'count': workoutPlan.length.toString(),
        'client_name': authUser.name.toString(),
        'client_email': authUser.email.toString(),
        'user_id': authUser.id,
        'trainer_id': authUser.id,
        'title': title,
        'description': description,
        'day_count':days
      });

      if (res['code'] == 200) {
        print('httpClient.addWorkout');
        print(res['data']);
        success = true;
      } else {
        print(res['data']);
      }

      httpClient.sendNotification(
          authUser.id,
          'New Workout Schedule Assigned!',
          'You have a new workout schedule assigned to you!',
          NSNotificationTypes.WorkoutsAssigned, {});

      if (success) {
        Get.back();
        showSnack('Success!', 'Schedule has been added.');
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          authUser.role == 'trainer' ? 'Share Workout' : 'Add Workout',
          style: TypographyStyles.title(20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Workout Preset',
                    style: TypographyStyles.boldText(
                      16,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade500
                          : colors.Colors().lightBlack(1),
                    )),
                Obx(
                  () => Visibility(
                    child: InkWell(
                      onTap: () {
                        workoutPlan.clear();
                      },
                      child: Text(
                        "Clear",
                        style: TypographyStyles.boldText(
                            16, Themes.mainThemeColor.shade500),
                      ),
                    ),
                    visible: workoutPlan.isNotEmpty,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Obx(() => workoutPlan.isNotEmpty
                ? Container(
                    padding: EdgeInsets.fromLTRB(15, 8, 8, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Get.isDarkMode
                          ? colors.Colors().deepGrey(1)
                          : colors.Colors().selectedCardBG,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TypographyStyles.boldText(
                                    16,
                                    Get.isDarkMode
                                        ? Themes.mainThemeColorAccent.shade100
                                        : colors.Colors().lightBlack(1)),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Last Edit - " +
                                    (DateFormat("dd/MM/yyyy HH:mm").format(
                                            DateTime.parse(Utils.dateFormat(
                                                lastUpdatedDate))))
                                        .toString(),
                                style: TypographyStyles.normalText(
                                    14,
                                    Get.isDarkMode
                                        ? Themes.mainThemeColorAccent.shade500
                                        : colors.Colors().deepGrey(1)),
                              ),
                            ]),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Workouts',
                                  style: TypographyStyles.boldText(
                                      12, Themes.mainThemeColorAccent.shade100),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  '${NumberFormat('00').format(workoutPlan.length)}',
                                  style: TypographyStyles.boldText(
                                      20, Themes.mainThemeColorAccent.shade100),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : TypeAheadField(
                    hideOnEmpty: true,
                    hideOnError: true,
                    hideOnLoading: true,
                    textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Workout Presets...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    )),
                    suggestionsCallback: (pattern) async {
                      print(pattern);
                      return await searchWorkoutPresets(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      var jsonObj = jsonDecode(jsonEncode(suggestion));

                      return Container(
                        height: 96,
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                tileColor: Colors.transparent,
                                title: Text(jsonObj['title']),
                                subtitle: Text(jsonObj['description']),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      Map jsonObj = jsonDecode(jsonEncode(suggestion));
                      print(jsonObj);
                      title = jsonObj['title'];
                      description = jsonObj['description'];
                      days = jsonObj['day_count'];
                      lastUpdatedDate = jsonObj['updated_at'];
                      List workouts = jsonObj['workout_plan'];
                      workouts.forEach((element) {
                        element['repetitions'] = 1;
                        element['has_completed'] = false;
                      });
                      workoutPlan.value = workouts;
                    },
                  )),
            SizedBox(
              height: 25,
            ),
            Visibility(
                visible: authUser.role == 'trainer',
                child: Text('Add Member',
                    style: TypographyStyles.boldText(
                      16,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade500
                          : colors.Colors().lightBlack(1),
                    ))),
            Visibility(
                visible: authUser.role == 'trainer',
                child: SizedBox(height: 16)),
            authUser.role == 'trainer'
                ? TypeAheadField(
                    hideOnEmpty: true,
                    hideOnError: true,
                    hideOnLoading: true,
                    textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Members...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    )),
                    suggestionsCallback: (pattern) async {
                      print(pattern);
                      return await searchClient(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      var jsonObj = jsonDecode(jsonEncode(suggestion));

                      return Container(
                        padding: const EdgeInsets.all(8),
                        height: 64,
                        child: Row(
                          children: [
                            CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                              HttpClient.s3BaseUrl +
                                  jsonObj['user']['avatar_url'],
                            )),
                            Expanded(
                              child: ListTile(
                                tileColor: Colors.transparent,
                                title: Text(jsonObj['user']['name']),
                                // subtitle: Text(jsonObj['calories'].toString() + ' Cals'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      var jsonObj = jsonDecode(jsonEncode(suggestion));
                      var doesExist = selectedUsers.firstWhereOrNull(
                          (element) => element['id'] == jsonObj['user_id']);
                      if (doesExist == null) {
                        print(jsonObj['user']);
                        selectedUsers.add(jsonObj['user']);
                      } else {
                        showSnack(
                            'User Already Selected', 'User already selected');
                      }
                    },
                  )
                : SizedBox(),
            SizedBox(height: 16),
            Visibility(
              visible: authUser.role == 'trainer',
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: selectedUsers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Get.isDarkMode
                                ? Colors.black
                                : colors.Colors().selectedCardBG,
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      HttpClient.s3BaseUrl +
                                          selectedUsers[index]['avatar_url'],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        selectedUsers[index]['name'],
                                        style: TypographyStyles.boldText(
                                            16,
                                            Get.isDarkMode
                                                ? Themes.mainThemeColorAccent
                                                    .shade100
                                                : colors.Colors()
                                                    .lightBlack(1)),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        selectedUsers[index]['email'],
                                        style: TypographyStyles.normalText(
                                            14,
                                            Get.isDarkMode
                                                ? Themes.mainThemeColorAccent
                                                    .shade300
                                                : colors.Colors()
                                                    .lightBlack(1)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  selectedUsers.removeAt(index);
                                },
                                icon: Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          height: 44,
          child: ElevatedButton(
            style: ButtonStyles.primaryButton(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                  child: Image.asset(
                    'assets/icons/share.png',
                    color: AppColors.textOnAccentColor,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  authUser.role == 'client' ? 'ADD TO ME' : 'SHARE TO MEMBERS',
                  style: TextStyle(
                      fontSize: 20, color: AppColors.textOnAccentColor),
                ),
              ],
            ),
            onPressed: () {
              print(selectedUsers);
              if (workoutPlan.length > 0 && selectedUsers.length > 0) {
                if (authUser.role == 'client') {
                  addToMe();
                } else {
                  saveWorkout();
                }
              } else {
                showSnack(
                    'Workouts List Empty', 'Please add workouts to continue');
              }
            },
          ),
        ),
      ),
    );
  }
}

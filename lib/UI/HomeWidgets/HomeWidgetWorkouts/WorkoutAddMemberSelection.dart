import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../../Models/AuthUser.dart';
import '../../../Models/HttpClient.dart';
import '../../../Utils/PopUps.dart';

class WorkoutAddMemberSelection extends StatelessWidget {
  WorkoutAddMemberSelection({required this.presetCalender});
  final List presetCalender;
  final DateFormat formatter = DateFormat('yyyy/MM/dd');
  RxList selectedUsers = authUser.role == 'client' ? [
          authUser.user
        ].obs : [].obs;
  RxBool ready = true.obs;
  @override
  Widget build(BuildContext context) {
    Future<List> searchClient(pattern) async {
      Map res = await httpClient.searchMembers(pattern, onlyPrimary: true);
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

      List formattedCalendar = presetCalender.map((date) {
        return {
          'date': formatter.format(DateTime.parse(date['date'])),
          'preset_id': date['isRestDate']
              ? []
              : date['presets'].map((preset) => preset['presetId']).toList()
        };
      }).toList();

      print(formattedCalendar);
      Map res = await httpClient.addWorkout(
          {'selecte_users': selectedUsers.map((user)=>user['id']).toList(), 'workouts': formattedCalendar,'trainer_id':authUser.id});

      if (res['code'] == 200) {
        print(res['data']);
        success = true;
      } else {
        print(res['data']);
        showSnack("Something went wrong", res['data']['error'], status: PopupNotificationStatus.error);
        return;
      }
      for (Map element in selectedUsers) {
        httpClient.sendNotification(
            element['id'],
            'New Workout Schedule Assigned!',
            'You have a new workout schedule assigned to you!',
            NSNotificationTypes.WorkoutsAssigned, {});
      }

      if (success) {
        Get.back();
        Get.back();
        showSnack('Success!', 'Schedule has been added.', status: PopupNotificationStatus.success);
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    if(authUser.role=='client'){
      saveWorkout();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Share To Member'),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            authUser.role=='client'?SizedBox():TypeAheadField(
              hideOnEmpty: true,
              hideOnError: true,
              hideOnLoading: true,
              builder: (context, controller, focusNode) {
                return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Members...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ));
              },
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
                        HttpClient.s3BaseUrl + jsonObj['user']['avatar_url'],
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
              onSelected: (suggestion) {
                var jsonObj = jsonDecode(jsonEncode(suggestion));
                var doesExist = selectedUsers.firstWhereOrNull(
                    (element) => element['id'] == jsonObj['user_id']);
                if (doesExist == null) {
                  print(jsonObj['user']);
                  selectedUsers.add(jsonObj['user']);
                } else {
                  showSnack('User Already Selected', 'User already selected');
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
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
                                ? AppColors.primary2Color
                                : Colors.white,
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
              if (selectedUsers.length > 0) {
                saveWorkout();
              } else {
                showSnack('Member List Empty', 'Please add Members to continue',
                    status: PopupNotificationStatus.warning);
              }
            },
          ),
        ),
      ),
    );
  }
}

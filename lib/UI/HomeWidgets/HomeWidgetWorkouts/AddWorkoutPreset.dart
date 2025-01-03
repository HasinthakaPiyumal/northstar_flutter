import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/DropDownButtonWithBorder.dart';

import '../../../Styles/AppColors.dart';

class AddWorkoutPreset extends StatelessWidget {
  const AddWorkoutPreset({Key? key, this.editWorkoutObject}) : super(key: key);
  final editWorkoutObject;

  @override
  Widget build(BuildContext context) {
    ScrollController _scroll = new ScrollController();

    RxList workouts = [].obs;
    RxBool ready = false.obs;

    print(editWorkoutObject);

    TextEditingController title = TextEditingController();
    TextEditingController description = TextEditingController();
    TextEditingController days = TextEditingController();

    Future<List> searchWorkouts(pattern) async {
      Map res = await httpClient.searchWorkouts(pattern);
      print(res['data']);
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
      int id = -99;
      if (editWorkoutObject != null) {
        id = editWorkoutObject['id'];
      }
      String jsonString = jsonEncode(workouts.value);
      print("===== jsonString");
      print(workouts);
      Map res = await httpClient.addOrEditWorkoutPresets({
        'workout_plan': json.encode(workouts.value),
        'trainer_id': authUser.id,
        'title': title.text,
        'description': description.text,
        'workout_id': id,
        'day_count': workouts.length
      });

      if (res['code'] == 200) {
        print(res['data']);
        success = true;
      } else {
        print(res['data']);
      }

      if (success) {
        Get.back();
        showSnack('Success!', 'Schedule has been added.');
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void fillIfEditMode() {
      if (editWorkoutObject != null) {
        title.text = editWorkoutObject['title'];
        description.text = editWorkoutObject['description'];
        // days.text = editWorkoutObject['day_count'].toString();
        workouts.value = editWorkoutObject['workout_plan'];
      }
    }

    String checkNullGetOne(String? value) {
      if (value == null || value == 'null') {
        return '1';
      } else {
        return value;
      }
    }

    fillIfEditMode();

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Add Preset',
            style: TypographyStyles.title(20),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => !ready.value
                  ? TextButton(
                      onPressed: () {
                        if (workouts.length > 0 &&
                            title.text.isNotEmpty &&
                            description.text.isNotEmpty) {
                          saveWorkout();
                        } else {
                          showSnack('Fill All the Fields!',
                              'Please fill all the fields to continue');
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: AppColors.accentColor),
                      ))
                  : LoadingAndEmptyWidgets.loadingWidget()),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(height: 4),
                  TextField(
                    controller: title,
                    maxLength: 250,
                    decoration: InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: description,
                    maxLength: 250,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  // SizedBox(height: 25),
                  // Obx(
                  //   () => TextField(
                  //     controller: days,
                  //     keyboardType: TextInputType.number,
                  //     decoration: InputDecoration(labelText: 'Days'),
                  //     enabled: workouts.isEmpty,
                  //     onTap: () {
                  //       if (workouts.isNotEmpty) {
                  //         showSnack("Can't edit days count",
                  //             "You can not edit when workout created. Please clear workouts to edit day count");
                  //       }
                  //     },
                  //   ),
                  // ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Text(
                        "Add Workouts",
                        style: TypographyStyles.boldText(
                          16,
                          Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade100
                              : colors.Colors().lightBlack(1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  TypeAheadField(
                    hideOnEmpty: true,
                    hideOnError: true,
                    hideOnLoading: true,
                    builder: (context, controller, focusNode) {
                      return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Search Workouts...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ));
                    },
                    suggestionsCallback: (pattern) async {
                      return await searchWorkouts(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      var jsonObj = jsonDecode(jsonEncode(suggestion));
                      print(jsonObj);
                      return Container(
                        height: 96,
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: HttpClient.s3ResourcesBaseUrl +
                                  jsonObj['preview_animation_url'],
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                            ),
                            Expanded(
                              child: ListTile(
                                tileColor: Colors.transparent,
                                title: Text(jsonObj['title']),
                                // subtitle: Text(jsonObj['calories'].toString() + ' Cals'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    onSelected: (suggestion) {
                      var jsonObj = jsonDecode(jsonEncode(suggestion));
                      var already = workouts.firstWhereOrNull(
                          (element) => element['id'] == jsonObj['id']);
                      if (already == null) {
                        jsonObj['repetitions'] = 1;
                        jsonObj['sets'] = 1;
                        jsonObj['weight'] = 50;
                        jsonObj['day'] = 1;
                        jsonObj['has_completed'] = false;
                        workouts.add(jsonObj);
                        print(jsonObj);
                      } else {
                        showSnack(
                            'Warning!', 'Exercise is Already in the Workout!');
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Obx(() => ListView.builder(
                        shrinkWrap: true,
                        controller: _scroll,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          RxBool isExpanded = false.obs;
                          void onChangeExpansion(val){
                              isExpanded.value = val;
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: ExpansionTile(
                              onExpansionChanged: onChangeExpansion,
                              showTrailingIcon: false,
                              collapsedBackgroundColor:Colors.transparent,
                              backgroundColor: Get.isDarkMode
                                  ? AppColors.primary2Color
                                  : Colors.white,
                              collapsedIconColor: AppColors.textOnAccentColor,
                              iconColor: AppColors.textOnAccentColor,
                              tilePadding: EdgeInsets.zero,
                              title: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: AppColors.accentColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(workouts[index]['title'],
                                          textAlign: TextAlign.center,
                                          style: TypographyStyles.title(18)
                                              .copyWith(
                                                  color: AppColors
                                                      .textOnAccentColor)),
                                      Obx(()=> Icon(isExpanded.value?Icons.keyboard_arrow_up_rounded:Icons.keyboard_arrow_down_rounded))
                                    ],
                                  )),
                              children: [
                                SizedBox(height: 8),
                                ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: HttpClient.s3ResourcesBaseUrl +
                                          workouts[index]
                                              ['preview_animation_url'],
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                    ),
                                  ),
                                  title: Text(
                                    workouts[index]['title'],
                                    style: TypographyStyles.title(16),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.highlight_remove_rounded,
                                        color: Colors.red),
                                    onPressed: () {
                                      workouts.removeAt(index);
                                    },
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                              text: workouts[index]
                                                      ['repetitions']
                                                  .toString()),
                                          keyboardType: TextInputType.number,
                                          onChanged: (newValue) {
                                            workouts[index]['repetitions'] =
                                                int.parse(newValue);
                                          },
                                          cursorColor: Colors.black,
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            labelText: 'Reps',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                              text: checkNullGetOne(
                                                  workouts[index]['weight']
                                                      .toString())),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          onChanged: (newValue) {
                                            workouts[index]['weight'] =
                                                double.parse(newValue);
                                          },
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            labelText: 'Weight (kg)',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                              text: checkNullGetOne(
                                                  workouts[index]['sets']
                                                      .toString())),
                                          keyboardType: TextInputType.number,
                                          onChanged: (newValue) {
                                            workouts[index]['sets'] =
                                                int.parse(newValue);
                                          },
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            labelText: 'Sets',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10),
                                  child: TextField(
                                    controller: TextEditingController(
                                        text: workouts[index]['notes'] ?? '1'),
                                    onChanged: (newValue) {
                                      workouts[index]['notes'] = newValue;
                                    },
                                    decoration: InputDecoration(
                                      border: UnderlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      labelText: 'Notes',
                                    ),
                                  ),
                                ),
                                // Container(
                                //   decoration: BoxDecoration(
                                //       color: AppColors.accentColor,
                                //       borderRadius: BorderRadius.only(
                                //           bottomLeft: Radius.circular(10),
                                //           bottomRight: Radius.circular(10))),
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 15.0, vertical: 10),
                                //     child: Row(
                                //       children: [
                                //         Text(
                                //           "Day: ",
                                //           style: TypographyStyles.title(16)
                                //               .copyWith(
                                //                   color: AppColors
                                //                       .textOnAccentColor),
                                //         ),
                                //         SizedBox(
                                //           width: 20,
                                //         ),
                                //         // Expanded(
                                //         //   child: DropdownButtonWithBorder(
                                //         //     items: List.generate(
                                //         //         int.parse(days.text.isEmpty
                                //         //             ? '1'
                                //         //             : days.text),
                                //         //         (index) =>
                                //         //             (index + 1).toString()),
                                //         //     selectedValue: workouts[index]
                                //         //             ['day']
                                //         //         .toString(),
                                //         //     onChanged: (String val) {
                                //         //       print("printing date ${val}");
                                //         //       workouts[index]['day'] =
                                //         //           int.parse(val);
                                //         //     },
                                //         //     color:
                                //         //         AppColors.textOnAccentColor,
                                //         //     backgroundColor: Colors.white,
                                //         //     width: Get.width,
                                //         //   ),
                                //         // ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                SizedBox(height: 4),
                              ],
                            ),
                          );
                        },
                      )),
                ],
              ),
            ),
          ),
        ));
  }
}

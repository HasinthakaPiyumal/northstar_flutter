import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/WorkoutAddMemberSelection.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:north_star/components/MaterialBottomSheet.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddWorkouts extends StatelessWidget {
  AddWorkouts({Key? key, required this.workoutList, required this.workoutID})
      : super(key: key);

  final List workoutList;
  final int workoutID;

  Rxn<DateTime> selectedStartDate = Rxn<DateTime>();
  Rxn<DateTime> selectedEndDate = Rxn<DateTime>();

  RxList presetCalender = [].obs;
  bool isDateSettedProgrammatically = false;

  final DateRangePickerController _controller = DateRangePickerController();

  @override
  Widget build(BuildContext context) {
    void preparePresetCalender() {
      print(selectedStartDate.value == null || selectedEndDate.value == null);
      print(selectedStartDate.value);
      print(selectedEndDate.value);
      if (selectedStartDate.value == null || selectedEndDate.value == null) {
        return;
      }
      DateTime currentDate = selectedStartDate.value!;

      presetCalender.clear();

      while (currentDate.isBefore(selectedEndDate.value!) ||
          currentDate.isAtSameMomentAs(selectedEndDate.value!)) {
        presetCalender.add({
          'date': currentDate.toIso8601String(),
          'presets': null,
          'presetTitle': null,
          'presetDescription': null,
          'isRestDate': null,
        });

        currentDate = currentDate.add(Duration(days: 1));
      }
    }

    void setPresetDate({
      required dynamic date,
      String? title,
      String? description,
      List? presets,
    }) {
      // Determine if it's a rest date
      bool isRestDate =
          (title == null && description == null && presets == null)
              ? true
              : false;
      date = DateTime.parse(date);
      // Find the index of the date in presetCalender
      int index = presetCalender.indexWhere(
          (element) => DateTime.parse(element['date']).isAtSameMomentAs(date));

      if (index != -1) {
        // If the date exists, update its properties
        presetCalender[index] = {
          'date': date.toIso8601String(),
          'presets': presets,
          'presetTitle': title,
          'presetDescription': description,
          'isRestDate': isRestDate,
        };
      } else {
        // If the date does not exist, add a new entry
        presetCalender.add({
          'date': date.toIso8601String(),
          'presets': presets,
          'presetTitle': title,
          'presetDescription': description,
          'isRestDate': isRestDate,
        });
      }
    }

    void openPresetPane(date) {
      print(date);
      MaterialBottomSheet(
          DateFormat('MMMM d, yyyy').format(DateTime.parse(date['date'])),
          child: WorkoutPresetPicker(
            prevPresets: date['presets'] ?? [],
            onPick: ({
              required presets,
              required description,
              required title,
            }) {
              setPresetDate(
                  date: date['date'],
                  title: title,
                  presets: presets,
                  description: description);
            },
          ));
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date Range',
                style: TypographyStyles.title(18),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Get.isDarkMode
                        ? AppColors.primary2Color
                        : AppColors.primary2ColorLight),
                child: SfDateRangePicker(
                  controller: _controller,
                  initialSelectedRange: null,
                  minDate: DateTime.now(),
                  // ca
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) async {

                    if (!isDateSettedProgrammatically) {

                      bool canSetCalender = true;
                      presetCalender.forEach((currentPreset) {
                        if (currentPreset['presets'] != null ||
                            currentPreset['isRestDate'] != null) {
                          canSetCalender = false;
                        }
                      });
                      if (!canSetCalender) {
                        canSetCalender = await CommonConfirmDialog.confirm(
                            "Yes",
                            message:
                                'Are you sure you want to clear all current calendar dates and set new dates?');
                      }

                      if (canSetCalender) {
                        if (args.value is PickerDateRange) {
                          print("=======args");
                          print(args);
                          print(canSetCalender);
                          selectedStartDate.value =
                              args.value.startDate ?? DateTime.now();
                          selectedEndDate.value =
                              args.value.endDate ?? args.value.startDate ??DateTime.now();
                        }
                        preparePresetCalender();
                      } else {
                        isDateSettedProgrammatically = true;
                        _controller.selectedRange = PickerDateRange(
                          selectedStartDate.value,
                          selectedEndDate.value,
                        );
                      }
                    }else{
                      isDateSettedProgrammatically = false;
                    }
                  },

                  monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle: TypographyStyles.text(16),
                    disabledDatesTextStyle: TypographyStyles.text(16),
                    todayTextStyle:
                        TypographyStyles.normalText(16, AppColors.accentColor),
                  ),
                  selectionMode: DateRangePickerSelectionMode.extendableRange,
                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: Colors.transparent,
                    textStyle: TypographyStyles.boldText(
                      20,
                      Get.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  showNavigationArrow: true,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Add Preset Calender',
                style: TypographyStyles.title(18),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(
                () => ListView.builder(
                    itemCount: presetCalender.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      dynamic date = presetCalender[index];
                      return GestureDetector(
                        onTap: () {
                          openPresetPane(date);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Get.isDarkMode
                                ? AppColors.primary2Color
                                : AppColors.primary2ColorLight,
                          ),
                          child: Row(children: [
                            Container(
                              height: 54,
                              width: 68,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: date['presets'] != null
                                      ? AppColors.accentColor
                                      : AppColors.blue),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat.MMM()
                                          .format(DateTime.parse(date['date']))
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: TypographyStyles.text(16).copyWith(
                                        color: AppColors.textOnAccentColor,
                                        height: 1.25,
                                      ),
                                    ),
                                    Text(
                                      DateTime.parse(date['date'])
                                          .day
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: TypographyStyles.title(18)
                                          .copyWith(
                                              color:
                                                  AppColors.textOnAccentColor,
                                              height: 1.25),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      date['presetTitle'] != null
                                          ? date['presetTitle']
                                          : date['isRestDate'] != null
                                              ? date['isRestDate']
                                                  ? 'Rest Day'
                                                  : 'Empty for now'
                                              : 'Empty for now',
                                      style: TypographyStyles.text(18),
                                      overflow: TextOverflow.ellipsis),
                                  Visibility(
                                      visible:
                                          date['presetDescription'] != null,
                                      child: Text(
                                          date['presetDescription'] ?? '-',
                                          style: TypographyStyles.text(14),
                                          overflow: TextOverflow.ellipsis))
                                ],
                              ),
                            ),
                            Buttons.iconButton(
                                icon: Icons.add,
                                iconColor: AppColors.textOnAccentColor,
                                iconSize: 24,
                                padding: 4,
                                backgroundColor: date['presets'] != null
                                    ? AppColors.accentColor
                                    : AppColors.blue,
                                onPressed: () {
                                  openPresetPane(date);
                                }),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                CommonConfirmDialog.confirm('Make Rest Day')
                                    .then((value) {
                                  if (value) {
                                    setPresetDate(date: date['date']);
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: date['isRestDate'] != null &&
                                          date['isRestDate']
                                      ? AppColors.accentColor
                                      : AppColors.blue,
                                ),
                                padding: EdgeInsets.all(10),
                                child: SvgPicture.asset("assets/svgs/zzz.svg"),
                              ),
                            )
                          ]),
                        ),
                      );
                    }),
              )
            ],
          ),
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
              if (presetCalender.length>0) {
                bool canGoFurther = true;
                presetCalender.forEach((currentPreset) {
                  if (currentPreset['presets'] == null &&
                      currentPreset['isRestDate'] == null) {
                    canGoFurther = false;
                  }
                });
                if(canGoFurther) {
                  Get.to(() => WorkoutAddMemberSelection(
                      presetCalender: presetCalender));
                }else{
                showSnack(
                    'Empty days', 'Please assign either a rest day or a workout day to all days.',status: PopupNotificationStatus.warning);
              }
              }else{
                showSnack(
                    'Preset Calendar Empty', 'Please add Presets to continue',status: PopupNotificationStatus.warning);
              }
            },
          ),
        ),
      ),
    );
  }
}

class WorkoutPresetPicker extends StatelessWidget {
  WorkoutPresetPicker({required this.onPick, required this.prevPresets});
  final Function onPick;
  final List prevPresets;

  RxList presets = [].obs;
  bool isSetPresets = false;
  @override
  Widget build(BuildContext context) {
    if (!isSetPresets) {
      presets.addAll(prevPresets);
      isSetPresets = true;
    }

    final double totalHeight = context.mediaQuerySize.height;
    final double keyboardHeight = context.mediaQueryViewInsets.bottom;
    final double availableHeight = totalHeight - keyboardHeight;

    Future<List> searchWorkoutPresets(pattern) async {
      Map res = await httpClient.searchWorkoutPresets(pattern);
      if (res['code'] == 200) {
        return res['data'];
      } else {
        print(res['data']);
        return [];
      }
    }

    return Container(
      height: availableHeight - 200,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  labelText: 'Search Workout Presets...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ));
          },
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
          onSelected: (suggestion) {
            print(suggestion);
            Map jsonObj = jsonDecode(jsonEncode(suggestion));
            Map preset = {};
            preset['title'] = jsonObj['title'];
            preset['description'] = jsonObj['description'];
            preset['presetId'] = jsonObj['id'];
            preset['workout_count'] = jsonObj['workout_plan'].length;
            var doesExist = presets.firstWhereOrNull(
                (element) => element['presetId'] == jsonObj['id']);
            if (doesExist == null) {
              print(presets);
              presets.add(preset);
              print(presets);
            } else {
              showSnack('Invalid preset', 'This preset already exist.');
            }
          },
        ),
        SizedBox(
          height: 20,
        ),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  presets.isEmpty ? 'No Preset Selected Yet' : 'Added Preset',
                  style: TypographyStyles.text(16),
                ),
                TextButton(
                    child: Text(
                      'Clear',
                    ),
                    onPressed: () {
                      CommonConfirmDialog.confirm('clear presets')
                          .then((value) {
                        if (value) {
                          presets.clear();
                        }
                      });
                    })
              ],
            )),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Obx(
              () => Visibility(
                  visible: presets.isNotEmpty,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: presets.length,
                    itemBuilder: (context, index) {
                      Map preset = presets[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: Get.width - 35,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? AppColors.primary1Color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${preset['title']}',
                                    style: TypographyStyles.title(18),
                                  ),
                                  Text(
                                    '${preset['description']}',
                                    style: TypographyStyles.text(16),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.greenAccent),
                              child: Column(
                                children: [
                                  Text(
                                    'Workout',
                                    style: TypographyStyles.text(14).copyWith(
                                        color: AppColors.textOnAccentColor),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    preset['workout_count'].toString(),
                                    style: TypographyStyles.title(18).copyWith(
                                        color: AppColors.textOnAccentColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
                child: Buttons.outlineButton(
                    onPressed: () {
                      Get.back();
                    },
                    label: "Close")),
            SizedBox(
              width: 20,
            ),
            Expanded(
                child: Buttons.yellowFlatButton(
                    onPressed: () {
                      if (presets.isNotEmpty) {
                        print(presets);
                        onPick(
                          title: presets.length > 1
                              ? '${presets.length} Presets Selected'
                              : presets[0]['title'],
                          description: presets.length > 1
                              ? 'Tap to view'
                              : presets[0]['description'],
                          presets: presets,
                        );
                        Get.back();
                      } else {
                        showSnack('Invalid', 'Please select a preset.',
                            status: PopupNotificationStatus.error);
                      }
                    },
                    label: "Save")),
          ],
        )
      ]),
    );
  }
}

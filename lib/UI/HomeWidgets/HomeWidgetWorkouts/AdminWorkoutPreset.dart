import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/AddWorkoutPreset.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../../Styles/AppColors.dart';

class AdminWorkoutPresets extends StatelessWidget {
  const AdminWorkoutPresets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList workoutPresets = [].obs;

    void getWorkoutPresets() async {
      Map res = await httpClient.getAdminWorkoutPresets();
      if (res['code'] == 200) {
        print(res['data']);
        workoutPresets.value = res['data'];
      }
      ready.value = true;
    }

    getWorkoutPresets();

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Admin Presets',
            style: TypographyStyles.title(20),
          )),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ready.value
                ? workoutPresets.isNotEmpty
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: workoutPresets.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Get.to(() => AddWorkoutPreset(
                              editWorkoutObject:
                              workoutPresets[index]));
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 8, 8, 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workoutPresets[index]['title'],
                                      style:
                                      TypographyStyles.boldText(
                                        16,
                                        Get.isDarkMode
                                            ? Themes
                                            .mainThemeColorAccent
                                            .shade100
                                            : colors.Colors()
                                            .lightBlack(1),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Last Edit - " +
                                          (DateFormat("dd/MM/yyyy HH:mm")
                                              .format(DateTime.parse(
                                              Utils.dateFormat(
                                                  workoutPresets[
                                                  index]
                                                  [
                                                  'updated_at']))))
                                              .toString(),
                                      style:
                                      TypographyStyles.normalText(
                                        14,
                                        Get.isDarkMode
                                            ? Themes
                                            .mainThemeColorAccent
                                            .shade500
                                            : colors.Colors()
                                            .lightBlack(1),
                                      ),
                                    ),
                                  ]),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF67FB7F),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 80,
                                  width: 90,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Workouts',
                                          style:  TextStyle(
                                            color: Color(0xFF1B1F24),
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          )),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Text(
                                        '${NumberFormat('00').format(workoutPresets[index]['workout_plan'].length)}',
                                        style:TextStyle(
                                          color: Color(0xFF1B1F24),
                                          fontSize: 20,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
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
          ),
        ],
      ),
    );
  }
}

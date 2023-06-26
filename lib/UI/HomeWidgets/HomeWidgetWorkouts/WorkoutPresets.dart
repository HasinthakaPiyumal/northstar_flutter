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

class WorkoutPresets extends StatelessWidget {
  const WorkoutPresets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList workoutPresets = [].obs;

    void getWorkoutPresets() async {
      Map res = await httpClient.getWorkoutPresets();
      if (res['code'] == 200) {
        print(res['data']);
        workoutPresets.value = res['data'];
      }
      ready.value = true;
    }

    getWorkoutPresets();

    return Scaffold(
      appBar: AppBar(title: Text('Workout Presets')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ElevatedButton(
              style: Get.isDarkMode ? ButtonStyles.bigBlackButton() : ButtonStyles.matButton(colors.Colors().lightCardBG, 1),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add,
                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      'CREATE NEW PRESET',
                      style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                Get.to(AddWorkoutPreset())?.then((value) => getWorkoutPresets());
              },
            ),
          ),
          Expanded(
            child: Obx(()=> ready.value ? workoutPresets.isNotEmpty ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: workoutPresets.length,
                itemBuilder: (context,index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().selectedCardBG,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: (){
                          Get.to(()=> AddWorkoutPreset(editWorkoutObject: workoutPresets[index]));
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 8, 8, 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(workoutPresets[index]['title'],
                                      style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                                    ),
                                    SizedBox(height: 5,),
                                    Text("Last Edit - " + (DateFormat("dd/MM/yyyy HH:mm").format(DateTime.parse(Utils.dateFormat(workoutPresets[index]['updated_at'])))).toString(),
                                      style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
                                    ),
                                  ]
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Get.isDarkMode ? Colors.black : colors.Colors().darkGrey(1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Workouts',
                                        style: TypographyStyles.boldText(12, Themes.mainThemeColorAccent.shade100),
                                      ),
                                      SizedBox(height: 7,),
                                      Text('${NumberFormat('00').format(workoutPresets[index]['workout_plan'].length)}',
                                        style: TypographyStyles.boldText(20, Themes.mainThemeColorAccent.shade100),
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
            ):LoadingAndEmptyWidgets.emptyWidget(): LoadingAndEmptyWidgets.loadingWidget()),
          ),
        ],
      ),
    );
  }
}

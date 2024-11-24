import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/ClientsWorkoutsController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkout.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkoutFeedBack.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/WorkoutDays.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/components/CircularProgressBar.dart';

class SelectedUserWorkouts extends StatelessWidget {
  final Map workoutsData;

  const SelectedUserWorkouts(
      {Key? key, required this.workoutsData, required this.index})
      : super(key: key);

  final int index;
  @override
  Widget build(BuildContext context) {
    RxMap workouts = RxMap(workoutsData['workouts']);
    RxBool ready = true.obs;

    void reloadWorkouts() {
      print(ClientsWorkoutsController.workouts);
      if(ClientsWorkoutsController.workouts[index]['user']['id']==workoutsData['user']['id']) {
        workouts.value = RxMap(ClientsWorkoutsController.workouts[index]['workouts']);
      }
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.only(top: 10), // Adjust the margin as needed
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        centerTitle: true,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: CachedNetworkImageProvider(
                HttpClient.s3BaseUrl + workoutsData['user']['avatar_url'],
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              workoutsData['user']['name'],
              style: TypographyStyles.boldText(
                18,
                Get.isDarkMode
                    ? Themes.mainThemeColorAccent.shade100
                    : colors.Colors().lightBlack(1),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Obx(() => ready.value
              ? workouts.length > 0
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: workouts.entries.length,
                        itemBuilder: (_, index) {
                          String date = workouts.entries.elementAt(index).key;
                          print(workouts.entries.elementAt(index).value);
                          List presets =
                              workouts.entries.elementAt(index).value;
                          Map report =
                              WorkoutHelper().calculateWorkoutStats(presets);
                          print("Card printing===");
                          print(date);
                          print(report);
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            color: Get.isDarkMode
                                ? AppColors.primary2Color
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (presets.length > 0) {
                                  Get.to(() =>
                                          WorkoutDays(workoutData: presets))
                                      ?.then((value) {
                                    reloadWorkouts();
                                  });
                                }
                                // Get.to(() => ViewWorkout(
                                //         workoutData: workouts[index]))
                                //     ?.then((value) => {getWorkouts()});
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          date,
                                          style: TypographyStyles.title(16),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          presets.length == 0
                                              ? 'Rest Day'
                                              : '${presets.length} Presets Added',
                                          style: TypographyStyles.text(16),
                                        )
                                        // Text(
                                        //   "Last Update - ${workouts[index]['updated_at']}",
                                        //       // Utils.dateFormat(workouts[index]
                                        //       //         ['updated_at'])
                                        //       //     .toString()
                                        //       //     .split(' ')[0],
                                        //   style: TypographyStyles.normalText(
                                        //     14,
                                        //     Get.isDarkMode
                                        //         ? Themes.mainThemeColorAccent
                                        //             .shade500
                                        //         : colors.Colors().lightBlack(1),
                                        //   ),
                                        // ),
                                      ],
                                    )),
                                    presets.length>0?CircularProgressBar(
                                        progress: report['completedSteps'] /
                                            report['totalSteps']):Container(
                                      height: 54,
                                      width: 68,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: AppColors.blue),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat.MMM()
                                                  .format(DateTime.parse(date))
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              style: TypographyStyles.text(16).copyWith(
                                                color: AppColors.textOnAccentColor,
                                                height: 1.25,
                                              ),
                                            ),
                                            Text(
                                              DateTime.parse(date)
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
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : LoadingAndEmptyWidgets.emptyWidget()
              : LoadingAndEmptyWidgets.loadingWidget()),
        ],
      ),
    );
  }
}

class WorkoutHelper {
  Map<String, int> calculateWorkoutStats(List workouts) {
    int feedbackCount = 0;
    int totalSteps = 0;
    int completedSteps = 0;

    for (var workout in workouts) {
      // Retrieve 'steps' and 'completed_steps' as num and convert to int
      num steps = workout['steps'] ?? 0;
      num completed = workout['completed_steps'] ?? 0;

      totalSteps += steps.toInt();
      completedSteps += completed.toInt();

      // Check if feedback is not null
      if (workout['feedback'] != null) {
        feedbackCount += 1;
      }
    }

    return {
      'feedbackCount': feedbackCount,
      'totalSteps': totalSteps,
      'completedSteps': completedSteps,
    };
  }
}
//
// Row(
// mainAxisAlignment: MainAxisAlignment.end,
// children: [
// Text(
// "Progress ${(workouts[index]['completed_steps'] / workouts[index]['steps'] * 100).toStringAsFixed(0)}%",
// style: TypographyStyles.normalText(
// 12,
// Get.isDarkMode
// ? Themes.mainThemeColorAccent
//     .shade500
//     : colors.Colors().lightBlack(1),
// ),
// ),
// ],
// ),
//
// ClipRRect(
// borderRadius: BorderRadius.circular(12),
// child: LinearProgressIndicator(
// value: (workouts[index]
// ['completed_steps'] /
// workouts[index]['steps']),
// valueColor:
// AlwaysStoppedAnimation<Color>(
// Colors.green),
// minHeight: 8,
// ),
// ),

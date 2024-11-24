import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/ClientsWorkoutsController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkout.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkoutFeedBack.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/components/CircularProgressBar.dart';

import '../../../Models/HttpClient.dart';

class WorkoutDays extends StatelessWidget {
  WorkoutDays({required this.workoutData});
  late List workoutData;

  @override
  Widget build(BuildContext context) {
    RxList workoutDays = workoutData.obs;
    RxBool ready = true.obs;


    void deleteWorkouts(dynamic item) async {
      ready.value = false;
      workoutDays.remove(item);
      await httpClient.deleteWorkout(item['id']);
      await ClientsWorkoutsController.getClientsWorkouts();
      ready.value = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Workout Days"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Obx(()=>
            ready.value?ListView.builder(
            itemCount: workoutDays.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  child: InkWell(
                    onLongPress: authUser.role == 'trainer'
                        ? () {
                      CommonConfirmDialog.confirm('Delete')
                          .then((value) {
                        if (value) {
                          deleteWorkouts(workoutDays[index]);
                        }
                      });
                    }
                        : null,
                    onTap: () {
                      Get.to(() => ViewWorkout(workoutData: workoutDays[index]));
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Ink(
                      decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? AppColors.primary2Color
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workoutDays[index]['title'],
                                  style: TypographyStyles.title(16),
                                ),
                                Text(
                                  'Steps ${workoutDays[index]['completed_steps']}/${workoutDays[index]['steps']}',
                                  style: TypographyStyles.text(14),
                                ),
                                workoutDays[index]['completed_steps'] >=
                                        workoutDays[index]['steps']
                                    ? Container(
                                        height: 44,
                                        padding: EdgeInsets.only(top: 10),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor:
                                                    AppColors.accentColor,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20))),
                                            onPressed: () {
                                              Get.to(() => ViewWorkoutFeedback(
                                                    data: workoutDays[index],
                                                    viewOnly: true,
                                                  ))?.then((value) {
                                                // getWorkouts();
                                              });
                                            },
                                            child: Text(
                                              'View Feedback',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textOnAccentColor),
                                            )),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                            CircularProgressBar(
                                progress: workoutDays[index]['completed_steps'] /
                                    workoutDays[index]['steps'])
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ):
          Center(child: LoadingAndEmptyWidgets.loadingWidget()),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkout.dart';
import 'package:north_star/components/CircularProgressBar.dart';

class WorkoutDays extends StatelessWidget {
  WorkoutDays({required this.workoutData});
  final dynamic workoutData;

  RxList workoutDays = [].obs;

  @override
  Widget build(BuildContext context) {
    print(workoutData);
    String formatNumber(int number) {
      // Using conditional (ternary) operator to check if the number is less than 10
      return number < 10 ? '0$number' : number.toString();
    }
    void formatData() {
      // workoutData['workout_plan'].forEach((item){
      //   workoutDays.add(item);
      // });
      workoutDays.clear();
      for (var entry in workoutData['workout_plan'].entries) {
        print('${entry.key}: ${entry.value}');
        int completedCount = 0;
        workoutData['workout_plan'][entry.key].forEach((element) {
          if (element['has_completed']) {
            completedCount++;
          }
        });
        Map item = {
          'day': entry.key,
          'title': 'Day ${formatNumber(int.parse(entry.key))}',
          'completed_steps': completedCount,
          'total_steps': workoutData['workout_plan'][entry.key].length
        };
        workoutDays.add(item);
      }
    }

    formatData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Workout Days"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: workoutDays.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom:8.0),
              child: Material(
                child: InkWell(
                  onTap: () {
                    Map<String, dynamic> tempWorkoutData = {...workoutData};
                    print('workout plan ${index.runtimeType} ${workoutDays[index]['day'].runtimeType}');
                    print(workoutData);
                    tempWorkoutData['workout_plan'] = workoutData['workout_plan'][workoutDays[index]['day']];
                    tempWorkoutData['steps'] = workoutDays[index]['total_steps'];
                    Get.to(()=>ViewWorkout(workoutData: tempWorkoutData));
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
                              Text(workoutDays[index]['title'],style: TypographyStyles.title(16),),
                              Text('Steps ${formatNumber(workoutDays[index]['completed_steps'])}/${formatNumber(workoutDays[index]['total_steps'])}',style: TypographyStyles.text(14),)
                            ],
                          ),
                          CircularProgressBar(
                              progress: workoutDays[index]['completed_steps'] /
                                  workoutDays[index]['total_steps'])
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

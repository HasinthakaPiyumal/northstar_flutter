import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkout.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewWorkoutFeedBack.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SelectedUserWorkouts extends StatelessWidget {

  final int clientID;

  const SelectedUserWorkouts({Key? key, required this.clientID}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxList workouts = [].obs;

    RxBool ready = false.obs;
    RxBool userReady = false.obs;

    var selectedUserData = {};

    void getWorkouts() async {
      ready.value = false;
      Map res = await httpClient.getWorkoutsClient(clientID);
      if (res['code'] == 200) {
        workouts.value = res['data'];

        workouts.removeWhere((element) => element['user_id'] != clientID);

        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void getData() async {
      Map res = await httpClient.getOneUser(clientID.toString());
      if (res['code'] == 200) {
        selectedUserData = res['data'];
        print(selectedUserData);
        userReady.value = true;
      } else {
        userReady.value = true;
      }
    }

    void deleteWorkouts(int id) async {
      ready.value = false;
      await httpClient.deleteWorkout(id);
      getWorkouts();
    }

    getWorkouts();
    getData();

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Obx(()=> userReady.value ? CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(
                    HttpClient.s3BaseUrl + selectedUserData['user']['avatar_url'],
                  ),) : CircularProgressIndicator()
                ),
                SizedBox(width: 15,),
                Obx(()=> userReady.value ? Text(selectedUserData['user']['name'],
                    style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  ) : SizedBox(),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Obx(() => ready.value ? workouts.length > 0 ? Expanded(
            child: ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (_, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().selectedCardBG,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onLongPress: authUser.role == 'trainer' ? () {
                      CommonConfirmDialog.confirm('Delete').then((value) {
                        if (value) {
                          deleteWorkouts(workouts[index]['id']);
                        }
                      });
                    } : null,
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.to(() => ViewWorkout(workoutData: workouts[index]))?.then((value) => {getWorkouts()});
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workouts[index]['title'],
                            style: TypographyStyles.title(16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Last Update - " + Utils.dateFormat(workouts[index]['created_at']).toString().split(' ')[0],
                            style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: (workouts[index]
                              ['completed_steps'] / workouts[index]['steps']),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              minHeight: 8,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Progress ${(workouts[index]['completed_steps'] / workouts[index]['steps'] * 100).toStringAsFixed(0)}%",
                                style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),),
                              ),
                            ],
                          ),
                          workouts[index]['completed_steps'] == workouts[index]['steps'] ? Column(
                            children: [
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                      style: ButtonStyles.bigBlackButton(),
                                      onPressed: (){
                                    Get.to(()=> ViewWorkoutFeedback(
                                        data: workouts[index],
                                        viewOnly: true,
                                    ));
                                  }, child: Text('View Feedback', style: TextStyle(color: Colors.white),)
                                  )
                                ],
                              )
                            ],
                          ): SizedBox(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ) : LoadingAndEmptyWidgets.emptyWidget() : LoadingAndEmptyWidgets.loadingWidget()),
        ],
      ),
    );
  }
}

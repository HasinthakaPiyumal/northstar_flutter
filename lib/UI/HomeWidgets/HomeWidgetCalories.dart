import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDashboard/WatchData.dart';
import 'package:north_star/UI/Members/UserView.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/UI/SharedWidgets/RingsWidget.dart';
import 'package:north_star/UI/SharedWidgets/WatchDataWidget.dart';

import '../../Styles/TypographyStyles.dart';
import '../../components/CircularProgressBar.dart';

class HomeWidgetCalories extends StatelessWidget {
  const HomeWidgetCalories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList macrosData = [].obs;
    RxMap<int, bool> isCollapsedMap = <int, bool>{}.obs;

    void getAllUserMacrosData() async {
      Map res = await httpClient.getHomeWidgetCalories();

      if (res['code'] == 200) {
        macrosData.value = res['data'];
        macrosData.removeWhere((element) => element['user_id'] == authUser.id);
        for (var item in macrosData) {
          isCollapsedMap[item['user_id']] = true;
        }
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllUserMacrosData();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Live Dashboard',
          style: TypographyStyles.title(20),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Get.to(() => WatchData(userId: authUser.id));
            },
            child: Text(
              '  My Data  ',
              style: TextStyle(color: AppColors.accentColor),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (!ready.value) return LoadingAndEmptyWidgets.loadingWidget();
        if (macrosData.isEmpty) return LoadingAndEmptyWidgets.emptyWidget();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: macrosData.length,
                itemBuilder: (_, index) {
                  var userData = macrosData[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 16.0),
                    child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Get.to(() =>
                              UserView(userID: userData['user']['id']));
                        },
                        child: Obx(() {
                          bool isCollapsed =
                              isCollapsedMap[userData['user_id']] ?? true;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [

                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundImage:
                                                CachedNetworkImageProvider(
                                                  HttpClient.s3BaseUrl +
                                                      userData['user']['avatar_url'],
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    userData['user']['name'],
                                                    style: TypographyStyles.title(
                                                        18),
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Text(
                                                    'Weight ${userData['fit_category']} / ${userData['fit_program']} Fitness Program',
                                                    style: TypographyStyles
                                                        .textWithWeight(
                                                        13, FontWeight.w300),
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Text(
                                                    '${(userData['user']['health_conditions']?.length ?? 0).toString()} Health Conditions',
                                                    style:
                                                    TypographyStyles.text(16),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap:(){
                                            showMacroDataModal(context,userData);
                                          },
                                          child: Container(
                                            height: 126,
                                            width: 126,
                                            child: ringsChartCalories(userData),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Target Calories',
                                          style: TypographyStyles.text(14),
                                        ),
                                        Text(
                                          '${userData['daily_calories']}/${userData['target_calories']}',
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      height: 10,
                                      width: Get.width,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              color: AppColors()
                                                  .getPrimaryColor(
                                                  reverse: true),
                                              borderRadius:
                                              BorderRadius.circular(50),
                                            ),
                                          ),
                                          Container(
                                            width: (userData['daily_calories'] /
                                                userData[
                                                'target_calories']) *
                                                (Get.width - 60),
                                            decoration: BoxDecoration(
                                              color: Color(0xff68FC80),
                                              borderRadius:
                                              BorderRadius.circular(50),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  isCollapsedMap[userData['user_id']] =
                                  !isCollapsed;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0,right: 20,bottom: 20),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: ShapeDecoration(
                                      color: Get.isDarkMode
                                          ? AppColors.primary1Color
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(isCollapsed
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_up),
                                        Text(isCollapsed
                                            ? 'See More'
                                            : 'See Less'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (!isCollapsed)
                                Padding(
                                  padding: const EdgeInsets.all( 20),
                                  child: Column(
                                    children: [
                                      WatchDataWidget(userData['user_id']),
                                      Text('Cloud data from your smart device may take approximately 2 minutes to sync, depending on the network and access conditions.',style: TypographyStyles.text(10),textAlign: TextAlign.center,),
                                      if (userData["today_workout"] != null)
                                        Column(
                                          children: [
                                            Text(
                                              "Today Workout",
                                              style:
                                              TypographyStyles.title(20),
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: [
                                                CircularProgressBar(
                                                  progress: userData[
                                                  "today_workout"]
                                                  ['progress'] /
                                                      100,
                                                  radius: 50,
                                                  strokeWidth: 6,
                                                  fontSize: 20,
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      width: Get.width - 224,
                                                      decoration:
                                                      BoxDecoration(
                                                        color: Get.isDarkMode
                                                            ? AppColors
                                                            .primary1Color
                                                            : AppColors
                                                            .baseColor,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(10),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Exercise",
                                                            style: TypographyStyles
                                                                .textWithWeight(
                                                                14,
                                                                FontWeight
                                                                    .w300),
                                                          ),
                                                          Text(
                                                            userData["today_workout"]
                                                            [
                                                            'exercisesCount']
                                                                .toString(),
                                                            style: TypographyStyles
                                                                .title(20),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Container(
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      width: Get.width - 224,
                                                      decoration:
                                                      BoxDecoration(
                                                        color: Get.isDarkMode
                                                            ? AppColors
                                                            .primary1Color
                                                            : AppColors
                                                            .baseColor,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(10),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Remaining",
                                                            style: TypographyStyles
                                                                .textWithWeight(
                                                                14,
                                                                FontWeight
                                                                    .w300),
                                                          ),
                                                          Text(
                                                            userData["today_workout"]
                                                            [
                                                            'remainingCount']
                                                                .toString(),
                                                            style: TypographyStyles
                                                                .title(20),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
void showMacroDataModal(BuildContext context,dynamic userData) {
  showDialog(
    context: context,
    barrierDismissible: true, // Dismiss on outside tap
    builder: (BuildContext context) {
      return Dialog(

        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          // width: Get.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Macro Data',
                    style: TypographyStyles.title(16),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.accentColor
                        ),
                        child: Icon(Icons.close, color: AppColors.textOnAccentColor)
                    ), // Close icon
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    child: ringsChartCalories(userData,radius: "48"),
                  ),
                  const SizedBox(width: 16),
                  // Macro details
                  Expanded(
                    child: Column(
                      children: [
                        macroItem('Calorie Intake', '${userData['daily_calories']}', const Color(0xFF5576E3)),
                        macroItem('Carbs', '${userData['daily_carbs']}/${userData['target_carbs']}g', const Color(0xFFF5BB1D)),
                        macroItem('Proteins', '${userData['daily_protein']}/${userData['target_protein']}g', const Color(0xFFEC2F2F)),
                        macroItem('Fat','${userData['daily_fat']}/${userData['target_fat']}g',  const Color(0xFF1FC52A) ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget macroItem(String title, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            // shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TypographyStyles.text(14),
          ),
        ),
        Text(
          value,
          style: TypographyStyles.text(14),
        ),
      ],
    ),
  );
}
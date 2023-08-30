import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import 'package:north_star/Utils/CustomColors.dart' as colors;

class ViewWorkout extends StatelessWidget {
  const ViewWorkout({Key? key, required this.workoutData}) : super(key: key);

  final Map workoutData;
  @override
  Widget build(BuildContext context) {
    RxInt pageIndex = 0.obs;
    RxBool ready = false.obs;
    RxMap workout = {}.obs;
    PageController pageController = PageController(initialPage: 0);

    void fillData(){
      print(workoutData);
    }

    Future<bool> getWorkout() async {
      ready.value = false;
      Map res = await httpClient.getWorkoutByID(workoutData['id']);

      if (res['code'] == 200) {
        workout.value = res['data'];
        ready.value = true;
        return true;
      } else {
        ready.value = true;
        return true;
      }
    }

    void markAsCompleted(Map workoutData) async{
      ready.value = false;
      Map res = await httpClient.markWorkoutAsCompleted({
        'workout_plan_id': workout['id'].toString(),
        'workout': json.encode(workoutData),
      });
      if (res['code'] == 200) {
        ready.value = true;
        await getWorkout();
      } else {
        ready.value = true;
      }
    }

    fillData();
    getWorkout();

    return Obx(()=> ready.value ? Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(workout['title'],style: TypographyStyles.title(20)),
        actions: [
          Container(
            width: 91,
            height: 40,
            margin: const EdgeInsets.only(top:10,right: 10),
            decoration: ShapeDecoration(
              color: AppColors.primary2Color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: ShapeDecoration(
                          color: Color(0xFFFFB700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        child: Center(
                          child: Text(
                            '0'+(pageIndex.value+1).toString(),
                            style: TextStyle(
                              color: Color(0xFF1B1F24),
                              fontSize: 20,
                              fontFamily: 'Bebas Neue',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ 0'+ workout['steps'].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Bebas Neue',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: Get.width,
              height: Get.height * 0.76,
              child: PageView.builder(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (int index) {
                  print(index);
                  print(workout['workout_plan'].length);
                  pageIndex.value = index;
                },
                itemCount: workout['workout_plan'].length,
                itemBuilder: (_,index){
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(workout['workout_plan'][index]['title'], style: TypographyStyles.title(18),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: Get.width,
                            child: CachedNetworkImage(
                              imageUrl: HttpClient.s3ResourcesBaseUrl + workout['workout_plan'][index]['animation_url'],
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Column(
                                      children: [
                                        Text('REPETITIONS', style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1))),
                                        SizedBox(height: 5,),
                                        Text(workout['workout_plan'][index]['repetitions'].toString(), style: TypographyStyles.boldText(24, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1))
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Column(
                                      children: [
                                        Text('SETS', style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1))),
                                        SizedBox(height: 5,),
                                        Text(workout['workout_plan'][index]['sets'].toString(), style: TypographyStyles.boldText(24, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1))
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              // Column(
                              //   children: [
                              //     TextButton(
                              //         onPressed: (){},
                              //         child: Column(
                              //           children: [
                              //             Icon(Icons.info_outline,size: 32),
                              //             Text('Info', style: TypographyStyles.title(18)),
                              //           ],
                              //         )
                              //     ),
                              //
                              //   ],
                              // ),
                              Expanded(
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Column(
                                      children: [
                                        Text('WEIGHT', style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1))),
                                        SizedBox(height: 5,),
                                        RichText(
                                          text: TextSpan(
                                            text: "${workout['workout_plan'][index]['weight'] == null ? '-' : workout['workout_plan'][index]['weight'].toString()}",
                                            style: TypographyStyles.boldText(24, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1)),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: 'Kg',
                                                style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(workout['workout_plan'][index]['notes'] == null ? '-' : workout['workout_plan'][index]['notes'],
                            style: TypographyStyles.normalText(15, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
       bottomNavigationBar: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(()=>pageIndex.value < workout['workout_plan'].length ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Container(
              width: Get.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.chevron_left, color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                            Text('PREV', style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),),
                          ],
                        ),
                        onPressed: (){
                          pageController.animateToPage(
                              pageIndex.value - 1,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 4,),
                  !workout['workout_plan'][pageIndex.value]['has_completed'] ? Expanded(
                    child: authUser.role != 'trainer' ? ElevatedButton(
                      onPressed: () {
                        markAsCompleted(workout['workout_plan'][pageIndex.value]);
                      },
                      child: Icon(Icons.check, size: 24, color: Colors.white,),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(19),
                        backgroundColor: Color(0xFF4BD595), // <-- Button color
                        foregroundColor: Colors.white, // <-- Splash color
                      ),
                    ): Container(),
                  ): Expanded(
                    child: TextButton(
                      onPressed: null,
                      child: Icon(Icons.check, size: 46, color: Colors.transparent,),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(19),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  SizedBox(width: 4,),
                  Expanded(
                    child: Obx(()=>Container(
                      child: pageIndex.value < workout['workout_plan'].length-1 ? TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('NEXT', style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),),
                            Icon(Icons.chevron_right,
                              color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                            ),
                          ],
                        ),
                        onPressed: (){
                          pageController.animateToPage(
                              pageIndex.value + 1,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut
                          );
                        },
                      ) : authUser.role != 'trainer' ? TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('DONE', style: TypographyStyles.boldText(16, Themes.mainThemeColorAccent.shade100),),
                          ],
                        ),
                        onPressed: (){
                          Get.back();
                        },
                      ):Container(),
                    )),
                  )
                ],
              ),
            ),
          ): Container()),
        ],
      )
    ): Scaffold(
      appBar: AppBar(
        title: Text('Loading...'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ));
  }
}

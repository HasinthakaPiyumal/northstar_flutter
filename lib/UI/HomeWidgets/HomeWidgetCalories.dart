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

    void getAllUserMacrosData() async {
      Map res = await httpClient.getHomeWidgetCalories();

      if (res['code'] == 200) {
        macrosData.value = res['data'];
        macrosData.removeWhere((element) => element['user_id'] == authUser.id);
        ready.value = true;
        print('==Macros data');
        print(res['data']);
      } else {
        print(res);
        ready.value = true;
      }
    }

    getAllUserMacrosData();

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
                ))
          ]),
      body: Obx(() => ready.value
          ? macrosData.length > 0
              ? Column(
                  children: [
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                          itemCount: macrosData.length,
                          itemBuilder: (_, index) {
                            Widget mainItem = Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16.0, bottom: 16.0),
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Get.isDarkMode
                                    ? AppColors.primary2Color
                                    : Colors.white,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Get.to(() => UserView(
                                        userID: macrosData[index]['user']
                                            ['id']));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                                radius: 24,
                                                                backgroundImage:
                                                                    CachedNetworkImageProvider(
                                                                  HttpClient
                                                                          .s3BaseUrl +
                                                                      macrosData[index]
                                                                              [
                                                                              'user']
                                                                          [
                                                                          'avatar_url'],
                                                                )),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                                macrosData[index]
                                                                        ['user']
                                                                    ['name'],
                                                                style:
                                                                    TypographyStyles
                                                                        .title(
                                                                            20)),
                                                            Text(
                                                                'Weight ' +
                                                                    macrosData[
                                                                            index]
                                                                        [
                                                                        'fit_category'] +
                                                                    ' / ' +
                                                                    macrosData[
                                                                            index]
                                                                        [
                                                                        'fit_program'] +
                                                                    ' Fitness Program',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TypographyStyles
                                                                    .textWithWeight(
                                                                        13,
                                                                        FontWeight
                                                                            .w300)),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 126,
                                                        width: 126,
                                                        child:
                                                            ringsChartCalories(
                                                                macrosData[
                                                                    index]),
                                                      ),
                                                    ],
                                                  ),
                                                  // ListTile(
                                                  //   contentPadding:
                                                  //       EdgeInsets.zero,
                                                  //   leading: CircleAvatar(
                                                  //       radius: 28,
                                                  //       backgroundImage:
                                                  //           CachedNetworkImageProvider(
                                                  //         HttpClient.s3BaseUrl +
                                                  //             macrosData[index]
                                                  //                     ['user'][
                                                  //                 'avatar_url'],
                                                  //       )),
                                                  //   title: Text(
                                                  //     macrosData[index]['user']
                                                  //         ['name'],
                                                  //     style: TextStyle(
                                                  //         fontWeight:
                                                  //             FontWeight.bold),
                                                  //   ),
                                                  //   subtitle: Text(
                                                  //       'Weight ' +
                                                  //           macrosData[index][
                                                  //               'fit_category'] +
                                                  //           ' | ' +
                                                  //           macrosData[index][
                                                  //               'fit_program'] +
                                                  //           ' Fitness Program',
                                                  //       style: TextStyle(
                                                  //           fontSize: 12,
                                                  //           color: Themes
                                                  //               .mainThemeColorAccent
                                                  //               .shade300)),
                                                  // ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 30),
                                                          height: 98,
                                                          decoration: BoxDecoration(
                                                              color: macrosData[
                                                                              index]
                                                                          [
                                                                          'daily_calories'] >
                                                                      macrosData[
                                                                              index]
                                                                          [
                                                                          'target_calories']
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text('Current',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                  )),
                                                              Text(
                                                                  macrosData[index]
                                                                          [
                                                                          'daily_calories']
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20,
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 30),
                                                          height: 98,
                                                          decoration: BoxDecoration(
                                                              color: Get
                                                                      .isDarkMode
                                                                  ? AppColors
                                                                      .primary1Color
                                                                  : AppColors
                                                                      .baseColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text('Target',
                                                                  style: TypographyStyles
                                                                      .text(
                                                                          16)),
                                                              Text(
                                                                macrosData[index]
                                                                        [
                                                                        'target_calories']
                                                                    .toString(),
                                                                style:
                                                                    TypographyStyles
                                                                        .title(
                                                                            20),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),
                                                  Center(
                                                      child: Text(
                                                    'Last Updated on: ' +
                                                        Utils.dateFormat(
                                                            macrosData[index]
                                                                ['updated_at']),
                                                    textAlign: TextAlign.center,
                                                    style: TypographyStyles
                                                        .textWithWeight(13,
                                                            FontWeight.w300),
                                                  )),
                                                  SizedBox(height: 5),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        watchDataWidget(
                                            macrosData[index]['user_id']),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            // if (index != macrosData.length - 1) {
                            //   return mainItem;
                            // }
                            return Column(
                              children: [
                                mainItem,
                                macrosData[index]["today_workout"]!=null?Container(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  margin: EdgeInsets.only(bottom: 16,left: 16,right: 16),
                                  decoration: BoxDecoration(
                                      color: Get.isDarkMode
                                          ? AppColors.primary2Color
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Today Workout",
                                        style: TypographyStyles.title(20),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          CircularProgressBar(
                                            progress: macrosData[index]["today_workout"]['progress']/100,
                                            radius: 50,
                                            strokeWidth: 6,
                                            fontSize: 20,
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                width:Get.width-224,
                                                decoration: BoxDecoration(
                                                    color: Get.isDarkMode
                                                        ? AppColors
                                                            .primary1Color
                                                        : AppColors.baseColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Column(children: [
                                                  Text("Exercise",style: TypographyStyles.textWithWeight(14, FontWeight.w300),),
                                                  Text(macrosData[index]["today_workout"]['exercisesCount'].toString(),style: TypographyStyles.title(20),),
                                                ],),
                                              ),
                                              SizedBox(height: 8,),
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                width:Get.width-224,
                                                decoration: BoxDecoration(
                                                    color: Get.isDarkMode
                                                        ? AppColors
                                                            .primary1Color
                                                        : AppColors.baseColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Column(children: [
                                                  Text("Remaining",style: TypographyStyles.textWithWeight(14, FontWeight.w300),),

                                                  Text(macrosData[index]["today_workout"]['remainingCount'].toString(),style: TypographyStyles.title(20),),
                                                ],),
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ):Container()
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : LoadingAndEmptyWidgets.emptyWidget()
          : LoadingAndEmptyWidgets.loadingWidget()),
    );
  }
}

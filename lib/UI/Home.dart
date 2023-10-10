import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/NotificationsController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetCalories.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClientNotes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetFinance.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetLabReports.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetPro.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetResources.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetServices.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetStore.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetToDos.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetTrainers.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetVideoSessions.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts.dart';
import 'package:north_star/UI/PrivateUser/ClientCalories.dart';
import 'package:north_star/UI/PrivateUser/CompleteUserProfile.dart';
import 'package:north_star/UI/SharedWidgets/ClientHomeTrainerRequest.dart';
import 'package:north_star/UI/SharedWidgets/HomeWidgetButton.dart';
import 'package:north_star/UI/SharedWidgets/RingsWidget.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetFamilyLink.dart';
import 'package:north_star/UI/Wallet.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Styles/AppColors.dart';
import 'HomeWidgets/HomeWidgetDoctors.dart';
import 'HomeWidgets/HomeWidgetProActive.dart';
import 'HomeWidgets/HomeWidgetTherapy.dart';
import 'SharedWidgets/WatchDataWidget.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  static const carouselHeight = 180.0;

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxMap homeData = {}.obs;
    RxMap homeDataTrainer = {}.obs;
    RxInt currentCarouselIndex = 0.obs;

    RxList<Widget> carouselItems = <Widget>[].obs;
    RxList carouselList = [].obs;
    RxInt carouselTime = 6.obs;

    void getCarouselItems() async {
      Map res = await httpClient.getCarouselItems();
      carouselList.value = res['data'];
      if (res['code'] == 200) {
        res['data'].forEach((item) {
          carouselTime.value = item['duration'];
          carouselItems.add(
            InkWell(
              onTap: () {
                final Uri meeting = Uri.parse(item['link']);
                launchUrl(meeting);
              },
              borderRadius: BorderRadius.circular(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                // color: Colors.red,
                height: 10,
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: HttpClient.s3ResourcesBaseUrl + item['ad_img'],
                    fit: BoxFit.fitWidth,
                    width: Get.width,
                    height: 200,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
          );
        });
      }
    }

    getCarouselItems();

    void getHomeData() async {
      ready.value = false;
      Map res = await httpClient.getHomeData('0');

      if (res['code'] == 200) {
        homeData.value = res['data'];
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void getHomeDataTrainer() async {
      ready.value = false;
      Map res = await httpClient.getHomeTrainerData();

      if (res['code'] == 200) {
        homeDataTrainer.value = res['data'];
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    if (authUser.role == 'trainer') {
      getHomeDataTrainer();
    } else {
      getHomeData();
    }

    void getNotificationsAndShowPrompt() async {
      await NotificationsController.getNotifications();
      NotificationsController.showNotificationsPrompt();
    }

    getNotificationsAndShowPrompt();

    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          Duration(seconds: 1),
          () async {
            getHomeData();
            getHomeDataTrainer();
            await NotificationsController.getNotifications();
            NotificationsController.showNotificationsPrompt();
          },
        );
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => ready.value
                  ? authUser.role == 'client'
                      ? Visibility(
                          visible: authUser.user['client']['is_complete'] == 0,
                          child: Container(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            width: Get.width,
                            height: 64,
                            child: Card(
                              color: Themes.mainThemeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                child: Center(
                                  child: Text(
                                    'Tap to Complete Your Profile',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Get.to(() => CompleteUserProfile())
                                      ?.then((value) {
                                    getHomeData();
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                      : Container()
                  : Container()),
              Container(
                height: carouselHeight,
                width: (Get.width),
                child: Obx(() => CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: carouselTime.value),
                        height: carouselHeight,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          currentCarouselIndex.value = index;
                          // carouselTime.value = carouselList[index]["duration"];
                          // print('Duration --> ${carouselTime.value}');
                        },
                      ),
                      items: carouselItems,
                    )),
              ),
              authUser.role == 'trainer'
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetCalories());
                          }, 'dashboard', 'Dashboard'),
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetWorkouts());
                          }, 'workouts', 'Exercise Bank'),
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetToDos());
                          }, 'todo', 'Todo'),
                        ],
                      ))
                  : SizedBox(),
              authUser.role == 'trainer'
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetGym());
                          }, 'gym', 'Facilities'),
                          homeWidgetButton(() {
                            Get.to(() => Doctors());
                          }, 'doctors', 'Medical Professionals'),
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetVideoSessions());
                          }, 'sessions', 'Video Sessions'),
                        ],
                      ))
                  : SizedBox(),
              authUser.role == 'trainer'
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              Get.to(() => HomeWidgetPro());
                            } else {
                              Get.to(() => HomeWidgetProActive());
                            }
                          }, 'pro', 'Pro'),
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetResources());
                          }, 'resources', 'Resources'),
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetServices());
                          }, 'calculators', 'Fitness Calculator'),
                        ],
                      ))
                  : SizedBox(),
              authUser.role == 'trainer'
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetStore());
                          }, 'shop', 'Stores'),
                          homeWidgetButton(() {
                            Get.to(() => UserCalories());
                          }, 'calorie', 'Calories'),
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetClientNotes());
                          }, 'notes', 'Income & Expense'),
                        ],
                      ))
                  : SizedBox(),
              authUser.role == 'trainer'
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetLabReports());
                          }, 'labReports', 'Lab Reports'),
                          homeWidgetButton(() {
                            Get.to(() => HomeWidgetFinance());
                          }, 'ewallet', 'Finance'),
                          homeWidgetButton(() {
                            Get.to(() => Therapy());
                          }, 'therapy', 'Physiotherapy'),
                        ],
                      ))
                  : SizedBox(),
              authUser.role == 'client'
                  ? Container(
                      width: Get.width,
                      height: 160,
                      padding: const EdgeInsets.fromLTRB(10, 8, 0, 8),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              Get.to(() => HomeWidgetPro());
                            } else {
                              Get.to(() => HomeWidgetProActive());
                            }
                          }, 'pro', 'Pro'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              Get.to(() => HomeWidgetPro());
                            } else {
                              Get.to(() => HomeWidgetWorkouts());
                            }
                          }, 'workouts', 'Exercise Bank'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              Get.to(() => Doctors());
                            } else {
                              Get.to(() => Doctors());
                            }
                          }, 'doctors', 'Medical Professionals'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              //Get.to(()=>HomeWidgetPro());
                              Get.to(() => HomeWidgetLabReports());
                            } else {
                              Get.to(() => HomeWidgetLabReports());
                            }
                          }, 'labReports', 'Lab Reports'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              Get.to(() => HomeWidgetPro());
                            } else {
                              Get.to(() => HomeWidgetToDos());
                            }
                          }, 'todo', 'Todo'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              Get.to(() => HomeWidgetGym());
                            } else {
                              Get.to(() => HomeWidgetGym());
                            }
                          }, 'gym', 'Facilities'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              Get.to(() => HomeWidgetPro());
                            } else {
                              Get.to(() => HomeWidgetVideoSessions());
                            }
                          }, 'sessions', 'Video Sessions'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              // Get.to(()=>HomeWidgetPro());
                              Get.to(() => HomeWidgetTrainers());
                            } else {
                              Get.to(() => HomeWidgetTrainers());
                            }
                          }, 'trainers', 'Trainers'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              Get.to(() => HomeWidgetPro());
                            } else {
                              Get.to(() => HomeWidgetResources());
                            }
                          }, 'resources', 'Resources'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              // Get.to(()=>HomeWidgetPro());
                              Get.to(() => FamilyLink());
                            } else {
                              Get.to(() => FamilyLink());
                            }
                          }, 'family', 'Family Link'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              // Get.to(()=>HomeWidgetPro());
                              Get.to(() => Wallet());
                            } else {
                              Get.to(() => Wallet());
                            }
                          }, 'ewallet', 'eWallet'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              // Get.to(()=>HomeWidgetPro());
                              Get.to(() => HomeWidgetStore());
                            } else {
                              Get.to(() => HomeWidgetStore());
                            }
                          }, 'shop', 'Store'),
                          homeWidgetButton(() {
                            if (authUser.user['subscription'] == null) {
                              // Get.to(()=>HomeWidgetPro());
                              Get.to(() => Therapy());
                            } else {
                              Get.to(() => Therapy());
                            }
                          }, 'therapy', 'Physiotherapy'),
                        ],
                      ))
                  : SizedBox(),
              authUser.role == 'client'
                  ? clientHomeTrainerRequest()
                  : SizedBox(),
              authUser.role == 'client'
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: watchDataWidget(authUser.id),
                    )
                  : SizedBox(),
              authUser.role == 'client'
                  ? Obx(() => ready.value
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: homeData['macros'] != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                        child: Card(
                                            elevation: 6,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            color: Get.isDarkMode
                                                ? AppColors.primary2Color
                                                : Colors.white,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 4),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8, top: 8),
                                                    child: Text(
                                                      'Today Calories',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  //ringsWidget(homeData),
                                                  Center(
                                                    child: Container(
                                                      height: 160,
                                                      width: 150,
                                                      child: SafeArea(
                                                          child: ringsChart(
                                                              homeData)),
                                                    ),
                                                  ),
                                                  //SizedBox(height: 4),
                                                  Card(
                                                    elevation: 0,
                                                    color: Get.isDarkMode
                                                        ? AppColors
                                                            .primary1Color
                                                        : Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text('Remaining'),
                                                              Text(
                                                                (homeData['macros']
                                                                            [
                                                                            'target_calories'] -
                                                                        homeData['macros']
                                                                            [
                                                                            'daily_calories'])
                                                                    .round()
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: homeData['macros']['target_calories'] <
                                                                            homeData['macros'][
                                                                                'daily_calories']
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                homeData['macros']
                                                                        [
                                                                        'target_calories']
                                                                    .round()
                                                                    .toString(),
                                                                style: TypographyStyles
                                                                    .textWithWeight(
                                                                        12,
                                                                        FontWeight
                                                                            .w300),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ))),
                                    Expanded(
                                        child: Card(
                                            elevation: 6,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            color: Get.isDarkMode
                                                ? AppColors.primary2Color
                                                : Colors.white,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              onTap: () {
                                                Get.to(
                                                    () => HomeWidgetWorkouts());
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 4),
                                                    homeData['workouts_total'] !=
                                                            0
                                                        ? Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 8,
                                                                    top: 8),
                                                            child: Text(
                                                              'Today Workouts',
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          )
                                                        : Container(),
                                                    SizedBox(height: 4),
                                                    Container(
                                                      child: homeData[
                                                                  'workouts_total'] !=
                                                              0
                                                          ? Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  height: 128,
                                                                  width: 128,
                                                                ),
                                                                Center(
                                                                  child:
                                                                      Container(
                                                                    height: 150,
                                                                    width: 150,
                                                                    child: SfCircularChart(
                                                                        margin: EdgeInsets
                                                                            .zero,
                                                                        series: <RadialBarSeries<
                                                                            ChartData,
                                                                            int>>[
                                                                          RadialBarSeries<
                                                                              ChartData,
                                                                              int>(
                                                                            useSeriesColor:
                                                                                true,
                                                                            trackOpacity:
                                                                                0.2,
                                                                            maximumValue:
                                                                                100,
                                                                            radius:
                                                                                "60",
                                                                            innerRadius:
                                                                                "48",
                                                                            gap:
                                                                                "3",
                                                                            cornerStyle:
                                                                                CornerStyle.bothCurve,
                                                                            dataSource: [
                                                                              ChartData(
                                                                                radius: 3,
                                                                                value: double.parse(homeData['workouts_done'].toString()) / double.parse(homeData['workouts_total']) * 100,
                                                                                color: colors.Colors().deepYellow(1),
                                                                              ),
                                                                            ],
                                                                            //pointRadiusMapper: (ChartData data, _) => data.radius.toString(),
                                                                            pointColorMapper: (ChartData data, _) =>
                                                                                data.color,
                                                                            xValueMapper: (ChartData sales, _) =>
                                                                                0,
                                                                            yValueMapper: (ChartData sales, _) =>
                                                                                sales.value,
                                                                          )
                                                                        ]),
                                                                  ),
                                                                ),
                                                                // Container(
                                                                //   padding: const EdgeInsets.all(8),
                                                                //   width: 128,
                                                                //   height: 128,
                                                                //   child: CircularProgressIndicator(
                                                                //     strokeWidth: 8,
                                                                //     value: double.parse(homeData['workouts_done'].toString()) / double.parse(homeData['workouts_total'].toString()),
                                                                //     valueColor: new AlwaysStoppedAnimation<Color>(Themes.mainThemeColor),
                                                                //   ),
                                                                // ),
                                                                // Container(
                                                                //   padding: const EdgeInsets.all(8),
                                                                //   width: 128,
                                                                //   height: 128,
                                                                //   child: CircularProgressIndicator(
                                                                //     strokeWidth: 8,
                                                                //     value: 1,
                                                                //     valueColor: new AlwaysStoppedAnimation<Color>(Themes.mainThemeColor.withOpacity(0.125)),
                                                                //   ),
                                                                // ),
                                                                Container(
                                                                  child: Text(
                                                                      (double.parse(homeData['workouts_done'].toString()) / double.parse(homeData['workouts_total'].toString()) * 100.0)
                                                                              .round()
                                                                              .toString() +
                                                                          '%',
                                                                      style: TypographyStyles
                                                                          .boldText(
                                                                        24,
                                                                        Get.isDarkMode
                                                                            ? Themes.mainThemeColorAccent.shade100
                                                                            : colors.Colors().lightBlack(1),
                                                                      )),
                                                                ),
                                                              ],
                                                            )
                                                          : Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                minHeight: 100,
                                                              ),
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'No workouts for today',
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    homeData['workouts_total'] !=
                                                            0
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                      homeData[
                                                                              'workouts_done']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              27,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  Text(
                                                                      'Exercises'),
                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                      (int.parse(homeData['workouts_total'].toString()) -
                                                                              int.parse(homeData['workouts_done']
                                                                                  .toString()))
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              27,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  Text(
                                                                      'Remaining'),
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                        : Container(),
                                                    SizedBox(height: 10),
                                                  ],
                                                ),
                                              ),
                                            ))),
                                  ],
                                )
                              : Container(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 64),
                                      Center(
                                        child:
                                            Text('No Macro Profile is Active!',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                      ),
                                      SizedBox(height: 16),
                                      Center(
                                        child: Text(
                                            'Please contact your Trainer.'),
                                      )
                                    ],
                                  ),
                                ),
                        )
                      : Center(child: CircularProgressIndicator()))
                  : SizedBox(),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

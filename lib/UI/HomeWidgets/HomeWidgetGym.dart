import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/CommercialGyms.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/ExclusiveGyms.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/GymView.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/UnlockDoorQR.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import 'DoorQRView.dart';
import 'HomeWidgetGym/Services.dart';

class HomeWidgetGym extends StatelessWidget {
  const HomeWidgetGym({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList myBookings = [].obs;
    RxList myServices = [].obs;
    DateFormat tmFormat = DateFormat('hh:mm a');

    void showInfo(Map data) {
      Get.defaultDialog(
          title: '${data['client_ids'].length} Member(s) Have Access',
          titlePadding: EdgeInsets.only(top: 20),
          radius: 8,
          content: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  height: 256,
                  width: Get.width,
                  child: ListView.builder(
                    itemCount: data['clients'].length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              HttpClient.s3BaseUrl +
                                  data['clients'][index]['user']['avatar_url']),
                        ),
                        title: Text(data['clients'][index]['user']['name']),
                        subtitle: Text(data['clients'][index]['user']['email']),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Close'))
          ]);
    }

    void getMyComGymBookings() async {
      Map res = await httpClient.getComGymSchedules();
      print("====");
      if (res['code'] == 200) {
        myBookings.addAll(res['data']);
      }
    }

    void getMyServiceBookings() async {
      Map res = await httpClient.getServiceSchedules();
      print("====");

      print("length services - ${res['data'].length}");
      print(res['data']);
      if (res['code'] == 200) {
        myBookings.addAll(res['data']);
      }
    }

    void getMyGymBookings() async {
      Map res = await httpClient.getExclusiveGymSchedules();
      if (res['code'] == 200) {
        myBookings.value = res['data'];
      }
      getMyServiceBookings();
      getMyComGymBookings();
    }

    getMyGymBookings();

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Facilities', style: TypographyStyles.title(20))),
      body: Obx(() => Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Visibility(
                      child: Container(
                        height: 80,
                        child: ElevatedButton(
                          style: ButtonStyles.matButton(
                              Get.isDarkMode
                                  ? AppColors.primary2Color
                                  : Colors.white,
                              1),
                          onPressed: () {
                            Get.to(() => ExclusiveGyms());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 64,
                                child: Image.asset("assets/icons/gym_bank.png"),
                              ),
                              SizedBox(width: 25),
                              Text(
                                'Exclusive Gyms',
                                style: TypographyStyles.text(20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      visible: authUser.role != 'client',
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 80,
                      child: ElevatedButton(
                        style: ButtonStyles.matButton(
                            Get.isDarkMode
                                ? AppColors.primary2Color
                                : Colors.white,
                            1),
                        onPressed: () {
                          Get.to(() => CommercialGyms());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 64,
                              child: Image.asset("assets/icons/gym_bank.png"),
                            ),
                            SizedBox(width: 25),
                            Text(
                              'Commercial Gyms',
                              style: TypographyStyles.text(20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Visibility(
                      child: Container(
                        height: 80,
                        child: ElevatedButton(
                          style: ButtonStyles.matButton(
                              Get.isDarkMode
                                  ? AppColors.primary2Color
                                  : Colors.white,
                              1),
                          onPressed: () {
                            Get.to(() => Services());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 64,
                                child: Image.asset("assets/icons/gym_bank.png"),
                              ),
                              SizedBox(width: 25),
                              Text(
                                'Services',
                                style: TypographyStyles.text(20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      visible: true//authUser.role != 'client',
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('My Bookings',
                    textAlign: TextAlign.left,
                    style: TypographyStyles.title(20)),
                SizedBox(height: 30),
                Expanded(
                  child: myBookings.length > 0
                      ? ListView.builder(
                          itemCount: myBookings.length,
                          itemBuilder: (_, index) {
                            print("GYM Type");
                            print(myBookings[index]['type']);
                            print("GYM Data");
                            print(myBookings[index]['gym_data']);
                            print(myBookings[index]['gym']);
                            if (myBookings[index]['type'] != null) {
                              DateTime selectedDateForEquation;

                              int daysDif = DateTime.parse(
                                      myBookings[index]['start_date'])
                                  .difference(DateTime.now())
                                  .inDays;

                              if (daysDif > 0) {
                                selectedDateForEquation = DateTime.parse(
                                    myBookings[index]['start_date']);
                              } else {
                                selectedDateForEquation = DateTime.now();
                              }

                              return Card(
                                margin: EdgeInsets.only(bottom: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Get.isDarkMode
                                          ? AppColors.primary2Color
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 18,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              HttpClient
                                                                      .s3BaseUrl +
                                                                  myBookings[index]
                                                                          [
                                                                          'gym']
                                                                      [
                                                                      'avatar_url']),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              Get.width - 140,
                                                          child: Text(
                                                            "${myBookings[index]['gym_data']['gym_name']}"
                                                                .capitalize
                                                                .toString(),
                                                            style:
                                                                TypographyStyles
                                                                    .title(16),
                                                          ),
                                                        ),
                                                        Text(
                                                          "${CountryPickerUtils.getCountryByIsoCode(myBookings[index]['gym_data']['gym_country']).name}",
                                                          style:
                                                              TypographyStyles
                                                                  .text(14),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Divider(
                                                  thickness: 0.5,
                                                  color: Colors.white
                                                      .withOpacity(
                                                          0.23999999463558197),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${DateTime.parse(myBookings[index]['end_date']).difference(selectedDateForEquation).inDays} Day(s) Remaining",
                                                          style: TypographyStyles
                                                              .textWithWeight(
                                                                  16,
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          DateFormat("MMM dd,yyyy").format(
                                                                  DateTime.parse(
                                                                      myBookings[
                                                                              index]
                                                                          [
                                                                          'start_date'])) +
                                                              ' - ' +
                                                              DateFormat(
                                                                      "MMM dd,yyyy")
                                                                  .format(DateTime.parse(
                                                                      myBookings[
                                                                              index]
                                                                          [
                                                                          'end_date'])),
                                                          style: TypographyStyles
                                                              .textWithWeight(
                                                                  14,
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Map obj =
                                                  myBookings[index]['gym_data'];
                                              obj.addIf(
                                                  !obj.keys.contains('user'),
                                                  'user', {
                                                'avatar_url': myBookings[index]
                                                    ['gym']['avatar_url']
                                              });
                                              print('Gym view obj');
                                              print(obj);
                                              Get.to(() => GymView(
                                                    gymObj: obj,
                                                    viewOnly: true,
                                                  ));
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          children: [
                                            // Container(
                                            //   height: 90,
                                            //   height: 90,
                                            //   child: ElevatedButton(
                                            //     style: ElevatedButton.styleFrom(
                                            //         foregroundColor:
                                            //             Colors.white,
                                            //         backgroundColor:
                                            //             Colors.transparent,
                                            //         elevation: 0,
                                            //         shape:
                                            //             RoundedRectangleBorder(
                                            //                 borderRadius:
                                            //                     BorderRadius
                                            //                         .circular(
                                            //                             8))),
                                            //     onPressed: () {
                                            //       //unlockGym(myBookings[index]['gym_id']);
                                            //       Get.to(() => UnlockDoorQR(
                                            //           gymID: myBookings[index]
                                            //               ['gym_id']));
                                            //     },
                                            //     child: Image.asset(
                                            //       "assets/images/unlock_v2.png",
                                            //       height: 90,
                                            //       fit: BoxFit.fitHeight,
                                            //     ),
                                            //   ),
                                            // ),
                                            // InkWell(
                                            //   onTap: () {
                                            //     //unlockGym(myBookings[index]['gym_id']);
                                            //     // Get.to(()=>DoorQRView());
                                            //     Get.to(() => UnlockDoorQR(
                                            //         QR: myBookings[index]
                                            //                 ['user']['qr_id']
                                            //             .toString()));
                                            //   },
                                            //   child: Container(
                                            //       width: 102,
                                            //       height: 108,
                                            //       padding:
                                            //           EdgeInsets.only(top: 10),
                                            //       decoration: BoxDecoration(
                                            //           color: Theme.of(context)
                                            //               .scaffoldBackgroundColor,
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   10)),
                                            //       child: Center(
                                            //         child: Column(
                                            //           children: [
                                            //             Image.asset(
                                            //               "assets/images/qr.png",
                                            //               fit: BoxFit.fitHeight,
                                            //               width: 36,
                                            //               height: 36,
                                            //             ),
                                            //             SizedBox(height: 10),
                                            //             Text(
                                            //               'Unlock \nDoor',
                                            //               textAlign:
                                            //                   TextAlign.center,
                                            //               style: TypographyStyles
                                            //                   .textWithWeight(
                                            //                       14,
                                            //                       FontWeight
                                            //                           .w300),
                                            //             )
                                            //           ],
                                            //         ),
                                            //       )),
                                            // ),
                                            Visibility(
                                              visible: authUser.role ==
                                                      'trainer' &&
                                                  myBookings[index]['gym_data']
                                                          ['gym_type'] !=
                                                      'normal',
                                              child: Container(
                                                child: ElevatedButton(
                                                  style: ButtonStyles
                                                      .bigFlatBlackButton(),
                                                  child: Text('Info'),
                                                  onPressed: () {
                                                    showInfo(myBookings[index]);
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )),
                              );
                            } else {

                              String formattedTimeString = tmFormat.format(
                                    DateTime.parse(
                                      myBookings[index]['start_time']+(myBookings[index]['service_data']!=null?'Z':''),
                                    ).toLocal(),
                                  ) +
                                  ' - ' +
                                  tmFormat.format(
                                    DateTime.parse(
                                      myBookings[index]['end_time']+(myBookings[index]['service_data']!=null?'Z':''),
                                    ).toLocal(),
                                  );
                              return Card(
                                margin: EdgeInsets.only(bottom: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Get.isDarkMode
                                          ? AppColors.primary2Color
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 18,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              HttpClient
                                                                      .s3BaseUrl +
                                                                  myBookings[index]
                                                                          [
                                                                          'gym']
                                                                      [
                                                                      'avatar_url']),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                            width:
                                                                Get.width - 140,
                                                            child: Text(
                                                              myBookings[index][
                                                                          'gym_data']
                                                                      [
                                                                      'gym_name']
                                                                  .toString()
                                                                  .capitalize
                                                                  .toString(),
                                                              style:
                                                                  TypographyStyles
                                                                      .title(
                                                                          16),
                                                            )),
                                                        Text(
                                                          "${CountryPickerUtils.getCountryByIsoCode(myBookings[index]['gym_data']['gym_country']).name}",
                                                          style:
                                                              TypographyStyles
                                                                  .text(14),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Divider(
                                                  thickness: 0.5,
                                                  color: Colors.white
                                                      .withOpacity(
                                                          0.23999999463558197),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          formattedTimeString,
                                                          style: TypographyStyles
                                                              .textWithWeight(
                                                                  16,
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          DateFormat("MMM dd,yyyy").format(
                                                                  DateTime.parse(
                                                                      myBookings[
                                                                              index]
                                                                          [
                                                                          'start_time']+'Z').toLocal()) +
                                                              ' - ' +
                                                              DateFormat(
                                                                      "MMM dd,yyyy")
                                                                  .format(DateTime.parse(
                                                                      myBookings[
                                                                              index]
                                                                          [
                                                                          'end_time']+'Z').toLocal()),
                                                          style: TypographyStyles
                                                              .textWithWeight(
                                                                  14,
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Map obj =
                                                  myBookings[index]['gym_data'];
                                              obj.addIf(
                                                  !obj.keys.contains('user'),
                                                  'user', {
                                                'avatar_url': myBookings[index]
                                                    ['gym']['avatar_url']
                                              });
                                              print('Gym view obj');
                                              print(obj);
                                              if (myBookings[index]
                                                      ['service_data'] !=
                                                  null) {
                                                obj['gym_gallery'] =
                                                    myBookings[index]
                                                            ['service_data']
                                                        ['gym_gallery'];
                                                obj["gym_services"] =
                                                    myBookings[index]
                                                        ['service_data'];
                                                obj["gym_type"] = "services";
                                              }
                                              Get.to(() => GymView(
                                                    gymObj: obj,
                                                    viewOnly: true,
                                                  ));
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          children: [
                                            // Container(
                                            //   height: 90,
                                            //   child: ElevatedButton(
                                            //     style: ElevatedButton.styleFrom(
                                            //         foregroundColor:
                                            //             Colors.white,
                                            //         backgroundColor:
                                            //             Colors.transparent,
                                            //         elevation: 0,
                                            //         shape:
                                            //             RoundedRectangleBorder(
                                            //                 borderRadius:
                                            //                     BorderRadius
                                            //                         .circular(
                                            //                             8))),
                                            //     onPressed: () {
                                            //       //unlockGym(myBookings[index]['gym_id']);
                                            //       Get.to(() => UnlockDoorQR(
                                            //           gymID: myBookings[index]
                                            //               ['gym_id']));
                                            //     },
                                            //     child: Image.asset(
                                            //       "assets/images/unlock_v2.png",
                                            //       height: 90,
                                            //       fit: BoxFit.fitHeight,
                                            //     ),
                                            //   ),
                                            // ),
                                            // TODO: Enable after Exclusive Confirm
                                            // InkWell(
                                            //   // onTap: () {
                                            //   //   //unlockGym(myBookings[index]['gym_id']);
                                            //   //   Get.to(() => UnlockDoorQR(
                                            //   //       QR: myBookings[index]
                                            //   //               ['user']['qr_id']
                                            //   //           .toString()));
                                            //   // },
                                            //   child: Container(
                                            //       width: 102,
                                            //       height: 108,
                                            //       padding:
                                            //           EdgeInsets.only(top: 10),
                                            //       decoration: BoxDecoration(
                                            //           color: Theme.of(context)
                                            //               .scaffoldBackgroundColor,
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   10)),
                                            //       child: Center(
                                            //         child: Column(
                                            //           children: [
                                            //             Image.asset(
                                            //               "assets/images/qr.png",
                                            //               fit: BoxFit.fitHeight,
                                            //               width: 36,
                                            //               height: 36,
                                            //             ),
                                            //             SizedBox(height: 10),
                                            //             Text(
                                            //               'Unlock \nDoor',
                                            //               textAlign:
                                            //                   TextAlign.center,
                                            //               style: TypographyStyles
                                            //                   .textWithWeight(
                                            //                       14,
                                            //                       FontWeight
                                            //                           .w300),
                                            //             )
                                            //           ],
                                            //         ),
                                            //       )),
                                            // ),
                                            // Visibility(
                                            //   visible: authUser.role ==
                                            //           'trainer' &&
                                            //       myBookings[index]['gym_data']
                                            //               ['gym_type'] !=
                                            //           'normal',
                                            //   child: Container(
                                            //     child: ElevatedButton(
                                            //       style: ButtonStyles
                                            //           .bigFlatBlackButton(),
                                            //       child: Text('Info'),
                                            //       onPressed: () {
                                            //         showInfo(myBookings[index]);
                                            //       },
                                            //     ),
                                            //   ),
                                            // )
                                          ],
                                        )
                                      ],
                                    )),
                              );
                              // return Card(
                              //   margin: EdgeInsets.only(bottom: 15),
                              //   shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(8)),
                              //   child: Container(
                              //       padding: EdgeInsets.all(15),
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(8),
                              //         color: Get.isDarkMode
                              //             ? colors.Colors().deepGrey(1)
                              //             : colors.Colors().selectedCardBG,
                              //       ),
                              //       child: Row(
                              //         children: [
                              //           Expanded(
                              //             child: InkWell(
                              //               child: Column(
                              //                 crossAxisAlignment:
                              //                     CrossAxisAlignment.start,
                              //                 children: [
                              //                   Row(
                              //                     mainAxisSize:
                              //                         MainAxisSize.min,
                              //                     children: [
                              //                       CircleAvatar(
                              //                         radius: 26,
                              //                         backgroundImage:
                              //                             CachedNetworkImageProvider(
                              //                                 HttpClient
                              //                                         .s3BaseUrl +
                              //                                     myBookings[index]
                              //                                             [
                              //                                             'gym']
                              //                                         [
                              //                                         'avatar_url']),
                              //                       ),
                              //                       SizedBox(
                              //                         width: 10,
                              //                       ),
                              //                       Column(
                              //                         crossAxisAlignment:
                              //                             CrossAxisAlignment
                              //                                 .start,
                              //                         mainAxisAlignment:
                              //                             MainAxisAlignment
                              //                                 .center,
                              //                         children: [
                              //                           Text(
                              //                             myBookings[index]
                              //                                     ['gym_data']
                              //                                 ['gym_name'],
                              //                             style: TypographyStyles.boldText(
                              //                                 20,
                              //                                 Get.isDarkMode
                              //                                     ? Themes
                              //                                         .mainThemeColorAccent
                              //                                         .shade100
                              //                                     : colors.Colors()
                              //                                         .lightBlack(
                              //                                             1)),
                              //                           ),
                              //                           Text(
                              //                             "${CountryPickerUtils.getCountryByIsoCode(myBookings[index]['gym_data']['gym_country']).name}",
                              //                             style: TypographyStyles.normalText(
                              //                                 14,
                              //                                 Get.isDarkMode
                              //                                     ? Themes
                              //                                         .mainThemeColorAccent
                              //                                         .shade100
                              //                                     : colors.Colors()
                              //                                         .lightBlack(
                              //                                             1)),
                              //                           ),
                              //                         ],
                              //                       ),
                              //                     ],
                              //                   ),
                              //                   SizedBox(
                              //                     height: 10,
                              //                   ),
                              //                   Divider(
                              //                     thickness: 1,
                              //                     color: Get.isDarkMode
                              //                         ? Colors.grey[700]
                              //                         : Colors.grey[400],
                              //                   ),
                              //                   Row(
                              //                     children: [
                              //                       Column(
                              //                         crossAxisAlignment:
                              //                             CrossAxisAlignment
                              //                                 .start,
                              //                         children: [
                              //                           Text(
                              //                             DateFormat(
                              //                                     "EEEE, MMM dd,yyyy")
                              //                                 .format(DateTime
                              //                                     .parse(myBookings[
                              //                                             index]
                              //                                         [
                              //                                         'start_time']))
                              //                                 .toString(),
                              //                             style: TypographyStyles.boldText(
                              //                                 15,
                              //                                 Get.isDarkMode
                              //                                     ? Themes
                              //                                         .mainThemeColorAccent
                              //                                         .shade100
                              //                                     : colors.Colors()
                              //                                         .lightBlack(
                              //                                             1)),
                              //                           ),
                              //                           SizedBox(
                              //                             height: 5,
                              //                           ),
                              //                           Text(
                              //                             tmFormat.format(DateTime
                              //                                     .parse(myBookings[
                              //                                             index]
                              //                                         [
                              //                                         'start_time'])) +
                              //                                 ' - ' +
                              //                                 tmFormat.format(
                              //                                     DateTime.parse(
                              //                                         myBookings[
                              //                                                 index]
                              //                                             [
                              //                                             'end_time'])),
                              //                             style: TypographyStyles.normalText(
                              //                                 13,
                              //                                 Get.isDarkMode
                              //                                     ? Themes
                              //                                         .mainThemeColorAccent
                              //                                         .shade100
                              //                                     : colors.Colors()
                              //                                         .lightBlack(
                              //                                             1)),
                              //                           ),
                              //                         ],
                              //                       ),
                              //                     ],
                              //                   ),
                              //                 ],
                              //               ),
                              //               borderRadius:
                              //                   BorderRadius.circular(8),
                              //               onTap: () {
                              //                 Get.to(() => GymView(
                              //                       gymObj: myBookings[index]
                              //                           ['gym_data'],
                              //                       viewOnly: true,
                              //                     ));
                              //               },
                              //             ),
                              //           ),
                              //           SizedBox(
                              //             width: 8,
                              //           ),
                              //           Column(
                              //             children: [
                              //               Container(
                              //                 height: 90,
                              //                 child: ElevatedButton(
                              //                   style: ButtonStyles
                              //                       .bigFlatBlackButton(),
                              //                   onPressed: () {
                              //                     //unlockGym(myBookings[index]['gym_id']);
                              //                     Get.to(() => UnlockDoorQR(
                              //                         gymID: myBookings[index]
                              //                             ['gym_id']));
                              //                   },
                              //                   child: Image.asset(
                              //                     "assets/images/unlock.png",
                              //                     height: 60,
                              //                     fit: BoxFit.fitHeight,
                              //                   ),
                              //                 ),
                              //               ),
                              //               Visibility(
                              //                 visible:
                              //                     authUser.role == 'trainer',
                              //                 child: Container(
                              //                   child: ElevatedButton(
                              //                     style: ButtonStyles
                              //                         .bigFlatBlackButton(),
                              //                     child: Text('Info'),
                              //                     onPressed: () {
                              //                       showInfo(myBookings[index]);
                              //                     },
                              //                   ),
                              //                 ),
                              //               )
                              //             ],
                              //           ),
                              //         ],
                              //       )),
                              // );
                            }
                          },
                        )
                      : Center(
                          child: Text(
                          'No Bookings Yet.',
                          style: TypographyStyles.normalText(
                              15, Themes.mainThemeColorAccent.shade300),
                        )),
                )
              ],
            ),
          )),
    );
  }
}

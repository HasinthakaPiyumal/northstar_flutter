import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/WatchDataController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/ContactUsPage.dart';
import 'package:north_star/UI/SharedWidgets/CommonProfileUpdate.dart';
import 'package:north_star/UI/SharedWidgets/QualificationsAddEdit.dart';
import 'package:north_star/UI/SharedWidgets/ReviewWidget.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class TrainerProfile extends StatefulWidget {
  const TrainerProfile({Key? key}) : super(key: key);

  @override
  State<TrainerProfile> createState() => _TrainerProfileState();
}

class _TrainerProfileState extends State<TrainerProfile> {
  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxBool isDarkMode = Get.isDarkMode.obs;

    final themeProvider = Provider.of<ThemeProvider>(context);

    TextEditingController aboutController = TextEditingController();

    RxMap data = {}.obs;
    RxMap reviews = {}.obs;

    void getProfile() async {
      ready.value = false;
      Map res = await httpClient.getMyProfile();

      if (res['code'] == 200) {
        data.value = res['data'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    void deleteQualification(id) async {
      ready.value = false;
      Map res = await httpClient.deleteQualification(id);
      if (res['code'] == 200) {
        getProfile();
      } else {
        print(res);
        ready.value = true;
      }
    }

    void updateAbout() async {
      ready.value = false;
      Map res = await httpClient.updateAbout({'about': aboutController.text});

      if (res['code'] == 200) {
        ready.value = true;
        Get.back();
        getProfile();
      } else {
        print(res);
        Get.back();
        ready.value = true;
      }
    }

    void getReviews() async {
      ready.value = false;
      Map res = await httpClient.getReviews(authUser.id);
      if (res['code'] == 200) {
        print(res['data']);
        reviews.value = res['data'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getProfile();

    getReviews();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => (ready.value &&
                    data.value.isNotEmpty &&
                    reviews.value.isNotEmpty)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          width: 124,
                          height: 124,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 124,
                                  height: 124,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          HttpClient.s3BaseUrl +
                                              data.value['avatar_url']),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 76.69,
                                child: Container(
                                  width: 124,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Color(0x88000000),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 36.75,
                                        top: 0,
                                        child: Container(
                                          width: 46,
                                          height: 46.50,
                                          // clipBehavior: Clip.antiAlias,
                                          child: Icon(
                                            Icons.camera_alt_rounded,
                                            color:
                                                Themes.mainThemeColor.shade500,
                                          ),
                                          // decoration: BoxDecoration(
                                          // ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(data.value['name'],
                          style: TypographyStyles.title(24)),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFFFB700),
                                    shape: StarBorder(
                                      points: 5,
                                      innerRadiusRatio: 0.38,
                                      pointRounding: 0,
                                      valleyRounding: 0,
                                      rotation: 0,
                                      squash: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  // '4.8 ( 6 reviews )',
                                  "${double.parse(data.value['trainer']['rating'].toString())} ( ${data.value['trainer']['rating_count']} reviews )",
                                  style: TypographyStyles.title(14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          themeProvider.toggleTheme();
                          // isDarkMode.value = value;
                        },
                        child: Container(
                          alignment: Alignment.bottomRight,
                          padding: EdgeInsets.only(right: 16),
                          child: Container(
                            width: 96,
                            height: 44,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 96,
                                    height: 44,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFF1E2630),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: Get.isDarkMode ? 56 : 4,
                                  top: 4,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: ShapeDecoration(
                                              color: Color(0xFFFFB700),
                                              shape: OvalBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 4,
                                  top: 4,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            child: Icon(
                                                Icons.light_mode_rounded,
                                                color: Get.isDarkMode
                                                    ? Color(0xFFFFFFFF)
                                                    : Color(0xFF1B1F24)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 56,
                                  top: 4,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            child: Icon(Icons.dark_mode,
                                                color: !Get.isDarkMode
                                                    ? Color(0xFFFFFFFF)
                                                    : Color(0xFF1B1F24)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Qualifications',
                                style: TypographyStyles.title(20)),
                            TextButton(
                                onPressed: () {
                                  Get.to(QualificationsAddEdit())
                                      ?.then((value) {
                                    getProfile();
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  clipBehavior: Clip.antiAlias,
                                  padding: EdgeInsets.all(5.0),
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFFFB700),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  child:
                                      Icon(Icons.add, color: Color(0xFF1B1F24)),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        height:
                            data.value['qualifications'].length > 0 ? 164 : 8,
                        width: Get.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: data.value['qualifications'].length,
                          itemBuilder: (_, index) {
                            return InkWell(
                              onLongPress: () {
                                Get.defaultDialog(
                                  radius: 8,
                                  title: 'Delete/Edit',
                                  backgroundColor: Get.isDarkMode
                                      ? Color(0xFF1E2630)
                                      : Color(0xFFffffff),
                                  content: Text(
                                      'Are you sure you want to delete/edit this qualification?',
                                      textAlign: TextAlign.center),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Get.back();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Delete'),
                                      onPressed: () {
                                        Get.back();
                                        deleteQualification(
                                            data.value['qualifications'][index]
                                                ['id']);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Edit'),
                                      onPressed: () {
                                        Get.back();
                                        Get.to(() => QualificationsAddEdit(
                                            qData: data.value['qualifications']
                                                [index]))?.then((value) {
                                          getProfile();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                  width: Get.width * 0.75,
                                  margin: index == 0
                                      ? EdgeInsets.only(left: 8)
                                      : EdgeInsets.only(left: 14, right: 8),
                                  child: Card(
                                    color: Get.isDarkMode
                                        ? Color(0xFF1E2630)
                                        : Color(0xFFffffff),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: 36,
                                            child: Image.asset(
                                              "assets/images/award_v2.png",
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          SizedBox(width: 18),
                                          Text(
                                              data.value['qualifications']
                                                      [index]['title']
                                                  .toString(),
                                              style:
                                                  TypographyStyles.title(16)),
                                          SizedBox(height: 10.0),
                                          Text(
                                            data.value['qualifications'][index]
                                                ['description'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Get.isDarkMode
                                                    ? Colors.white
                                                    : Color(0xFF1B1F24),
                                                fontFamily: 'Poppins',
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: ShapeDecoration(
                          color: Get.isDarkMode
                              ? AppColors.primary2Color
                              : AppColors.baseColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      child:
                                          Icon(Icons.account_circle_outlined),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('About',
                                      style: TypographyStyles.textWithWeight(
                                          16, FontWeight.w400)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(data['trainer']['about'],
                                    style: TypographyStyles.textWithWeight(
                                        12, FontWeight.w300)),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Get.isDarkMode
                                        ? AppColors.textColorDark
                                        : AppColors.textColorLight,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    aboutController.text =
                                        data.value['trainer']['about'];
                                    Get.defaultDialog(
                                        radius: 5,
                                        title: 'Edit About',
                                        titleStyle:
                                            TypographyStyles.smallBoldTitle(26),
                                        backgroundColor: Get.isDarkMode
                                            ? AppColors.primary2Color
                                            : Colors.white,
                                        titlePadding:
                                            EdgeInsets.only(top: 30.0),
                                        content: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: aboutController,
                                            maxLength: 250,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                                hintText: 'About',
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 50,
                                                        horizontal: 20)),
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              style: ButtonStyles
                                                  .bigFlatYellowButton(),
                                              onPressed: () {
                                                if (aboutController
                                                    .text.isEmpty) {
                                                  showSnack(
                                                      'About field is Empty',
                                                      'Please fill the about field');
                                                } else {
                                                  updateAbout();
                                                }
                                              },
                                              child: Container(
                                                width: Get.width / 4,
                                                child: Center(
                                                  child: Text('SAVE',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF1B1F24),
                                                        fontSize: 20,
                                                        fontFamily:
                                                            'Bebas Neue',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      )),
                                                ),
                                              )),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.transparent,
                                                  backgroundColor: Get
                                                          .isDarkMode
                                                      ? AppColors.primary2Color
                                                      : Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: AppColors
                                                              .accentColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Container(
                                                width: Get.width / 4,
                                                child: Center(
                                                  child: Text('Cancel',
                                                      style: TypographyStyles
                                                          .smallBoldTitle(20)),
                                                ),
                                              )),
                                        ]);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: ShapeDecoration(
                          color: Get.isDarkMode
                              ? Color(0xFF1E2630)
                              : Color(0xFFffffff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        margin: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Container(
                              width: 103,
                              height: 44,
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      child:
                                          Icon(Icons.account_circle_outlined),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text('Profile',
                                      style: TypographyStyles.textWithWeight(
                                          16, FontWeight.w400)),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text('Phone',
                                          style: TypographyStyles.title(16)),
                                      SizedBox(height: 24),
                                      Text('Birth Day',
                                          style: TypographyStyles.title(16)),
                                      SizedBox(height: 26),
                                      Text('Email',
                                          style: TypographyStyles.title(16)),
                                      SizedBox(height: 26),
                                      Text('Gender',
                                          style: TypographyStyles.title(16)),
                                      SizedBox(height: 26),
                                      Text('NIC/Passport',
                                          style: TypographyStyles.title(16)),
                                      SizedBox(height: 26),
                                      Text('Shipping Address',
                                          style: TypographyStyles.title(16)),
                                      SizedBox(height: 26),
                                      Text('Country',
                                          style: TypographyStyles.title(16)),
                                      SizedBox(height: 26),
                                      Text('Has Insurance',
                                          style: TypographyStyles.title(16)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(data.value['phone'],
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w400)),
                                      SizedBox(height: 28),
                                      Text(data.value['birthday'],
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w400)),
                                      SizedBox(height: 28),
                                      Text(data.value['email'],
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w400)),
                                      SizedBox(height: 28),
                                      Text(
                                          data.value['gender']
                                              .toString()
                                              .toUpperCase(),
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w400)),
                                      SizedBox(height: 28),
                                      Text(data.value['nic'],
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w400)),
                                      SizedBox(height: 28),
                                      Text(data.value['address'],
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w400)),
                                      SizedBox(height: 28),
                                      Text(data.value['country_code'],
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w400)),
                                      SizedBox(height: 28),
                                      Text(
                                          data.value['trainer']['is_insured']
                                              ? 'Yes'
                                              : 'No',
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w400)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.to(CommonProfileUpdate(userObj: data.value))
                                    ?.then((value) {
                                  getProfile();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFFFB700),
                                // Set the background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: Text(
                                'edit your information',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1B1F24),
                                  fontSize: 20,
                                  fontFamily: 'Bebas Neue',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 388,
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Health Data Sync',
                                  style: TypographyStyles.title(20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 48,
                              height: 24,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () async {
                                        var value =
                                            !authUser.user['health_data'];
                                        ready.value = false;
                                        if (value) {
                                          bool hasPermissions =
                                              await WatchDataController
                                                  .requestPermission();
                                          if (!hasPermissions) {
                                            showSnack('Permission Denied',
                                                'Please allow permission to sync health data');
                                            ready.value = true;
                                          } else {
                                            await httpClient
                                                .toggleHealthDataConsent();
                                            await authUser.checkAuth();
                                            showSnack('Permission Granted',
                                                'Health data will be synced');
                                            ready.value = true;
                                          }
                                        } else {
                                          await httpClient
                                              .toggleHealthDataConsent();
                                          await authUser.checkAuth();
                                          ready.value = true;
                                        }
                                      },
                                      child: Container(
                                        width: 48,
                                        height: 24,
                                        decoration: ShapeDecoration(
                                          color: !authUser.user['health_data']
                                              ? Colors.transparent
                                              : Color(0xFFFFB700),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 0.75,
                                                color: Color(0xFFFFB700)),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left:
                                        !authUser.user['health_data'] ? 4 : 28,
                                    top: 4,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: ShapeDecoration(
                                        color: !authUser.user['health_data']
                                            ? Color(0xFFFFB700)
                                            : Colors.white,
                                        shape: OvalBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: reviewWidget(reviews, data),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFB800),
                      ),
                    ),
                  )),
            // Obx(() => (ready.value &&
            //         data.value.isNotEmpty &&
            //         reviews.value.isNotEmpty)
            //     ? Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           SizedBox(height: 16),
            //           Padding(
            //             padding: EdgeInsets.symmetric(horizontal: 16),
            //             child: Row(
            //               children: [
            //                 CircleAvatar(
            //                   radius: 32,
            //                   backgroundImage: CachedNetworkImageProvider(
            //                       HttpClient.s3BaseUrl +
            //                           data.value['avatar_url']),
            //                 ),
            //                 SizedBox(
            //                   width: 10,
            //                 ),
            //                 Expanded(
            //                   child: Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Text(data.value['name'],
            //                           style: TypographyStyles.title(24)),
            //                       SizedBox(height: 7),
            //                       Row(
            //                         children: [
            //                           Text(
            //                               "${data.value['trainer']['rating'].toStringAsFixed(1)}"),
            //                           SizedBox(width: 5),
            //                           RatingBarIndicator(
            //                             rating: double.parse(data
            //                                 .value['trainer']['rating']
            //                                 .toString()),
            //                             itemBuilder: (context, index) => Icon(
            //                               Icons.star,
            //                               color: colors.Colors().deepYellow(1),
            //                             ),
            //                             itemCount: 5,
            //                             itemSize: 15.0,
            //                             direction: Axis.horizontal,
            //                             unratedColor:
            //                                 colors.Colors().darkGrey(1),
            //                           ),
            //                           SizedBox(
            //                             width: 15,
            //                           ),
            //                           Text(
            //                             "${data.value['trainer']['rating_count']} reviews",
            //                             style: TypographyStyles.boldText(
            //                                 14, Colors.blue),
            //                           ),
            //                         ],
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //                 IconButton(
            //                   onPressed: () {
            //                     Get.to(() => UploadAvatar())?.then((value) {
            //                       getProfile();
            //                     });
            //                   },
            //                   icon: Icon(Icons.edit,
            //                       color: Themes.mainThemeColor),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           SizedBox(height: 16),
            //           Divider(thickness: 1),
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 16),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Text('Qualifications',
            //                         style: TypographyStyles.title(20)),
            //                     TextButton(
            //                         onPressed: () {
            //                           Get.to(QualificationsAddEdit())
            //                               ?.then((value) {
            //                             getProfile();
            //                           });
            //                         },
            //                         child: Text('Add'))
            //                   ],
            //                 ),
            //               ),
            //               SizedBox(height: 5),
            //               Container(
            //                 height: data.value['qualifications'].length > 0
            //                     ? 100
            //                     : 8,
            //                 width: Get.width,
            //                 child: ListView.builder(
            //                   scrollDirection: Axis.horizontal,
            //                   itemCount: data.value['qualifications'].length,
            //                   itemBuilder: (_, index) {
            //                     return InkWell(
            //                       onLongPress: () {
            //                         Get.defaultDialog(
            //                           radius: 8,
            //                           title: 'Delete/Edit',
            //                           content: Text(
            //                               'Are you sure you want to delete/edit this qualification?',
            //                               textAlign: TextAlign.center),
            //                           actions: [
            //                             TextButton(
            //                               child: Text('Cancel'),
            //                               onPressed: () {
            //                                 Get.back();
            //                               },
            //                             ),
            //                             TextButton(
            //                               child: Text('Delete'),
            //                               onPressed: () {
            //                                 Get.back();
            //                                 deleteQualification(
            //                                     data.value['qualifications']
            //                                         [index]['id']);
            //                               },
            //                             ),
            //                             TextButton(
            //                               child: Text('Edit'),
            //                               onPressed: () {
            //                                 Get.back();
            //                                 Get.to(() => QualificationsAddEdit(
            //                                     qData: data
            //                                             .value['qualifications']
            //                                         [index]))?.then((value) {
            //                                   getProfile();
            //                                 });
            //                               },
            //                             ),
            //                           ],
            //                         );
            //                       },
            //                       borderRadius: BorderRadius.circular(8),
            //                       child: Container(
            //                           width: Get.width * 0.75,
            //                           margin: index == 0
            //                               ? EdgeInsets.only(left: 16)
            //                               : EdgeInsets.zero,
            //                           child: Card(
            //                             child: Padding(
            //                               padding: EdgeInsets.symmetric(
            //                                   vertical: 5, horizontal: 20),
            //                               child: Column(
            //                                 crossAxisAlignment:
            //                                     CrossAxisAlignment.start,
            //                                 mainAxisAlignment:
            //                                     MainAxisAlignment.center,
            //                                 children: [
            //                                   Row(
            //                                     children: [
            //                                       Container(
            //                                         width: 18,
            //                                         child: Image.asset(
            //                                           "assets/images/award.png",
            //                                           color: isDarkMode.value ==
            //                                                   true
            //                                               ? colors.Colors()
            //                                                   .deepYellow(1)
            //                                               : Colors.black,
            //                                           fit: BoxFit.fitWidth,
            //                                         ),
            //                                       ),
            //                                       SizedBox(width: 15),
            //                                       Text(
            //                                           data.value[
            //                                                   'qualifications']
            //                                                   [index]['title']
            //                                               .toString(),
            //                                           style: TypographyStyles
            //                                               .title(16))
            //                                     ],
            //                                   ),
            //                                   SizedBox(height: 8.0),
            //                                   Text(
            //                                     data.value['qualifications']
            //                                         [index]['description'],
            //                                     textAlign: TextAlign.left,
            //                                     style: TextStyle(
            //                                         color: Colors.grey[500],
            //                                         fontSize: 14),
            //                                   )
            //                                 ],
            //                               ),
            //                             ),
            //                           )),
            //                     );
            //                   },
            //                 ),
            //               ),
            //               SizedBox(height: 16),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 16),
            //                 child: Row(
            //                   children: [
            //                     Text('About',
            //                         style: TypographyStyles.title(20)),
            //                     Spacer(),
            //                     IconButton(
            //                       icon: Icon(
            //                         Icons.edit,
            //                         color: Themes.mainThemeColor,
            //                       ),
            //                       onPressed: () {
            //                         aboutController.text =
            //                             data.value['trainer']['about'];
            //                         Get.defaultDialog(
            //                             radius: 8,
            //                             title: 'Edit About',
            //                             content: TextField(
            //                               controller: aboutController,
            //                               decoration: InputDecoration(
            //                                 hintText: 'About',
            //                               ),
            //                             ),
            //                             actions: [
            //                               ElevatedButton(
            //                                   style: SignUpStyles
            //                                       .notSelectedButton(),
            //                                   onPressed: () {
            //                                     Get.back();
            //                                   },
            //                                   child: Text('Cancel')),
            //                               ElevatedButton(
            //                                   style:
            //                                       SignUpStyles.selectedButton(),
            //                                   onPressed: () {
            //                                     if (aboutController
            //                                         .text.isEmpty) {
            //                                       showSnack(
            //                                           'About field is Empty',
            //                                           'Please fill the about field');
            //                                     } else {
            //                                       updateAbout();
            //                                     }
            //                                   },
            //                                   child: Text('  Save  ')),
            //                             ]);
            //                       },
            //                     )
            //                   ],
            //                 ),
            //               ),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 16),
            //                 child: Row(
            //                   children: [
            //                     Text(data['trainer']['about'],
            //                         style: TypographyStyles.normalText(
            //                             16,
            //                             Get.isDarkMode
            //                                 ? Themes
            //                                     .mainThemeColorAccent.shade500
            //                                     .withOpacity(0.6)
            //                                 : colors.Colors().lightBlack(1))),
            //                     Spacer(),
            //                   ],
            //                 ),
            //               ),
            //               SizedBox(height: 20),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 16),
            //                 child: Row(
            //                   children: [
            //                     Text('Profile',
            //                         style: TypographyStyles.title(20)),
            //                     Spacer(),
            //                     IconButton(
            //                       icon: Icon(
            //                         Icons.edit,
            //                         color: Themes.mainThemeColor,
            //                       ),
            //                       onPressed: () {
            //                         Get.to(CommonProfileUpdate(
            //                                 userObj: data.value))
            //                             ?.then((value) {
            //                           getProfile();
            //                         });
            //                       },
            //                     )
            //                   ],
            //                 ),
            //               ),
            //               SizedBox(height: 16),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 16),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Text('Phone',
            //                             style: TypographyStyles.normalText(
            //                                 16,
            //                                 Get.isDarkMode
            //                                     ? Themes.mainThemeColorAccent
            //                                         .shade500
            //                                         .withOpacity(0.6)
            //                                     : colors.Colors()
            //                                         .lightBlack(1))),
            //                         SizedBox(height: 24),
            //                         Text('Birth Day',
            //                             style: TypographyStyles.normalText(
            //                                 16,
            //                                 Get.isDarkMode
            //                                     ? Themes.mainThemeColorAccent
            //                                         .shade500
            //                                         .withOpacity(0.6)
            //                                     : colors.Colors()
            //                                         .lightBlack(1))),
            //                         SizedBox(height: 24),
            //                         Text('Email',
            //                             style: TypographyStyles.normalText(
            //                                 16,
            //                                 Get.isDarkMode
            //                                     ? Themes.mainThemeColorAccent
            //                                         .shade500
            //                                         .withOpacity(0.6)
            //                                     : colors.Colors()
            //                                         .lightBlack(1))),
            //                         SizedBox(height: 24),
            //                         Text('Gender',
            //                             style: TypographyStyles.normalText(
            //                                 16,
            //                                 Get.isDarkMode
            //                                     ? Themes.mainThemeColorAccent
            //                                         .shade500
            //                                         .withOpacity(0.6)
            //                                     : colors.Colors()
            //                                         .lightBlack(1))),
            //                         SizedBox(height: 24),
            //                         Text('NIC/Passport',
            //                             style: TypographyStyles.normalText(
            //                                 16,
            //                                 Get.isDarkMode
            //                                     ? Themes.mainThemeColorAccent
            //                                         .shade500
            //                                         .withOpacity(0.6)
            //                                     : colors.Colors()
            //                                         .lightBlack(1))),
            //                         SizedBox(height: 24),
            //                         Text('Shipping Address',
            //                             style: TypographyStyles.normalText(
            //                                 16,
            //                                 Get.isDarkMode
            //                                     ? Themes.mainThemeColorAccent
            //                                         .shade500
            //                                         .withOpacity(0.6)
            //                                     : colors.Colors()
            //                                         .lightBlack(1))),
            //                         SizedBox(height: 24),
            //                         Text('Country',
            //                             style: TypographyStyles.normalText(
            //                                 16,
            //                                 Get.isDarkMode
            //                                     ? Themes.mainThemeColorAccent
            //                                         .shade500
            //                                         .withOpacity(0.6)
            //                                     : colors.Colors()
            //                                         .lightBlack(1))),
            //                         SizedBox(height: 24),
            //                         Text('Has Insurance',
            //                             style: TypographyStyles.normalText(
            //                                 16,
            //                                 Get.isDarkMode
            //                                     ? Themes.mainThemeColorAccent
            //                                         .shade500
            //                                         .withOpacity(0.6)
            //                                     : colors.Colors()
            //                                         .lightBlack(1))),
            //                         SizedBox(height: 24),
            //                       ],
            //                     ),
            //                     Column(
            //                       crossAxisAlignment: CrossAxisAlignment.end,
            //                       mainAxisAlignment: MainAxisAlignment.start,
            //                       children: [
            //                         Text(data.value['phone'],
            //                             style: TypographyStyles.title(16)),
            //                         SizedBox(height: 24),
            //                         Text(data.value['birthday'],
            //                             style: TypographyStyles.title(16)),
            //                         SizedBox(height: 24),
            //                         Text(data.value['email'],
            //                             style: TypographyStyles.title(16)),
            //                         SizedBox(height: 24),
            //                         Text(
            //                             data.value['gender']
            //                                 .toString()
            //                                 .toUpperCase(),
            //                             style: TypographyStyles.title(16)),
            //                         SizedBox(height: 24),
            //                         Text(data.value['nic'],
            //                             style: TypographyStyles.title(16)),
            //                         SizedBox(height: 24),
            //                         Text(data.value['address'],
            //                             style: TypographyStyles.title(16)),
            //                         SizedBox(height: 24),
            //                         Text(data.value['country_code'],
            //                             style: TypographyStyles.title(16)),
            //                         SizedBox(height: 24),
            //                         Text(
            //                             data.value['trainer']['is_insured']
            //                                 ? 'Yes'
            //                                 : 'No',
            //                             style: TypographyStyles.title(16)),
            //                         SizedBox(height: 24),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               SizedBox(height: 10),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 16),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Text('Dark Mode'),
            //                     CupertinoSwitch(
            //                       value: isDarkMode.value,
            //                       onChanged: (value) {
            //                         themeProvider.toggleTheme();
            //                         isDarkMode.value = value;
            //                       },
            //                       // onChanged: (value){
            //                       //   SharedPreferences.getInstance().then((prefs){
            //                       //     prefs.setBool('darkMode', value);
            //                       //   });
            //                       //   print(value);
            //                       //   isDarkMode.value = value;
            //                       //   //Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
            //                       //   showSnack('Theme Changed!', 'Please Reopen the App');
            //                       // },
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               SizedBox(height: 10),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 16),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Text('Health Data Sync'),
            //                     CupertinoSwitch(
            //                       value: authUser.user['health_data'],
            //                       onChanged: (bool value) async {
            //                         ready.value = false;
            //                         if (value) {
            //                           bool hasPermissions =
            //                               await WatchDataController
            //                                   .requestPermission();
            //                           if (!hasPermissions) {
            //                             showSnack('Permission Denied',
            //                                 'Please allow permission to sync health data');
            //                             ready.value = true;
            //                           } else {
            //                             await httpClient
            //                                 .toggleHealthDataConsent();
            //                             await authUser.checkAuth();
            //                             showSnack('Permission Granted',
            //                                 'Health data will be synced');
            //                             ready.value = true;
            //                           }
            //                         } else {
            //                           await httpClient
            //                               .toggleHealthDataConsent();
            //                           await authUser.checkAuth();
            //                         }
            //                       },
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               SizedBox(height: 10),
            //
            //               SizedBox(height: 16),
            //             ],
            //           ),
            //         ],
            //       )
            //     : Center(
            //         child: Container(
            //           margin: const EdgeInsets.all(16),
            //           child: CircularProgressIndicator(),
            //         ),
            //       )),

            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // decoration: ShapeDecoration(
            //   color: Color(0xFFFFB700),
            //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            // )
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: MaterialButton(
                  onPressed: () {
                    Get.to(() => ContactUsPage());
                  },
                  color: AppColors.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Contact North Star',
                    style: TextStyle(
                      color: AppColors.textOnAccentColor,
                      fontSize: 20,
                      fontFamily: 'Bebas Neue',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: MaterialButton(
                    onPressed: () {
                      showSignOutDialog();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                            width: 1.25, color: AppColors.accentColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Get.isDarkMode
                              ? AppColors.textColorDark
                              : AppColors.textColorLight,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: Get.isDarkMode
                                ? AppColors.textColorDark
                                : AppColors.textColorLight,
                            fontSize: 20,
                            fontFamily: 'Bebas Neue',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            SizedBox(height: 20),
            Text(HttpClient.buildInfo),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

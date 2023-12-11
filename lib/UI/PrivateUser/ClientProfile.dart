import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/WatchDataController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetTrainers/TrainerView.dart';
import 'package:north_star/UI/PrivateUser/ClientAccountInfo.dart';
import 'package:north_star/UI/PrivateUser/CompleteUserProfile.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/UploadAvatar.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:provider/provider.dart';

import '../../Models/NSNotification.dart';
import '../../components/CheckButton.dart';
import '../../main.dart';
import '../HelpAndSupport/HelpAndSupportHome.dart';
import '../HomeWidgets/ContactUsPage.dart';

class ClientProfile extends StatelessWidget {
  const ClientProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxBool isDarkMode = Get.isDarkMode.obs;
    TextEditingController commentController = TextEditingController();
    Map<String, dynamic> data = {};

    final themeProvider = Provider.of<ThemeProvider>(context);

    void getProfile() async {
      ready.value = false;
      Map res = await httpClient.getMyProfile();
      if (res['code'] == 200) {
        data = res['data'];
        print(data);
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    void removeTrainer(trainerID, type) async {
      ready.value = false;
      Map res = await httpClient.removeTrainer({
        'trainer_id': trainerID.toString(),
        'type': type,
      }, trainerID);

      if (res['code'] == 200) {

        Get.back();
        getProfile();
      } else {
        print(res);
        ready.value = true;
      }
    }

    void newReview(int trainerId, int rating, String comment) async {
      Map res = await httpClient.newReview({
        'reviewee': trainerId,
        'rating': rating,
        'comment': comment,
      });
      if (res['code'] == 200) {
        Get.back();
        showSnack('Review Added!', 'Your review has been added successfully!');
        getProfile();
      } else {
        print(res);
        ready.value = true;
      }
    }

    void authCheck() async {
      print('authCheck');
      AuthUser().checkAuth();
    }

    getProfile();
    authCheck();

    RxDouble noOfStars = 0.0.obs;

    Widget alert(BuildContext context, var data) {
      print(data);

      OutlineInputBorder commonBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Get.isDarkMode
              ? Themes.mainThemeColorAccent.shade500.withOpacity(0.5)
              : colors.Colors().lightBlack(0.5),
        ),
      );

      TextStyle commonTextStyle = TypographyStyles.text(14);

      return AlertDialog(
        backgroundColor:
            Get.isDarkMode ? colors.Colors().deepGrey(1) : Color(0xFFF2F2F2),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: CachedNetworkImageProvider(
                  HttpClient.s3BaseUrl + data['avatar_url']),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data['name'], style: TypographyStyles.title(16)),
                SizedBox(
                  height: 5,
                ),
                Text(data['email'], style: TypographyStyles.text(14)),
              ],
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rate Your Trainer",
              style: TypographyStyles.text(14),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: Get.width / 100 * 60,
              child: RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                itemSize: 35,
                unratedColor: Get.isDarkMode
                    ? Themes.mainThemeColorAccent.shade500.withOpacity(0.5)
                    : colors.Colors().selectedCardBG,
                glow: true,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Themes.mainThemeColor.shade500,
                ),
                onRatingUpdate: (rating) {
                  print(rating);
                  noOfStars.value = rating;
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Write a Review",
              style: TypographyStyles.text(14),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                border: commonBorder,
                focusedBorder: commonBorder,
                enabledBorder: commonBorder,
                labelStyle: commonTextStyle,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 15,
                ),
                hintText: "write here...",
                hintStyle: commonTextStyle,
              ),
            )
          ],
        ),
        actionsPadding: EdgeInsets.only(bottom: 15),
        contentPadding: EdgeInsets.fromLTRB(25, 20, 25, 10),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: MaterialButton(
              onPressed: () async {
                newReview(data['id'], noOfStars.value.toInt(),
                    commentController.text);
              },
              minWidth: Get.width,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "SUBMIT",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              minWidth: Get.width,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Get.isDarkMode
                        ? Themes.mainThemeColorAccent.shade500.withOpacity(0.5)
                        : colors.Colors().darkGrey(1),
                  )),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "CANCEL",
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget trainerCard(String type, Map data) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Get.isDarkMode
              ? colors.Colors().deepGrey(1)
              : colors.Colors().lightCardBG,
        ),
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: CachedNetworkImageProvider(
                              HttpClient.s3BaseUrl + data[type]['avatar_url']),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data[type]['name'],
                                style: TypographyStyles.title(16)),
                            SizedBox(
                              height: 5,
                            ),
                            Text(data[type]['email'],
                                style: TypographyStyles.text(14)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        CommonConfirmDialog.confirm('Remove').then((value) {
                          if (value) {
                            removeTrainer(
                                data[type]['id'],
                                type == 'physical_trainer'
                                    ? 'physical'
                                    : 'diet');
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 1,
                  color: Themes.mainThemeColorAccent.shade300.withOpacity(0.5),
                ),
                Container(
                  width: Get.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            Map res = await httpClient
                                .getOneUser(data[type]['id'].toString());
                            Get.to(() =>
                                TrainerView(trainerObj: res['data']['user']));
                          },
                          child: Text(
                            "View Profile",
                            style: TypographyStyles.boldText(
                              14,
                              Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade100
                                  : colors.Colors().lightBlack(1),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    alert(context, data[type]));
                          },
                          elevation: 0,
                          shape: StadiumBorder(),
                          color:
                              Themes.mainThemeColor.shade500.withOpacity(0.15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rate_review_rounded,
                                color: Get.isDarkMode
                                    ? Themes.mainThemeColor.shade500
                                    : colors.Colors().lightBlack(1),
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Write a Review",
                                style: TypographyStyles.boldText(
                                  14,
                                  Get.isDarkMode
                                      ? Themes.mainThemeColor.shade500
                                      : colors.Colors().lightBlack(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(() => ready.value && data['user']!=null
                  ? Column(
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
                                                data['user']['avatar_url']),
                                        fit: BoxFit.cover,
                                      ),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 76.69,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => UploadAvatar())
                                          ?.then((value) {
                                        getProfile();
                                      });
                                    },
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
                                                color: Themes
                                                    .mainThemeColor.shade500,
                                              ),
                                              // decoration: BoxDecoration(
                                              // ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(data['user']['name'],
                            style: TypographyStyles.title(24)),
                        const SizedBox(height: 10),
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
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => ClientAccountInfo());
                                },
                                child: Container(
                                  // width: 189,
                                  height: 126,
                                  padding: const EdgeInsets.all(10),
                                  decoration: ShapeDecoration(
                                    color: Get.isDarkMode
                                        ? AppColors.primary2Color
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/paste.png"),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: 146,
                                        child: Text(
                                          'Account Information',
                                          textAlign: TextAlign.center,
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  16, FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => CompleteUserProfile());
                                },
                                child: Container(
                                  // width: 189,
                                  height: 126,
                                  padding: const EdgeInsets.all(10),
                                  decoration: ShapeDecoration(
                                    color: Get.isDarkMode
                                        ? AppColors.primary2Color
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/firstaidbox.png"),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: 146,
                                        child: Text(
                                          'Health Information',
                                          textAlign: TextAlign.center,
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  16, FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Primary Trainer',
                                style: TypographyStyles.title(16)),
                            Visibility(
                              visible: data['physical_trainer'] != null &&
                                  data['diet_trainer'] != null,
                              child: Tooltip(
                                message:
                                    "A person who works one-on-one\nwith a client to plan or implement an\nexercise or fitness regimen.",
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                textStyle: TypographyStyles.normalText(
                                    14, Themes.mainThemeColorAccent.shade100),
                                triggerMode: TooltipTriggerMode.tap,
                                waitDuration: Duration(seconds: 2),
                                showDuration: Duration(seconds: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black,
                                ),
                                child: Icon(Icons.info_outline),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        data['physical_trainer'] != null
                            ? Container(
                                decoration: BoxDecoration(
                                    color: colors.Colors().deepGrey(1),
                                    borderRadius: BorderRadius.circular(12)),
                                child: trainerCard('physical_trainer', data))
                            : Container(
                                padding: EdgeInsets.only(top: 25),
                                child: Center(
                                  child: Text('No Physical Trainer',
                                      style: TypographyStyles.text(16).copyWith(
                                          color: colors.Colors().darkGrey(1))),
                                )),
                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Secondary Trainer',
                                style: TypographyStyles.title(16)),
                            Visibility(
                              visible: data['physical_trainer'] != null &&
                                  data['diet_trainer'] != null,
                              child: Tooltip(
                                message:
                                    "Facilitating the incorporation of\nhealthy eating behaviors and empowering\ntheir clients to take responsibility\nfor their health",
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                textStyle: TypographyStyles.normalText(
                                    14, Themes.mainThemeColorAccent.shade100),
                                triggerMode: TooltipTriggerMode.tap,
                                waitDuration: Duration(seconds: 2),
                                showDuration: Duration(seconds: 2),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black),
                                child: Icon(Icons.info_outline),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        data['diet_trainer'] != null
                            ? Container(
                                decoration: BoxDecoration(
                                    color: colors.Colors().deepGrey(1),
                                    borderRadius: BorderRadius.circular(12)),
                                child: trainerCard('diet_trainer', data))
                            : Container(
                                padding: EdgeInsets.only(top: 25),
                                child: Center(
                                  child: Text('No Diet Trainer',
                                      style: TypographyStyles.text(16).copyWith(
                                          color: colors.Colors().darkGrey(1))),
                                )),
                        SizedBox(height: 8),
                        Visibility(
                          visible: data['physical_trainer'] != null &&
                              data['diet_trainer'] != null,
                          child: Container(
                            child: ElevatedButton(
                              onPressed: () {
                                CommonConfirmDialog.confirm('Switch')
                                    .then((value) {
                                  if (value) {
                                    ready.value = false;
                                    httpClient.switchTrainers().then((value) {
                                      getProfile();
                                    });
                                  }
                                });
                              },
                              child: Text('Switch Trainers'),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 16),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            ready.value = false;
                            if (!authUser.user['health_data']) {
                              bool hasPermissions =
                                  await WatchDataController.requestPermission();
                              if (!hasPermissions) {
                                showSnack('Permission Denied',
                                    'Please allow permission to sync health data');
                                ready.value = true;
                              } else {
                                await httpClient.toggleHealthDataConsent();
                                await authUser.checkAuth();
                                showSnack('Permission Granted',
                                    'Health data will be synced');
                                ready.value = true;
                              }
                            } else {
                              await httpClient.toggleHealthDataConsent();
                              await authUser.checkAuth();
                              showSnack('Permission Revoked',
                                  'Health data will not be synced');
                              ready.value = true;
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Health Data Sync'),
                              CheckButton(
                                isChecked: authUser.user['health_data'],
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    )),
              SizedBox(height: 30),
              Buttons.outlineTextIconButton(
                  onPressed: () {
                    Get.to(() => HelpAndSupportHome());
                  },
                  label: "Help And Support",
                  width: Get.width - 32,
                  icon: Icons.help),
              SizedBox(height: 10,),
              Buttons.yellowFlatButton(onPressed: () {
                Get.to(() => ContactUsPage());
              },label: "Contact North Start",width: double.infinity),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Buttons.outlineTextIconButton(
                    onPressed: () {
                      showSignOutDialog();
                    },
                    label: "logout",
                    icon: Icons.logout),
              ),
              SizedBox(height: 20),
              Text(HttpClient.buildInfo),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/WatchDataController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetTrainers/TrainerView.dart';
import 'package:north_star/UI/PrivateUser/ClientAccountInfo.dart';
import 'package:north_star/UI/PrivateUser/CompleteUserProfile.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/UploadAvatar.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
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
              Obx(() => ready.value
                  ? Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          leading: CircleAvatar(
                            radius: 32,
                            backgroundImage: CachedNetworkImageProvider(
                                HttpClient.s3BaseUrl +
                                    data['user']['avatar_url']),
                          ),
                          title: Text(data['user']['name'],
                              style: TypographyStyles.title(24)),
                          trailing: IconButton(
                            onPressed: () {
                              Get.to(() => UploadAvatar())?.then((value) {
                                getProfile();
                              });
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Get.isDarkMode
                                  ? Themes.mainThemeColor
                                  : colors.Colors().lightBlack(1),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton(
                          style: Get.isDarkMode
                              ? ButtonStyles.matRadButton(Colors.black, 0, 12)
                              : ButtonStyles.matRadButton(
                                  colors.Colors().selectedCardBG, 0, 12),
                          onPressed: () {
                            Get.to(() => ClientAccountInfo());
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 22, horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Account Information",
                                  style: TypographyStyles.text(15),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: Get.isDarkMode
                              ? ButtonStyles.matRadButton(Colors.black, 0, 12)
                              : ButtonStyles.matRadButton(
                                  colors.Colors().selectedCardBG, 0, 12),
                          onPressed: () {
                            Get.to(() => CompleteUserProfile());
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 22, horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Health Information",
                                  style: TypographyStyles.text(15),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                )
                              ],
                            ),
                          ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Dark Mode'),
                            CupertinoSwitch(
                              value: isDarkMode.value,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                                isDarkMode.value = value;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Health Data Sync'),
                            CupertinoSwitch(
                              value: authUser.user['health_data'],
                              onChanged: (value) async {
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
                            ),
                          ],
                        )
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    )),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: MaterialButton(
                  onPressed: () {
                    Get.to(() => ContactUsPage());
                  },
                  color: colors.Colors().deepGrey(1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Contact North Star',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: MaterialButton(
                    onPressed: () {
                      showSignOutDialog();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'LOGOUT',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    )),
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

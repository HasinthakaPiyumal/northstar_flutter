import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetNotifications.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class NotificationsController {
  static RxList<NSNotification> notifications = RxList<NSNotification>([]);
  static RxBool ready = false.obs;

  static int lastNotificationId = 0;

  static List<NSNotificationTypes> requestTypes = [
    NSNotificationTypes.DietConsultationRequest,
    NSNotificationTypes.ClientRequest,
    NSNotificationTypes.ClientRequestWeb,
    NSNotificationTypes.TrainerRequest,
  ];

  static Future<bool> getNotifications() async {
    ready.value = false;
    Map res = await httpClient.getNotifications();
    print('printing notification ${res['data']}');
    if (res['code'] == 200) {
      print('notification loeader -->$res');
      print(authUser.name);
      notifications.value = List<NSNotification>.from(
          res['data'].map((x) => NSNotification.fromJson(x))).toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    ready.value = true;
    return true;
  }

  static Future<bool> readAllNotifications() async {
    await httpClient.readAllNotifications();
    await getNotifications();
    return true;
  }

  static int getUnreadNotificationsCount() {
    return notifications.where((element) => element.hasSeen == false).length;
  }

  static int getUnreadNotificationsCountByType(NSNotificationTypes type) {
    return notifications
        .where((element) => element.hasSeen == false && element.type == type)
        .length;
  }

  static int getUnreadRequestNotificationsCount() {
    return notifications
        .where((element) =>
            element.hasSeen == false && requestTypes.contains(element.type))
        .length;
  }

  static List<NSNotification> getRequestNotifications() {
    notifications.forEach((element) {
      print("====notification");
      print(element.type == NSNotificationTypes.DietConsultationRequest );
      print(requestTypes.contains(element.type) );
      print(element.type );
    });
    return notifications
        .where((element) => requestTypes.contains(element.type))
        .toList();
  }

  static void actions(NSNotification notification, Function selectItem,
      Set selectedList, Function selectAll, Function deleteSelected) async {
    Get.bottomSheet(Card(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: !notification.hasSeen,
              child: ListTile(
                leading: Icon(Icons.mark_email_read),
                title: Text('Mark as Read'),
                onTap: () {
                  Get.back();
                  notification.readNotification();
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.select_all_outlined),
              title: Text(
                  selectedList.contains(notification) ? 'Unselect' : 'Select'),
              onTap: () {
                Get.back();
                selectItem(notification);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Select All'),
              onTap: () {
                Get.back();
                selectAll();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title:
                  Text(selectedList.length > 0 ? 'Delete Selected' : 'Delete'),
              onTap: () {
                Get.back();
                if (selectedList.length > 0) {
                  deleteSelected();
                } else {
                  notification.deleteNotification();
                }
              },
            ),
          ],
        ),
      ),
    ));
  }

  static void showNotificationsPrompt() {
    int currentLastNotificationId = notifications.first.id;
    if (getUnreadNotificationsCount() > 0 && lastNotificationId!=currentLastNotificationId) {
      lastNotificationId = currentLastNotificationId;
      Get.dialog(
          AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          height: 240,
          width: Get.width,
          child: Stack(
            children: [
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        flex: 1,
                        child: Container(
                          color: Colors.transparent,
                        )),
                    Flexible(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? AppColors.primary2Color
                                : colors.Colors().lightWhite(1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            height: 110,
                            width: 110,
                            child: Lottie.asset(
                                'assets/lotties/notifications.json'),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'You have new notifications',
                            style: TypographyStyles.boldText(
                                18,
                                Get.isDarkMode
                                    ? Themes.mainThemeColorAccent.shade100
                                    : colors.Colors().lightBlack(1)),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Please check notification center',
                            style: TypographyStyles.normalText(
                                13, Themes.mainThemeColorAccent.shade300),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      // Get.to(() => HomeWidgetNotifications());
                                      NotificationsController.readAllNotifications();
                                      Get.back();
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        'Read All',
                                        style: TypographyStyles.boldText(
                                            16,
                                            Themes
                                                .mainThemeColorAccent.shade100),
                                      ),
                                    ),
                                    color: AppColors.primary2Color,
                                    shape: StadiumBorder(
                                        side: BorderSide(color: Colors.white)),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.to(() => HomeWidgetNotifications());
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        'View',
                                        style: TypographyStyles.boldText(
                                            16,
                                           AppColors.textOnAccentColor),
                                      ),
                                    ),
                                    color: AppColors.accentColor,
                                    shape: StadiumBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),);
    }
  }
}

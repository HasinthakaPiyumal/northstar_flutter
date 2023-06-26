import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class NotificationsController{
  static RxList<NSNotification> notifications = RxList<NSNotification>([]);
  static RxBool ready = false.obs;

  static List<NSNotificationTypes> requestTypes = [
    NSNotificationTypes.ClientRequest,
    NSNotificationTypes.ClientRequestWeb,
    NSNotificationTypes.TrainerRequest,
  ];

  static Future<bool> getNotifications() async {
    ready.value = false;
    Map res = await httpClient.getNotifications();
    if(res['code'] == 200){
      notifications.value = List<NSNotification>.from(res['data'].map((x) => NSNotification.fromJson(x))).toList();
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

  static int getUnreadNotificationsCount(){
    return notifications.where((element) => element.hasSeen == false).length;
  }
  static int getUnreadNotificationsCountByType(NSNotificationTypes type){
    return notifications.where((element) => element.hasSeen == false && element.type == type).length;
  }

  static int getUnreadRequestNotificationsCount(){
    return notifications.where((element) => element.hasSeen == false && requestTypes.contains(element.type)).length;
  }

  static List<NSNotification> getRequestNotifications(){
    return notifications.where((element) => requestTypes.contains(element.type)).toList();
  }

  static void actions(NSNotification notification) async {
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
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Get.back();
                notification.deleteNotification();
              },
            ),
          ],
        ),
      ),
    ));
  }

  static void showNotificationsPrompt(){
    if(getUnreadNotificationsCount() > 0){
      Get.dialog(
          AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.transparent,
            content: Container(
              height: 230,
              child: Stack(
                children: [
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(flex: 1,child: Container(color: Colors.transparent,)),
                        Flexible(flex: 3,child:
                        Container(
                          decoration: BoxDecoration(
                            color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightWhite(1),
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
                        Flexible(flex: 2,child: Container(color: Colors.transparent,
                          child: Center(
                            child: Container(
                              height: 110,
                              width: 110,
                              child: Lottie.asset('assets/lotties/notifications.json'),
                            ),
                          ),
                        ),),
                        Flexible(flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('You have new notifications',
                                style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5,),
                              Text('Please check notification center',
                                style: TypographyStyles.normalText(13, Themes.mainThemeColorAccent.shade300),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 15,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Text('OK',
                                        style: TypographyStyles.boldText(16, Themes.mainThemeColorAccent.shade100),
                                      ),
                                    ),
                                    color: Themes.mainThemeColor.shade600,
                                    shape: StadiumBorder(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
      );
    }
  }



}

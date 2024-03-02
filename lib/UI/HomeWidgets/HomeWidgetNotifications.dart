import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/NotificationsController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetNotifications/AllNotifications.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetNotifications/RequestsNotifications.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/components/Buttons.dart';

import 'HomeWidgetPro.dart';

class HomeWidgetNotifications extends StatelessWidget {
  const HomeWidgetNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    NotificationsController.getNotifications();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          TextButton.icon(
            label: Text(
              "Read All",
              style: TypographyStyles.boldText(
                  12, Themes.mainThemeColorAccent.shade300),
            ),
            icon: Icon(
              Icons.playlist_add_check,
              color: Themes.mainThemeColorAccent.shade300,
            ),
            onPressed: () => NotificationsController.readAllNotifications(),
          )
        ],
      ),
      body: Obx(() => NotificationsController.ready.value
          ? DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Column(
                children: [
                  Visibility(visible:(authUser.role=='trainer'||authUser.role=='client') && authUser.user['subscription'] == null,child: Container(margin: EdgeInsets.symmetric(vertical: 10),child: Buttons.yellowTextIconButton(textColor:Colors.white,backgroundColor:Colors.red,icon:Icons.lock_open,label: "Unlock the pro version",onPressed: (){Get.to(() => HomeWidgetPro());},width: Get.width-40))),
                  TabBar(
                    tabs: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("All Notifications"),
                            SizedBox(
                              width: 5,
                            ),
                            Visibility(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.circle,
                                      size: 20,
                                      color: Themes.mainThemeColor.shade600),
                                  Positioned(
                                    child: Obx(() => Text(
                                          "${NotificationsController.getUnreadNotificationsCount()}",
                                          style: TypographyStyles.boldText(
                                            12,
                                            Themes.mainThemeColorAccent,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                              visible: NotificationsController.getUnreadNotificationsCount() > 0,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Requests"),
                            SizedBox(
                              width: 5,
                            ),
                            Visibility(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.circle,
                                      size: 20,
                                      color: Themes.mainThemeColor.shade600),
                                  Positioned(
                                    child: Obx(() => Text(
                                          "${NotificationsController.getUnreadRequestNotificationsCount()}",
                                          style: TypographyStyles.boldText(
                                            12,
                                            Themes.mainThemeColorAccent,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                              visible: NotificationsController.getUnreadRequestNotificationsCount() > 0,
                            )
                          ],
                        ),
                      ),
                    ],
                    labelStyle: Theme.of(context).textTheme.titleMedium,
                    labelColor: Themes.mainThemeColor.shade600,
                    unselectedLabelColor: Get.isDarkMode
                        ? Themes.mainThemeColorAccent.shade100
                        : colors.Colors().lightBlack(1),
                    indicatorColor: Themes.mainThemeColor.shade600,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        AllNotifications(),
                        RequestsNotifications(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : LoadingAndEmptyWidgets.loadingWidget()),
    );
  }
}

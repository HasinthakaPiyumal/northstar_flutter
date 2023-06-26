import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/NotificationsController.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Models/NSNotification.dart';
class AllNotifications extends StatelessWidget {
  const AllNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: NotificationsController.notifications.length > 0
          ? Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Obx(()=>ListView.builder(
                itemCount: NotificationsController.notifications.length,
                itemBuilder: (_, index) {
                  NSNotification notification = NotificationsController.notifications[index];

                  return Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: notification.hasSeen
                            ? Get.isDarkMode
                            ? colors.Colors().deepGrey(1)
                            : colors.Colors().lightCardBG
                            : Get.isDarkMode
                            ? Color(0xFF6D5D4A)
                            : colors.Colors().selectedCardBG,
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 12),
                        child: InkWell(
                          onLongPress: () {
                            NotificationsController.actions(notification);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: TypographyStyles.boldText(
                                          16,
                                          Get.isDarkMode
                                              ? Themes
                                              .mainThemeColorAccent.shade100
                                              : colors.Colors()
                                              .lightBlack(0.7)),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      notification.description,
                                      style: TypographyStyles.normalText(
                                          15,
                                          Get.isDarkMode
                                              ? Colors.white54
                                              : colors.Colors().darkGrey(0.7)),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      "${DateFormat("dd-MMM-yyyy").format(notification.createdAt)} | ${DateFormat("HH:mm").format(notification.createdAt)}",
                                      style: TypographyStyles.boldText(
                                          12,
                                          Get.isDarkMode
                                              ? Colors.white30
                                              : colors.Colors().darkGrey(0.5)),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: notification.hasSeen
                                    ? null
                                    : Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Get.isDarkMode
                                      ? Themes.mainThemeColor.shade600
                                      : colors.Colors().lightBlack(1),
                                ),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              )),
            )
          : LoadingAndEmptyWidgets.emptyWidget(),
    );
  }
}

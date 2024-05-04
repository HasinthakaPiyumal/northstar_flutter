import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/NotificationsController.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class AllNotifications extends StatefulWidget {
  const AllNotifications({Key? key}) : super(key: key);

  @override
  State<AllNotifications> createState() => _AllNotificationsState();
}

class _AllNotificationsState extends State<AllNotifications> {
  Set<NSNotification> selectedList = <NSNotification>{};

  @override
  Widget build(BuildContext context) {
    void selectItem(NSNotification notification) {
      setState(() {
        if (selectedList.contains(notification)) {
          selectedList.remove(notification);
        } else {
          selectedList.add(notification);
        }
      });
    }

    void selectAll() {
      setState(() {
        selectedList =
            Set<NSNotification>.from(NotificationsController.notifications);
      });
    }
    void deleteSelected(){
      selectedList.forEach((element) {
        element.deleteSelectedNotification();
      });
    }
    print(NotificationsController.notifications);
    print('NotificationsController.notifications');

    return Scaffold(
      body: NotificationsController.notifications.length > 0
          ? Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Obx(() => ListView.builder(
                    itemCount: NotificationsController.notifications.length,
                    itemBuilder: (_, index) {
                      NSNotification notification =
                          NotificationsController.notifications[index];

                      return Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: notification.hasSeen
                                ? Get.isDarkMode
                                    ? AppColors.primary2Color
                                    : colors.Colors().lightCardBG
                                : Get.isDarkMode
                                    ? Color(0xFF6D5D4A)
                                    : colors.Colors().selectedCardBG,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                selectedList.length > 0 ? 0 : 15,
                                15,
                                selectedList.length > 0 ? 0 : 15,
                                12),
                            child: InkWell(
                              onLongPress: () {
                                NotificationsController.actions(notification,
                                    selectItem, selectedList, selectAll,deleteSelected);
                              },
                              onTap: () {
                                if (selectedList.length > 0) {
                                  selectItem(notification);
                                }else{
                                  notification.readNotification(askConfirm: false);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Visibility(
                                      visible: selectedList.length > 0,
                                      child: Checkbox(
                                        splashRadius: 15,
                                        visualDensity: VisualDensity(
                                            horizontal: -4.0, vertical: -4.0),
                                        value:
                                            selectedList.contains(notification),
                                        onChanged: (bool? value) {
                                          selectItem(notification);
                                        },
                                      )),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title,
                                          style: TypographyStyles.boldText(
                                              16,Get.isDarkMode?Colors.white:Colors.black),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          notification.description,
                                          style: TypographyStyles.text(
                                            14),),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          "${DateFormat("dd MMMM yyyy - HH:mm").format(notification.createdAt)}",
                                          style: TypographyStyles.text(
                                              14)
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

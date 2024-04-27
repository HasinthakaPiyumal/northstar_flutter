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

import '../../Styles/AppColors.dart';
import 'HomeWidgetPro.dart';

class HomeWidgetNotifications extends StatefulWidget {
  const HomeWidgetNotifications({Key? key}) : super(key: key);

  @override
  State<HomeWidgetNotifications> createState() => _HomeWidgetNotificationsState();
}

class _HomeWidgetNotificationsState extends State<HomeWidgetNotifications> with SingleTickerProviderStateMixin {
  late TabController tabController;
  int index = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    tabController.addListener(() {
      setState(() {
        index = tabController.index;
      });
    });
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
      body: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Column(
                children: [
                  Visibility(visible:(authUser.role=='trainer'||authUser.role=='client') && authUser.user['subscription'] == null,child: Container(margin: EdgeInsets.symmetric(vertical: 10),child: Buttons.yellowTextIconButton(textColor:Colors.white,backgroundColor:Colors.red,icon:Icons.lock_open,label: "Unlock the pro version",onPressed: (){Get.to(() => HomeWidgetPro());},width: Get.width-40))),
                  // TabBar(
                  //   tabs: [
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(vertical: 10),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text("All Notifications"),
                  //           SizedBox(
                  //             width: 5,
                  //           ),
                  //           Visibility(
                  //             child: Stack(
                  //               alignment: Alignment.center,
                  //               children: [
                  //                 Icon(Icons.circle,
                  //                     size: 20,
                  //                     color: Themes.mainThemeColor.shade600),
                  //                 Positioned(
                  //                   child: Obx(() => Text(
                  //                         "${NotificationsController.getUnreadNotificationsCount()}",
                  //                         style: TypographyStyles.boldText(
                  //                           12,
                  //                           Themes.mainThemeColorAccent,
                  //                         ),
                  //                       )),
                  //                 )
                  //               ],
                  //             ),
                  //             visible: NotificationsController.getUnreadNotificationsCount() > 0,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(vertical: 10),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text("Requests"),
                  //           SizedBox(
                  //             width: 5,
                  //           ),
                  //           Visibility(
                  //             child: Stack(
                  //               alignment: Alignment.center,
                  //               children: [
                  //                 Icon(Icons.circle,
                  //                     size: 20,
                  //                     color: Themes.mainThemeColor.shade600),
                  //                 Positioned(
                  //                   child: Obx(() => Text(
                  //                         "${NotificationsController.getUnreadRequestNotificationsCount()}",
                  //                         style: TypographyStyles.boldText(
                  //                           12,
                  //                           Themes.mainThemeColorAccent,
                  //                         ),
                  //                       )),
                  //                 )
                  //               ],
                  //             ),
                  //             visible: NotificationsController.getUnreadRequestNotificationsCount() > 0,
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  //   labelStyle: Theme.of(context).textTheme.titleMedium,
                  //   labelColor: Themes.mainThemeColor.shade600,
                  //   unselectedLabelColor: Get.isDarkMode
                  //       ? Themes.mainThemeColorAccent.shade100
                  //       : colors.Colors().lightBlack(1),
                  //   indicatorColor: Themes.mainThemeColor.shade600,
                  //   indicatorSize: TabBarIndicatorSize.tab,
                  // ),
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color:Get.isDarkMode? AppColors.primary2Color:Colors.white,borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Expanded(child: Buttons.yellowFlatButton(useDefaultFont:true,label: "All Notifications ${NotificationsController.getUnreadNotificationsCount() > 0?'(${NotificationsController.getUnreadRequestNotificationsCount()})':''}",onPressed: (){tabController.animateTo(0);},backgroundColor: index==0?AppColors.accentColor:Colors.transparent,textColor: index==0?AppColors.textOnAccentColor:Get.isDarkMode?Colors.white:Colors.black)),
                      SizedBox(width: 5,),
                      Expanded(child: Buttons.yellowFlatButton(useDefaultFont:true,label: "Requests ${NotificationsController.getUnreadRequestNotificationsCount() > 0?'(${NotificationsController.getUnreadRequestNotificationsCount()})':''}",onPressed: (){tabController.animateTo(1);},backgroundColor: index==1?AppColors.accentColor:Colors.transparent,textColor: index==1?AppColors.textOnAccentColor:Get.isDarkMode?Colors.white:Colors.black)),
                    ],),),
                  Expanded(
                    child: Obx(() => NotificationsController.ready.value
                        ? TabBarView(
                      controller: tabController,
                      children: [
                        AllNotifications(),
                        RequestsNotifications(),
                      ],
                    ):LoadingAndEmptyWidgets.loadingWidget()),
                  ),
                ],
              ),
            )
          ,
    );
  }
}

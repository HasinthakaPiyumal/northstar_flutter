import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/LocalNotificationsController.dart';
import 'package:north_star/Controllers/NotificationsController.dart';
import 'package:north_star/Controllers/TaxController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/IcoMoon.dart';
import 'package:north_star/UI/Chats/ChatHome.dart';
import 'package:north_star/UI/Home.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetCalls.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetNotifications.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetPro.dart';
import 'package:north_star/UI/Members.dart';
import 'package:north_star/UI/Members/UserView_Health.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorHome.dart';
import 'package:north_star/UI/PrivateTrainer/TrainerProfile.dart';
import 'package:north_star/UI/PrivateUser/ClientCalories.dart';
import 'package:north_star/UI/PrivateUser/ClientProfile.dart';
import 'package:north_star/UI/SharedWidgets/ExitWidget.dart';
import 'package:north_star/UI/Wallet.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Layout extends StatefulWidget {
  const Layout({Key? key}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final RxInt currentPage = 0.obs;
  String preferenceName = "homeViewTabIndex";
  late Rx<PageController> pgController;

  @override
  void dispose() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(preferenceName, 0);
    pgController.close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    pgController = PageController(initialPage: currentPage.value).obs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //bool hasShown = false;

    Future<int?> retrieveSelectedTabIndex() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int val = prefs.getInt(preferenceName)!;
      currentPage.value = val;
      print('$preferenceName $val ------> Getting');
      return prefs.getInt(preferenceName);
    }

    Future<void> saveSelectedTabIndex(int index) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      print('$preferenceName $index ------> Setting');
      prefs.setInt(preferenceName, index);
    }
    taxController.refresh();
    retrieveSelectedTabIndex();

    void checkPermissions() async {
      await [
        Permission.camera,
        Permission.microphone,
        Permission.activityRecognition,
        Permission.photos
      ].request();

      FlutterLocalNotificationsPlugin fNP = FlutterLocalNotificationsPlugin();
      await fNP
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
      await LocalNotificationsController.init();
    }

    checkPermissions();

    Widget bNavBar() {
      return WillPopScope(
        onWillPop: () async {
          showDialog(
            context: context,
            builder: (context) => const ExitWidget(),
          );
          return shouldPop;
        },
        child: Container(
          decoration: BoxDecoration(
            // color: Get.isDarkMode ? Color(0xff1C1C1C) : Colors.white,
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, -1),
                blurRadius: 10,
              ),
            ],
          ),
          // padding: EdgeInsets.symmetric(vertical: 10),
          child: Obx(() {
            return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                backgroundColor:
                    Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                selectedItemColor: AppColors.accentColor,
                currentIndex: currentPage.value,
                onTap: (int index) {
                  currentPage.value = index;
                  saveSelectedTabIndex(index);
                  pgController.value.jumpToPage(index);
                },
                selectedFontSize: 0,
                unselectedFontSize: 0,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: [
                  Buttons.bottomNavbarButton(label: "Home",pathname: "home.svg"),
                  authUser.role == 'trainer'
                      ? Buttons.bottomNavbarButton(label: "Members",pathname: "members.svg")
                      : Buttons.bottomNavbarButton(label: "Calories",pathname: "calories.svg"),
                  authUser.role == 'trainer'
                      ?
                  Buttons.bottomNavbarButton(label: "eWallet",pathname: "ewallet.svg")
                      : Buttons.bottomNavbarButton(label: "Health",pathname: "health.svg"),
                  authUser.role == 'trainer'
                      ? Buttons.bottomNavbarButton(label: "Profile",pathname: "profile.svg")
                      : Buttons.bottomNavbarButton(label: "Profile",pathname: "profile.svg"),
                ]);
          }),
        ),
      );
    }

    if (authUser.role == 'doctor') {
      return WillPopScope(
        onWillPop: () async {
          showDialog(
            context: context,
            builder: (context) => const ExitWidget(),
          );
          return shouldPop;
        },
        child: DoctorHome(),
      );
    } else {
      return WillPopScope(
        onWillPop: () async {
          showDialog(
            context: context,
            builder: (context) => const ExitWidget(),
          );
          return shouldPop;
        },
        child: Scaffold(
          bottomNavigationBar: bNavBar(),
          appBar: AppBar(
            toolbarHeight: 50,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: false,
            title: Container(
              height: 21,
              child: Image.asset(
                  Get.isDarkMode
                      ? 'assets/allwhite.png'
                      : 'assets/allblack.png',
                  fit: BoxFit.fitHeight),
            ),
            actions: [
              Obx(() => IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      Get.to(() => HomeWidgetNotifications());
                    },
                    icon:
                        NotificationsController.getUnreadNotificationsCount() >
                                0
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset("assets/svgs/notification-bell.svg",
                                      height: 24,width: 18, color: Colors.red),
                                  Positioned(
                                    child: Text(
                                        NotificationsController
                                                .getUnreadNotificationsCount()
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              )
                            : SvgPicture.asset("assets/svgs/notification-bell.svg",
                            height: 24,width: 24, color:Get.isDarkMode?Colors.white:AppColors.primary1Color),
                  )),
              IconButton(
                onPressed: authUser.user['subscription'] != null
                    ? () {
                        Get.to(() => ChatHome());
                      }
                    : () {
                        Get.to(() => HomeWidgetPro());
                      },
                splashRadius: 20,
                icon:  SvgPicture.asset("assets/svgs/message.svg",
    height: 24,width: 24,
                  color: authUser.user['subscription'] == null
                      ? Colors.grey[600]
                      : AppColors().getPrimaryColor(reverse: true),
                ),
              ),
              IconButton(
                splashRadius: 20,
                onPressed: authUser.user['subscription'] != null
                    ? () {
                        Get.to(() => HomeWidgetCalls());
                      }
                    : () {
                        Get.to(() => HomeWidgetPro());
                      },
                icon:  SvgPicture.asset("assets/svgs/call.svg",
    height: 24,width: 18,
                  color: authUser.user['subscription'] == null
                      ? Colors.grey[600]
                      : AppColors().getPrimaryColor(reverse: true),
                ),
              )
            ],
          ),
          body: Obx(() {
            return PageView(
                onPageChanged: (index) async {
                  currentPage.value = index;
                  await NotificationsController.getNotifications();
                  NotificationsController.showNotificationsPrompt();
                },
                controller: pgController.value,
                children: [
                  Home(),
                  authUser.role == 'trainer' ? Members() : UserCalories(),
                  authUser.role == 'trainer'
                      ? Wallet()
                      : UserViewHealth(userID: authUser.id,data:{}),
                  authUser.role == 'trainer'
                      ? TrainerProfile()
                      : ClientProfile(),
                ]);
          }),
        ),
      );
    }
  }
}

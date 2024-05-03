import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/IcoMoon.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetNotifications.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorPageController.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorPrivateProfile.dart';
import 'package:north_star/UI/PrivateDoctor/FrontPage.dart';
import 'package:north_star/UI/PrivateDoctor/Pending.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../Controllers/NotificationsController.dart';
import '../../components/Buttons.dart';
import 'Upcoming.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class DoctorHome extends StatefulWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {

  final RxInt currentPage = 0.obs;
  String preferenceName = "homeViewTabIndex";

  @override
  void dispose() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(preferenceName, 0);
    DoctorPageController.doctorPageController.close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    DoctorPageController.doctorPageController = PageController(initialPage: currentPage.value).obs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    RxInt currentPage = 0.obs;

    void getNotificationsAndShowPrompt() async {
      await NotificationsController.getNotifications();
      NotificationsController.showNotificationsPrompt();
    }
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
    getNotificationsAndShowPrompt();
    retrieveSelectedTabIndex();

    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          Duration(seconds: 1),
              () async {
            await NotificationsController.getNotifications();
            NotificationsController.showNotificationsPrompt();
          },
        );
      },
      child: Obx(()=>Scaffold(
          appBar: AppBar(
            toolbarHeight: 74,
            elevation: 0.5,
            centerTitle: false,
            title: Container(
              height: 30,
              child: Image.asset('assets/logo_white.png', fit: BoxFit.fitHeight,
                color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
              ),
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
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color:  Get.isDarkMode ? AppColors.primary2Color : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, -1),
                  blurRadius: 10,
                ),
              ],
            ),
            // padding: EdgeInsets.symmetric(vertical: 10),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Get.isDarkMode ? AppColors.primary2Color  : Colors.white,
              selectedItemColor: AppColors.accentColor,
              currentIndex: currentPage.value,
              type: BottomNavigationBarType.fixed,
              unselectedFontSize: 0,
              selectedFontSize: 0,
              items: [
                Buttons.bottomNavbarButton(label: "Home",pathname: "home.svg"),
                Buttons.bottomNavbarButton(label: "Requests",pathname: "requests.svg"),
                Buttons.bottomNavbarButton(label: "Schedules",pathname: "schedule.svg"),
                Buttons.bottomNavbarButton(label: "Profile",pathname: "profile.svg"),
              ],
              onTap: (index) {
                currentPage.value = index;
                DoctorPageController.doctorPageController.value.jumpToPage(index);
                saveSelectedTabIndex(index);
                DoctorPageController.doctorPageController.value.jumpToPage(index);
              },
            ),
          ),
          body: PageView(
            controller: DoctorPageController.doctorPageController.value,
            onPageChanged: (index) {
              currentPage.value = index;
            },
            children: [
              FrontPage(),
              Pending(),
              Upcoming(),
              DoctorPrivateProfile()
            ],
          )
      )),
    );
  }
}

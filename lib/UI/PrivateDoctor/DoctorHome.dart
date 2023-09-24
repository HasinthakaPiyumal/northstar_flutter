import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/IcoMoon.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorPageController.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorPrivateProfile.dart';
import 'package:north_star/UI/PrivateDoctor/FrontPage.dart';
import 'package:north_star/UI/PrivateDoctor/Pending.dart';


import '../../Controllers/NotificationsController.dart';
import 'Upcoming.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class DoctorHome extends StatefulWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  @override
  Widget build(BuildContext context) {

    RxInt currentPage = 0.obs;

    void getNotificationsAndShowPrompt() async {
      await NotificationsController.getNotifications();
      NotificationsController.showNotificationsPrompt();
    }

    getNotificationsAndShowPrompt();

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
            title: Container(
              height: 30,
              child: Image.asset('assets/logo_white.png', fit: BoxFit.fitHeight,
                color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
              ),
            ),
            actions: [
              IconButton(
                onPressed: (){},
                icon: Icon(Icons.notifications, size: 28),
              ),
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
            padding: EdgeInsets.symmetric(vertical: 10),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Get.isDarkMode ? AppColors.primary2Color  : Colors.white,
              selectedItemColor: AppColors.accentColor,
              currentIndex: currentPage.value,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Icon(IcoMoon.home),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Icon(Icons.medical_services_rounded),
                  ),
                  label: 'Requests',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Icon(Icons.videocam),
                  ),
                  label: 'Schedules',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Icon(Icons.person),
                  ),
                  label: 'Profile',
                ),
              ],
              onTap: (index) {
                currentPage.value = index;
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

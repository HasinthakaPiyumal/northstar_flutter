import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClasses/ActiveClasses.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClasses/RejectedClasses.dart';

import '../../components/Buttons.dart';

class Classes extends StatefulWidget {
  const Classes();

  @override
  _ClassesState createState() => _ClassesState();
}

class _ClassesState extends State<Classes> with SingleTickerProviderStateMixin {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Classes"),
          // bottom: TabBar(
          //   controller: tabController,
          //   indicatorSize: TabBarIndicatorSize.tab,
          //   tabs: [Tab(text: 'Tab 1'), Tab(text: 'Tab 2')],
          // ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color:Get.isDarkMode? AppColors.primary2Color:Colors.white,borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
              Expanded(child: Buttons.yellowFlatButton(label: "Active",onPressed: (){tabController.animateTo(0);},backgroundColor: index==0?AppColors.accentColor:Colors.transparent,textColor: index==0?AppColors.textOnAccentColor:Get.isDarkMode?Colors.white:Colors.black)),
                SizedBox(width: 5,),
              Expanded(child: Buttons.yellowFlatButton(label: "Rejected",onPressed: (){tabController.animateTo(1);},backgroundColor: index==1?AppColors.accentColor:Colors.transparent,textColor: index==1?AppColors.textOnAccentColor:Get.isDarkMode?Colors.white:Colors.black)),
            ],),),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  ActiveClasses(),
                  RejectedClasses(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}

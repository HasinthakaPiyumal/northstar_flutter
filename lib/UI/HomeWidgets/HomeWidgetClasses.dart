import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';

import '../../components/Buttons.dart';

class Classes extends StatefulWidget {
  const Classes();

  @override
  _ClassesState createState() => _ClassesState();
}

class _ClassesState extends State<Classes> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
              Expanded(child: Buttons.yellowFlatButton(label: "Active",onPressed: (){})),
                SizedBox(width: 5,),
              Expanded(child: Buttons.yellowFlatButton(label: "Rejected",onPressed: (){},backgroundColor: AppColors.accentColor)),
            ],),),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  Column(children: [
                    
                  ],),
                  Center(child: Text('Tab 2 Content')),
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

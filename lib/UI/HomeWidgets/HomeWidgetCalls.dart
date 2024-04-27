import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetCalls/CallHistory.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetCalls/Dialer.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Styles/AppColors.dart';

import '../../components/Buttons.dart';
class HomeWidgetCalls extends StatefulWidget {
  const HomeWidgetCalls({Key? key}) : super(key: key);

  @override
  State<HomeWidgetCalls> createState() => _HomeWidgetCallsState();
}

class _HomeWidgetCallsState extends State<HomeWidgetCalls> {

  Widget _lastSelected = Dialer();
  int _currentIndex = 0;

  void _change(int index) {
    setState(() {
      _currentIndex = index;
      if(index == 0){
        _lastSelected = Dialer();
      }else if(index == 1){
        _lastSelected = CallHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(_currentIndex == 0 ? 'Contacts': 'Recent Calls',style: TypographyStyles.title(20),),
      ),
      body: _lastSelected,
      bottomNavigationBar: SizedBox(
        // height: 70,
        child: BottomNavigationBar(
          selectedItemColor: AppColors.accentColor,
          backgroundColor: Utils.isDarkMode() ? AppColors.primary2Color : Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Get.isDarkMode ? AppColors.textColorDark :AppColors.textColorLight,
          currentIndex: _currentIndex,
          onTap: _change,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          items: [
            Buttons.bottomNavbarButton(label: "Contacts",pathname: "contact.svg"),
            Buttons.bottomNavbarButton(label: "Recent",pathname: "recent.svg"),
          ],
        ),
      ),
    );
  }
}



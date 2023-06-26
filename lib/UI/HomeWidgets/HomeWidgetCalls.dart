import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetCalls/CallHistory.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetCalls/Dialer.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

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
        title: _currentIndex == 0 ? Text('Contacts') : Text('Recent Calls'),
      ),
      body: _lastSelected,
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          selectedItemColor: colors.Colors().deepYellow(1),
          backgroundColor: Utils.isDarkMode() ? Theme.of(context).focusColor : Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.6) : colors.Colors().lightBlack(0.5),
          currentIndex: _currentIndex,
          onTap: _change,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt,),
              label: "Contacts",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time,),
              label: "Recent",
            ),
          ],
        ),
      ),
    );
  }
}



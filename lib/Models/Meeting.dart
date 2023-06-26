import 'package:flutter/material.dart';
import 'package:north_star/Styles/Themes.dart';

class Meeting{
  late String eventName;
  late DateTime from;
  late DateTime to;
  Color background = Themes.mainThemeColor;
  bool isAllDay = false;

  Meeting(Map data){
    this.eventName = '${data['title']} [ ${data['type']} ]';
    this.from = DateTime.parse(data['start'].toString());
    this.to = DateTime.parse(data['end'].toString());
    this.background = data['type'] == 'TODO' ?
      Colors.green : data['type'] == 'TRAINER MEETING' ?
      Colors.blue: data['type'] == 'GYM BOOKING' ? Colors.purple: Colors.red;
  }
}

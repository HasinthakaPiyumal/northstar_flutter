import 'package:north_star/Models/HttpClient.dart';

class ProWidgetController{
  List list = [
    'Dashboard',
    'Exercise Bank',
    'Todo',
    'Video Sessions',
    'Resources',
    'Doctors',
    'Calls',
    'Client Notes',
    'Fitness Calculator',
    'Calories',
    'Lab Reports',
    'Online Clinic',
    'Physiotherapy'
  ];

  Future<void> getProWidget() async {
    Map data = await httpClient.getProWidgets();
    if(data['code']==200){
      list = data['data'];
      print('pro widget list');
      print(list);
    }
  }
}

ProWidgetController proWidgetController = ProWidgetController();
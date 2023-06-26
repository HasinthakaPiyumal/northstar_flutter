import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

class CallHistory extends StatelessWidget {
  const CallHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList callHistory = [].obs;

    void getCallHistory() async {
      Map res = await httpClient.getCallHistory();
      if (res['code'] == 200) {
        callHistory.value = res['data'];
      }
    }

    getCallHistory();
    return Scaffold(
        body: Obx(()=>callHistory.isEmpty ? LoadingAndEmptyWidgets.emptyWidget() : ListView.builder(
         itemCount: callHistory.length,
         itemBuilder: (context, index) {
           return Column(
             children: [
               ListTile(
                 title: Text('Calling ' + callHistory[index]['receiver']['name']),
                 subtitle: Text(callHistory[index]['created_at'].split('T')[0] + ' ' + callHistory[index]['created_at'].split('T')[1].split('.')[0]),
                 trailing: Text(callHistory[index]['duration'].toString() + ' seconds'),
               ),
               Divider(
                 thickness: 1,
               ),
             ],
           );
         },
       )),
    );
  }
}

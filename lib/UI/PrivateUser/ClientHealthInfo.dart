import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/PrivateUser/CompleteUserProfile.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

class ClientHealthInfo extends StatelessWidget {

  const ClientHealthInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;
    var data = {};

    void getProfile() async{
      ready.value = false;
      Map res = await httpClient.getMyProfile();
      if (res['code'] == 200) {
        data = res['data'];
        print(data);
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getProfile();

    return Scaffold(
      appBar: AppBar(
        title: Text("Health Information"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Themes.mainThemeColor,),
            onPressed: (){
              Get.to(()=>CompleteUserProfile())?.then((value){
                getProfile();
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Obx(()=>ready.value ? data["health_conditions"] != null ? ListView.builder(
                itemCount: data["health_conditions"].length,
                itemBuilder: (context, index){
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10,),
                      Text("${data["health_conditions"][index]}",
                        style: TypographyStyles.text(15),
                      ),
                      SizedBox(height: 10,),
                      Divider(
                        thickness: 1,
                        color: Themes.mainThemeColorAccent.shade300.withOpacity(0.3),
                      )
                    ],
                  );
                },) : LoadingAndEmptyWidgets.emptyWidget() : Center(child: CircularProgressIndicator(),)),
            )
          ],
        )
      ),
    );
  }
}

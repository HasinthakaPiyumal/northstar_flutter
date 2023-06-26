import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDashboard/WatchData.dart';
import 'package:north_star/UI/Members/UserView.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/UI/SharedWidgets/RingsWidget.dart';
import 'package:north_star/UI/SharedWidgets/WatchDataWidget.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;


class HomeWidgetCalories extends StatelessWidget {
  const HomeWidgetCalories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList macrosData = [].obs;



    void getAllUserMacrosData() async {
      Map res = await httpClient.getHomeWidgetCalories();

      if (res['code'] == 200) {
        macrosData.value = res['data'];
        macrosData.removeWhere((element) => element['user_id'] == authUser.id);
        ready.value = true;
        print(res['data']);
      } else {
        print(res);
        ready.value = true;
      }
    }



    getAllUserMacrosData();

    return Scaffold(
      appBar: AppBar(
          title: Text('Live Dashboard'),
          centerTitle: true,
          actions: [
            TextButton(onPressed: (){
              Get.to(()=>WatchData(userId: authUser.id));
            }, child: Text('  My Data  '))
      ]),
      body: Obx(() => ready.value
          ? macrosData.length > 0 ? Column(
              children: [

                Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemCount: macrosData.length,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Get.isDarkMode ? Color(0xff101010) : colors.Colors().lightCardBG,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Get.to(() => UserView(userID: macrosData[index]['user']['id']));
                              },
                              child: Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading:CircleAvatar(
                                                    radius: 28,
                                                    backgroundImage: CachedNetworkImageProvider(
                                                      HttpClient.s3BaseUrl + macrosData[index]['user']['avatar_url'],
                                                    )
                                                ),
                                                title: Text(
                                                  macrosData[index]['user']['name'],
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                    'Weight ' +
                                                        macrosData[index]
                                                        ['fit_category'] +
                                                        ' | ' +
                                                        macrosData[index]
                                                        ['fit_program'] +
                                                        ' Fitness Program',
                                                    style: TextStyle(fontSize: 12, color: Themes.mainThemeColorAccent.shade300)),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                      const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                          color: macrosData[index][
                                                          'daily_calories'] >
                                                              macrosData[index][
                                                              'target_calories']
                                                              ? Colors.red
                                                              : Colors.green,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text('Current',style: TextStyle(
                                                              color: Colors.white)),
                                                          Text(macrosData[index]
                                                          ['daily_calories']
                                                              .toString(),style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                      const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                          color: Get.isDarkMode
                                                              ? Color(0xff292929)
                                                              : Color(0xffE4E4E4),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                            'Target',
                                                          ),
                                                          Text(macrosData[index][
                                                          'target_calories']
                                                              .toString())
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Last Updated on: ' + Utils.dateFormat(macrosData[index]['updated_at']),
                                                style: TextStyle(fontSize: 12, color: Themes.mainThemeColorAccent.shade300),
                                              )
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: 135,
                                              width: 135,
                                              child: ringsChartCalories(macrosData[index]),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    watchDataWidget(macrosData[index]['user_id']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : LoadingAndEmptyWidgets.emptyWidget() : LoadingAndEmptyWidgets.loadingWidget()),
    );
  }
}

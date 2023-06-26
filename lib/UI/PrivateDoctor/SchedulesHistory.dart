import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Members/UserView.dart';
import 'package:north_star/UI/PrivateDoctor/PrescriptionsManager/CreatePrescription.dart';
import 'package:north_star/UI/PrivateDoctor/PrescriptionsManager/ViewPrescription.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SchedulesHistory extends StatelessWidget {
  const SchedulesHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList list = [].obs;

    void getHistory() async{
      ready.value = false;
      var request = http.Request('GET', Uri.parse(HttpClient.baseURL +'/api/meeting/doctor-meetings/history/'+ authUser.id.toString()));
      request.headers.addAll(client.getHeader());

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = jsonDecode(await response.stream.bytesToString());
        print(res);
        list.value = res;
        ready.value = true;
      } else {
        print(await response.stream.bytesToString());
        ready.value = true;
      }
    }

    Map getUser(Map meeting){
      if (meeting['trainer'] == null){
        return meeting['client'];
      } else {
        return meeting['trainer'];
      }
    }

    getHistory();

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedules History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(()=> ready.value ? list.isNotEmpty ? ListView.builder(
          itemCount: list.length,
          itemBuilder: (_,index){
            return Padding(
              padding: EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: CachedNetworkImageProvider(
                                    'https://north-star-storage.s3.ap-southeast-1.amazonaws.com/avatars/' + getUser(list[index])['avatar_url'],
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(getUser(list[index])['name'],style: TypographyStyles.title(20)),
                                    SizedBox(height: 5),
                                    Text(getUser(list[index])['email'],style: TypographyStyles.text(14)),
                                  ],
                                ),
                              ],
                            ),
                            Image.asset("assets/icons/externallink.png",
                              color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1),
                              height: 20,
                            ),
                          ],
                        ),
                        onTap: (){
                          Get.to(()=> UserView(userID: list[index]['client']['id']));
                        },
                      ),
                      Divider(),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date', style: TypographyStyles.boldText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().darkGrey(0.7),)),
                              SizedBox(height: 5),
                              Text("${DateFormat("MMM dd,yyyy").format(DateTime.parse(list[index]['start_time']))}",
                                style: TypographyStyles.title(16),
                              ),
                            ],
                          ),
                          SizedBox(width: 25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time', style: TypographyStyles.boldText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().darkGrey(0.7),)),
                              SizedBox(height: 5),
                              Text("${DateFormat("hh:mm a").format(DateTime.parse(list[index]['start_time']))}",
                                style: TypographyStyles.title(16),
                              ),
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: 15),
                      Text(list[index]['title'], style: TypographyStyles.title(16)),
                      SizedBox(height: 10),
                      Text(list[index]['description'], style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().darkGrey(0.7),),),
                      SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                              child: Row(
                                children: [
                                  Text('Add Prescriptions',
                                    style: TypographyStyles.boldText(15, Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            style: ButtonStyles.matRadButton(Themes.mainThemeColor.shade500, 5, 12),
                            onPressed: (){
                              Get.to(()=>CreatePrescription(
                                userData: getUser(list[index]),
                              ));
                            },
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                              child: Row(
                                children: [
                                  Text('VIEW',
                                    style: TypographyStyles.boldText(15, Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            style: ButtonStyles.matRadButton(Themes.mainThemeColor.shade500, 5, 12),
                            onPressed: (){
                              Get.to(()=>ViewPrescription(
                                userData: getUser(list[index]),
                              ));
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ) : LoadingAndEmptyWidgets.emptyWidget() : Center(
          child: CircularProgressIndicator(),
        )),
      ),
    );
  }
}

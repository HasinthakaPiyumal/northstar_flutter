import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

Widget clientHomeTrainerRequest() {
  RxBool ready = false.obs;
  RxMap clientData = {}.obs;

  void getClientProfile() async{
    ready.value = false;
    Map res = await httpClient.getMyProfile();
    if (res['code'] == 200) {
      clientData.value = res['data'];
      ready.value = true;
    } else {
      print(res);
      ready.value = true;
    }
  }

  Future<bool> acceptTrainer(requestID, trainerID) async {
    ready.value = false;
    Map res = await httpClient.acceptTrainer(requestID,trainerID);
    print(res);
    showSnack('Trainer Accepted!', 'Trainer Has been Accepted!');
    getClientProfile();
    print('authCheck');
    AuthUser().checkAuth();
    return true;
  }

  Future<bool> rejectTrainer(requestID, trainerID) async {
    ready.value = false;
    await httpClient.rejectTrainer(requestID,trainerID);
    showSnack('Trainer Rejected!', 'Trainer Has been Rejected!');
    getClientProfile();
    return true;
  }

  getClientProfile();

  return Obx(() => ready.value && clientData['requests'] != null && clientData['requests'].length > 0  ?
    Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: clientData['requests'].length,
            itemBuilder: (_, index) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff1C1C1C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: Column(
                          children: [
                            Text("New Trainer Request",
                              style: TypographyStyles.boldText(16, Themes.mainThemeColorAccent.shade100),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: CachedNetworkImageProvider(HttpClient.s3BaseUrl + clientData['requests'][index]['trainer']['avatar_url']),
                                      radius: 25,
                                    ),
                                    SizedBox(width : 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children :[
                                          Text(clientData['requests'][index]['trainer']['name'],style: TypographyStyles.title(16),
                                            overflow: TextOverflow.fade,
                                          ),
                                          SizedBox(height: 5,),
                                          Text(clientData['requests'][index]['trainer']['email'], style: TypographyStyles.text(13),
                                            overflow: TextOverflow.fade,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ClipOval(
                                      child: InkWell(
                                        onTap: (){
                                          CommonConfirmDialog.confirm('Reject').then((value){
                                            if (value)  {
                                              rejectTrainer(clientData['requests'][index]['id'], clientData['requests'][index]['trainer_id']);
                                            }
                                          });
                                        },
                                        child: Container(
                                          color: colors.Colors().deepGrey(0.5),
                                          child: Padding(
                                            padding: EdgeInsets.all(9),
                                            child: Icon(Icons.close, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    ClipOval(
                                      child: InkWell(
                                        onTap: (){
                                          CommonConfirmDialog.confirm('Accept').then((value){
                                            if (value)  {
                                              acceptTrainer(clientData['requests'][index]['id'], clientData['requests'][index]['trainer_id']);
                                            }
                                          });
                                        },
                                        child: Container(
                                          color: Colors.green,
                                          child: Padding(
                                            padding: EdgeInsets.all(9),
                                            child: Icon(Icons.check, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5,)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Divider(),
      ])
      : SizedBox()
  );
}

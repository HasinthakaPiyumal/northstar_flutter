import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class ViewPrescription extends StatelessWidget {
  const ViewPrescription({Key? key, required this.userData}) : super(key: key);

  final Map userData;

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList prescriptions = [].obs;

    void getPrescriptions() async{
      ready.value = false;
      Map res = await httpClient.getPrescriptions(userData['id']);
      if (res['code'] == 200) {
        prescriptions.value = res['data'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    void archivePrescriptions(id) async{
      ready.value = false;
      Map res = await httpClient.archivePrescriptions(id);
      if (res['code'] == 200) {
        getPrescriptions();
      } else {
        print(res);
        ready.value = true;
      }
    }

    getPrescriptions();


    return Scaffold(
      appBar: AppBar(
        title: Text('Prescriptions'),
      ),
      body: Obx(()=> ready.value ? prescriptions.length > 0 ? ListView.builder(
        itemCount: prescriptions.length,
        itemBuilder: (_,index){
          return Container(
            padding: EdgeInsets.all(8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: CachedNetworkImageProvider(
                                HttpClient.s3BaseUrl + prescriptions[index]['doctor']['avatar_url'],
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(prescriptions[index]['doctor']['name'],style: TypographyStyles.title(20)),
                                SizedBox(height: 5),
                                Text(prescriptions[index]['doctor']['email'],style: TypographyStyles.text(14)),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: (){
                            CommonConfirmDialog.confirm('Delete').then((value){
                              if (value){
                                archivePrescriptions(prescriptions[index]['id']);
                              }
                            });
                          },
                          child: Icon(Icons.delete),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date', style: TypographyStyles.boldText(12, Themes.mainThemeColorAccent.shade100.withOpacity(0.7))),
                            SizedBox(height: 5),
                            Text("${DateFormat("MMM dd,yyyy").format(DateTime.parse(prescriptions[index]['created_at']))}",
                              style: TypographyStyles.title(16),
                            ),
                          ],
                        ),
                        SizedBox(width: 25),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time', style: TypographyStyles.boldText(12, Themes.mainThemeColorAccent.shade100.withOpacity(0.7))),
                            SizedBox(height: 5),
                            Text("${DateFormat("hh:mm a").format(DateTime.parse(prescriptions[index]['created_at']))}",
                              style: TypographyStyles.title(16),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Text("Doctor note :", style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),)),
                    SizedBox(height: 10),
                    Text(prescriptions[index]['prescription_data']['prescription_info'], style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().lightBlack(0.8),),),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Medicine'),
                          Text('Dosage')
                        ],
                      ),
                    ),

                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: prescriptions[index]['prescription_data']['medicines'].length,
                      itemBuilder: (_,index2){
                        return Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(prescriptions[index]['prescription_data']['medicines'][index2]['name']),
                                  Text(prescriptions[index]['prescription_data']['medicines'][index2]['dose'])
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ): Center(
        child: LoadingAndEmptyWidgets.emptyWidget(),
      ): Center(child: LoadingAndEmptyWidgets.loadingWidget()),
      ),
    );
  }
}

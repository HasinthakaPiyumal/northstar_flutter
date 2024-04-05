import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/DoctorProfile.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class Prescriptions extends StatelessWidget {
  const Prescriptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList prescriptions = [].obs;

    void getPrescriptions() async{
      ready.value = false;
      Map res = await httpClient.getPrescriptions(authUser.id);

      print(res);

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
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Prescriptions',style: TypographyStyles.title(20),),
      ),
      body: Obx(()=> ready.value ? prescriptions.length > 0 ? ListView.builder(
        itemCount: prescriptions.length,
        itemBuilder: (_,index){
          return Container(
            padding: EdgeInsets.all(8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    onTap: () async{
                      Map res = await httpClient.getOneUser(prescriptions[index]['doctor_id'].toString());
                      Get.to(()=>DoctorProfile(doctor: res['data']['user']));
                    },
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundImage: CachedNetworkImageProvider(
                        HttpClient.s3BaseUrl + prescriptions[index]['doctor']['avatar_url'],
                      ),
                    ),
                    title: Text(prescriptions[index]['doctor']['name']),
                    subtitle: Text(prescriptions[index]['doctor']['email']),
                    // trailing: InkWell(
                    //   onTap: (){
                    //     CommonConfirmDialog.confirm('Delete').then((value){
                    //       if (value){
                    //         archivePrescriptions(prescriptions[index]['id']);
                    //       }
                    //     });
                    //   },
                    //   child: Icon(Icons.delete,
                    //     color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                    //   ),
                    // ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(prescriptions[index]['created_at'].split('T')[0].toString()),
                    subtitle: Text(prescriptions[index]['created_at'].split('T')[1].toString().split('.')[0].toString()),
                    trailing: InkWell(
                      onTap: () async {
                        Map res = await httpClient.getOneUser(prescriptions[index]['doctor_id'].toString());
                        print(res['data']['user']['doctor']);
                        Get.defaultDialog(
                          radius: 8,
                          title: '',
                          backgroundColor: Color(0xFFFFFFFF),
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Signature', style: TextStyle(color: Colors.black),),
                                  SizedBox(height: 8),
                                  Container(
                                    height: 128,
                                    width: Get.width,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fitHeight,
                                        imageUrl: HttpClient.s3DocSignatureBaseUrl + res['data']['user']['doctor']['signature'],
                                      ),
                                    ),
                                  ),
                                ],),
                              SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Seal', style: TextStyle(color: Colors.black),),
                                  SizedBox(height: 8),
                                  Container(
                                    height: 128,
                                    width: Get.width,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fitHeight,
                                        imageUrl: HttpClient.s3DocSealBaseUrl + res['data']['user']['doctor']['seal'],
                                      ),
                                    ),
                                  )
                                ],),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: Text('OK', style: TextStyle(color: Colors.black),),
                              onPressed: (){
                                Get.back();
                              },
                            ),
                          ],
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: Text("Prescribed By",
                            style: TypographyStyles.boldText(12, Colors.white,),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Note'),
                    subtitle: Text(prescriptions[index]['prescription_data']['prescription_info']),
                  ),
                  ListTile(
                    title: Text('Medicine'),
                    trailing: Text('Dosage')
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: prescriptions[index]['prescription_data']['medicines'].length,
                    itemBuilder: (_,index2){
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              index2 != 0 ? Divider(
                                color: Get.isDarkMode ? colors.Colors().lightWhite(0.3) : colors.Colors().darkGrey(1),
                              ) : SizedBox(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(prescriptions[index]['prescription_data']['medicines'][index2]['name'],
                                    style: TextStyle(
                                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                  Text(prescriptions[index]['prescription_data']['medicines'][index2]['dose'],
                                    style: TextStyle(
                                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20,)
                ],
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

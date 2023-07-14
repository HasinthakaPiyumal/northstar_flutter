import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/PrivateDoctor/DocProfileSettings.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorAccountInfo.dart';
import 'package:north_star/UI/PrivateDoctor/DoctorSettings.dart';
import 'package:north_star/UI/SharedWidgets/QualificationsAddEdit.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../main.dart';
import '../SharedWidgets/UploadAvatar.dart';

class DoctorPrivateProfile extends StatelessWidget {
  const DoctorPrivateProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxMap doctor = {}.obs;
    RxBool ready = false.obs;
    RxBool isDarkMode = Get.isDarkMode.obs;

    final themeProvider = Provider.of<ThemeProvider>(context);

    void getProfile() async{
      ready.value = false;
      Map res = await httpClient.getMyProfile();

      if (res['code'] == 200) {
        doctor.value = res['data'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    void deleteQualification(id) async {
      ready.value = false;
      Map res = await httpClient.deleteQualification(id);
      if (res['code'] == 200) {
        getProfile();
      } else {
        print(res);
        ready.value = true;
      }
    }

    getProfile();

    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(()=> ready.value ?  Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: CachedNetworkImageProvider(
                                'https://north-star-storage.s3.ap-southeast-1.amazonaws.com/avatars/' + doctor['avatar_url'],
                              ),
                            ),
                            SizedBox(width: 15,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doctor['name'], style: TypographyStyles.title(24)),
                                Text(
                                    doctor['doctor']['speciality'].toString().replaceRange(0, 1, doctor['doctor']['speciality'].toString().substring(0, 1).toUpperCase())
                                ),
                              ],
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(()=>UploadAvatar())?.then((value){
                              getProfile();
                            });
                          },
                          child: Icon(Icons.edit, color: Themes.mainThemeColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Qualifications', style: TypographyStyles.title(18)),
                        TextButton(onPressed: (){
                          Get.to(QualificationsAddEdit())?.then((value) {
                            getProfile();
                          });
                        },
                            child: Text('Add'))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      height: doctor.value['qualifications'].length > 0 ? 100: 8,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: doctor.value['qualifications'].length,
                        itemBuilder: (_,index){
                          return InkWell(
                            onLongPress: (){
                              Get.defaultDialog(
                                radius: 8,
                                title: 'Delete/Edit',
                                content: Text('Are you sure you want to delete/edit this qualification?',
                                    textAlign: TextAlign.center
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: (){
                                      Get.back();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Delete'),
                                    onPressed: (){
                                      Get.back();
                                      deleteQualification(doctor.value['qualifications'][index]['id']);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Edit'),
                                    onPressed: (){
                                      Get.back();
                                      Get.to(()=>QualificationsAddEdit(qData: doctor.value['qualifications'][index]))?.then((value) {
                                        getProfile();
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: Get.width*0.75,
                              margin: index == 0 ? EdgeInsets.only(left: 16) : EdgeInsets.zero,
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(children: [
                                        Container(
                                          width:18,
                                          child: Image.asset("assets/images/award.png",
                                            color: isDarkMode.value == true ? colors.Colors().deepYellow(1) : Colors.black,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Text(doctor.value['qualifications'][index]['title'].toString(),style: TypographyStyles.title(16))
                                      ],),
                                      SizedBox(height: 8.0),
                                      Text(doctor.value['qualifications'][index]['description'], textAlign: TextAlign.left, style: TextStyle(color: Colors.grey[500], fontSize: 14),)
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
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dark Mode'),
                        CupertinoSwitch(
                          value: isDarkMode.value,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                            isDarkMode.value = value;
                          },
                          // onChanged: (value){
                          //   SharedPreferences.getInstance().then((prefs){
                          //     prefs.setBool('darkMode', value);
                          //   });
                          //   print(value);
                          //   isDarkMode.value = value;
                          //   //Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
                          //   showSnack('Theme Changed!', 'Please Reopen the App');
                          // },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ButtonStyles.matRadButton( Get.isDarkMode ? Colors.black : colors.Colors().selectedCardBG, 0, 12),
                      onPressed: (){
                        Get.to(()=>DoctorAccountInfo());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 22, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Account Information",
                              style: TypographyStyles.text(15),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 15,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ButtonStyles.matRadButton(Get.isDarkMode ? Colors.black : colors.Colors().selectedCardBG, 0, 12),
                      onPressed: (){
                        Get.to(()=>DoctorSettings());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 22, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Schedule Settings",
                              style: TypographyStyles.text(15),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 15,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ButtonStyles.matRadButton(Get.isDarkMode ? Colors.black : colors.Colors().selectedCardBG, 0, 12),
                      onPressed: (){
                        Get.to(()=>DocProfileSettings());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 22, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Profile Settings",
                              style: TypographyStyles.text(15),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 15,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ) : Center(child: CircularProgressIndicator(),)),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: MaterialButton(
                      onPressed: (){
                        showSignOutDialog();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.red
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red,),
                          SizedBox(width: 20,),
                          Text('LOGOUT', style: TextStyle(color: Colors.red),),
                        ],
                      )),
                ),
              ),
              SizedBox(height: 20),
              Text(HttpClient.buildInfo),
              SizedBox(height: 20),
            ],
          )
      )
    );
  }
}

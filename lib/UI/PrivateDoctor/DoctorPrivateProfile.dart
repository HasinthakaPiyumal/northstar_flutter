import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
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


import '../../Styles/AppColors.dart';
import '../../components/Buttons.dart';
import '../../components/CheckButton.dart';
import '../../main.dart';
import '../HelpAndSupport/HelpAndSupportHome.dart';
import '../SharedWidgets/UploadAvatar.dart';

class DoctorPrivateProfile extends StatefulWidget {
  const DoctorPrivateProfile({Key? key}) : super(key: key);

  @override
  State<DoctorPrivateProfile> createState() => _DoctorPrivateProfileState();
}

class _DoctorPrivateProfileState extends State<DoctorPrivateProfile> {
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
                    child: Column(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 124,
                            height: 124,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 124,
                                    height: 124,
                                    decoration: ShapeDecoration(
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            HttpClient.s3BaseUrl +
                                                doctor.value['avatar_url']),
                                        fit: BoxFit.cover,
                                      ),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 76.69,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => UploadAvatar())?.then((value) {
                                        getProfile();
                                      });
                                    },
                                    child: Container(
                                      width: 124,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Color(0x88000000),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 36.75,
                                            top: 0,
                                            child: Container(
                                              width: 46,
                                              height: 46.50,
                                              // clipBehavior: Clip.antiAlias,
                                              child: Icon(
                                                Icons.camera_alt_rounded,
                                                color: Themes
                                                    .mainThemeColor.shade500,
                                              ),
                                              // decoration: BoxDecoration(
                                              // ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10,),
                            Text(doctor['name'].toString().capitalize.toString(), style: TypographyStyles.title(20)),
                            SizedBox(height: 6,),
                            Text(
                                doctor['doctor']['speciality'].toString().replaceRange(0, 1, doctor['doctor']['speciality'].toString().substring(0, 1).toUpperCase()),
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8,)
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      themeProvider.toggleTheme();
                      // isDarkMode.value = value;
                    },
                    child: Container(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Container(
                        width: 96,
                        height: 44,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 96,
                                height: 44,
                                decoration: ShapeDecoration(
                                  color: Color(0xFF1E2630),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: Get.isDarkMode ? 56 : 4,
                              top: 4,
                              child: Container(
                                width: 36,
                                height: 36,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: ShapeDecoration(
                                          color: Color(0xFFFFB700),
                                          shape: OvalBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 4,
                              top: 4,
                              child: Container(
                                width: 36,
                                height: 36,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        child: Icon(
                                            Icons.light_mode_rounded,
                                            color: Get.isDarkMode
                                                ? Color(0xFFFFFFFF)
                                                : Color(0xFF1B1F24)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 56,
                              top: 4,
                              child: Container(
                                width: 36,
                                height: 36,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        child: Icon(Icons.dark_mode,
                                            color: !Get.isDarkMode
                                                ? Color(0xFFFFFFFF)
                                                : Color(0xFF1B1F24)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   child: Divider(thickness: 1),
                  // ),
                  SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ButtonStyles.matRadButton( Get.isDarkMode ?AppColors.primary2Color : colors.Colors().selectedCardBG, 0, 10,showBorder: true),
                      onPressed: (){
                        Get.to(()=>DoctorAccountInfo());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10,),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/notebook-pencil.png",
                                  width: 36,
                                  height: 36,
                                ),
                                SizedBox(width: 10,),
                                Text("Account Information",
                                  style: TypographyStyles.text(15),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, size: 15,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   child: ElevatedButton(
                  //     style: ButtonStyles.matRadButton(Get.isDarkMode ? AppColors.primary2Color : colors.Colors().selectedCardBG, 0, 10,showBorder: true),
                  //     onPressed: (){
                  //       Get.to(()=>DoctorSettings());
                  //     },
                  //     child: Padding(
                  //       padding: EdgeInsets.symmetric(vertical: 10),
                  //       child: Row(
                  //         children: [
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Image.asset(
                  //                 "assets/icons/setting-pink.png",
                  //                 width: 36,
                  //                 height: 36,
                  //               ),
                  //               SizedBox(width: 10,),
                  //               Text("Schedule Settings",
                  //                 style: TypographyStyles.text(15),
                  //               ),
                  //             ],
                  //           ),
                  //               Icon(Icons.arrow_forward_ios, size: 15,)
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ButtonStyles.matRadButton(Get.isDarkMode ? AppColors.primary2Color : colors.Colors().selectedCardBG, 0, 10,showBorder: true),
                      onPressed: (){
                        Get.to(()=>DocProfileSettings());
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical:10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/calender.png",
                                  width: 36,
                                  height: 36,
                                ),
                                SizedBox(width: 10,),
                                Text("Profile Settings",
                                  style: TypographyStyles.text(15),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, size: 15,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Qualifications',
                            style: TypographyStyles.title(20)),
                        TextButton(
                            onPressed: () {
                              Get.to(QualificationsAddEdit())
                                  ?.then((value) {
                                getProfile();
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              clipBehavior: Clip.antiAlias,
                              padding: EdgeInsets.all(5.0),
                              decoration: ShapeDecoration(
                                color: Color(0xFFFFB700),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child:
                              Icon(Icons.add, color: Color(0xFF1B1F24)),
                            ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      height: doctor.value['qualifications'].length > 0 ? 164 : 8,
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
                                width: Get.width * 0.75,
                                margin: index == 0
                                    ? EdgeInsets.only(left: 8)
                                    : EdgeInsets.only(left: 14, right: 8),
                                child: Card(
                                  color: Get.isDarkMode
                                      ? AppColors.primary2Color
                                      : Color(0xFFffffff),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 36,
                                          child: Image.asset(
                                            "assets/images/award_v2.png",
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        SizedBox(width: 18),
                                        Text(
                                            doctor.value['qualifications']
                                            [index]['title']
                                                .toString(),
                                            style:
                                            TypographyStyles.title(16)),
                                        SizedBox(height: 10.0),
                                        Text(
                                          doctor.value['qualifications'][index]
                                          ['description'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Get.isDarkMode
                                                  ? Colors.white
                                                  : Color(0xFF1B1F24),
                                              fontFamily: 'Poppins',
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            // child: Container(
                            //   width: Get.width*0.75,
                            //   margin: index == 0 ? EdgeInsets.only(left: 16) : EdgeInsets.zero,
                            //   child: Card(
                            //     child: Padding(
                            //       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                            //       child: Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           Row(children: [
                            //             Container(
                            //               width:18,
                            //               child: Image.asset("assets/images/award.png",
                            //                 color: isDarkMode.value == true ? colors.Colors().deepYellow(1) : Colors.black,
                            //                 fit: BoxFit.fitWidth,
                            //               ),
                            //             ),
                            //             SizedBox(width: 15),
                            //             Text(doctor.value['qualifications'][index]['title'].toString(),style: TypographyStyles.title(16))
                            //           ],),
                            //           SizedBox(height: 8.0),
                            //           Text(doctor.value['qualifications'][index]['description'], textAlign: TextAlign.left, style: TextStyle(color: Colors.grey[500], fontSize: 14),)
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ) : Center(child: CircularProgressIndicator(),)),
              SizedBox(height: 20,),
              Buttons.outlineTextIconButton(
                  onPressed: () {
                    Get.to(() => HelpAndSupportHome());
                  },
                  label: "Help And Support",
                  width: Get.width - 32,
                  icon: Icons.help),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Buttons.outlineTextIconButton(
                      onPressed: () {
                        showSignOutDialog();
                      },
                      label: "logout",
                      icon: Icons.logout),
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

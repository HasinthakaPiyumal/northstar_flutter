import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/ContactUsPage.dart';
import 'package:north_star/Controllers/WatchDataController.dart';
import 'package:north_star/UI/SharedWidgets/CommonProfileUpdate.dart';
import 'package:north_star/UI/SharedWidgets/QualificationsAddEdit.dart';
import 'package:north_star/UI/SharedWidgets/ReviewWidget.dart';
import 'package:north_star/UI/SharedWidgets/UploadAvatar.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './';


class TrainerProfile extends StatelessWidget {
  const TrainerProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxBool isDarkMode = Get.isDarkMode.obs;

    final themeProvider = Provider.of<ThemeProvider>(context);

    TextEditingController aboutController = TextEditingController();

    RxMap data = {}.obs;
    RxMap reviews = {}.obs;

    void getProfile() async{
      ready.value = false;
      Map res = await httpClient.getMyProfile();

      if (res['code'] == 200) {
        data.value = res['data'];
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

    void updateAbout() async{
      ready.value = false;
      Map res = await httpClient.updateAbout({
        'about': aboutController.text
      });

      if (res['code'] == 200) {
        ready.value = true;
        Get.back();
        getProfile();
      } else {
        print(res);
        Get.back();
        ready.value = true;
      }
    }

    void getReviews() async{
      ready.value = false;
      Map res = await httpClient.getReviews(authUser.id);
      if (res['code'] == 200) {
        print(res['data']);
        reviews.value = res['data'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getProfile();

    getReviews();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [

            Obx(()=> (ready.value && data.value.isNotEmpty && reviews.value.isNotEmpty ) ? Container(
              width: 188,
              height: 228,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
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
                                image: CachedNetworkImageProvider("https://via.placeholder.com/124x124"),
                                fit: BoxFit.fill,
                              ),
                              shape: OvalBorder(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 2,
                          top: 71.69,
                          child: Container(
                            width: 119.50,
                            height: 52.31,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 36.75,
                                  top: 0,
                                  child: Container(
                                    width: 46.50,
                                    height: 46.50,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ruchira lakmal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: ShapeDecoration(
                            color: Color(0xFFFFB700),
                            shape: StarBorder(
                              points: 5,
                              innerRadiusRatio: 0.38,
                              pointRounding: 0,
                              valleyRounding: 0,
                              rotation: 0,
                              squash: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '4.8 ( 6 reviews )',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ):Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFFFFB800),),
              ),
            )),
            Obx(()=> (ready.value && data.value.isNotEmpty && reviews.value.isNotEmpty ) ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage : CachedNetworkImageProvider(HttpClient.s3BaseUrl + data.value['avatar_url']),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.value['name'], style: TypographyStyles.title(24)),
                            SizedBox(height: 7),
                            Row(
                              children: [
                                Text("${data.value['trainer']['rating'].toStringAsFixed(1)}"),
                                SizedBox(width: 5),
                                RatingBarIndicator(
                                  rating: double.parse(data.value['trainer']['rating'].toString()),
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: colors.Colors().deepYellow(1),
                                  ),
                                  itemCount: 5,
                                  itemSize: 15.0,
                                  direction: Axis.horizontal,
                                  unratedColor: colors.Colors().darkGrey(1),
                                ),
                                SizedBox(width: 15,),
                                Text("${data.value['trainer']['rating_count']} reviews",
                                  style: TypographyStyles.boldText(14, Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                          Get.to(()=>UploadAvatar())?.then((value){
                            getProfile();
                          });
                        },
                        icon: Icon(Icons.edit, color: Themes.mainThemeColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Divider(thickness: 1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Qualifications', style: TypographyStyles.title(20)),
                          TextButton(onPressed: (){
                            Get.to(QualificationsAddEdit())?.then((value) {
                              getProfile();
                            });
                          }, child: Text('Add'))
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: data.value['qualifications'].length > 0 ? 100: 8,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.value['qualifications'].length,
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
                                      deleteQualification(data.value['qualifications'][index]['id']);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Edit'),
                                    onPressed: (){
                                      Get.back();
                                      Get.to(()=>QualificationsAddEdit(qData: data.value['qualifications'][index]))?.then((value) {
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
                                        Text(data.value['qualifications'][index]['title'].toString(),style: TypographyStyles.title(16))
                                      ],),
                                      SizedBox(height: 8.0),
                                      Text(data.value['qualifications'][index]['description'], textAlign: TextAlign.left, style: TextStyle(color: Colors.grey[500], fontSize: 14),)
                                    ],
                                  ),
                                ),
                              )
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text('About', style: TypographyStyles.title(20)),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.edit, color: Themes.mainThemeColor,),
                            onPressed: (){
                              aboutController.text = data.value['trainer']['about'];
                              Get.defaultDialog(
                                  radius: 8,
                                  title: 'Edit About',
                                  content: TextField(
                                    controller: aboutController,
                                    decoration: InputDecoration(
                                      hintText: 'About',
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        style: SignUpStyles.notSelectedButton(),
                                        onPressed: (){
                                          Get.back();
                                        }, child: Text('Cancel')),
                                    ElevatedButton(
                                        style: SignUpStyles.selectedButton(),
                                        onPressed: (){
                                          if(aboutController.text.isEmpty){
                                            showSnack('About field is Empty', 'Please fill the about field');
                                          } else {
                                            updateAbout();
                                          }
                                        }, child: Text('  Save  ')),
                                  ]
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(data['trainer']['about'], style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                          Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text('Profile', style: TypographyStyles.title(20)),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.edit, color: Themes.mainThemeColor,),
                            onPressed: (){
                              Get.to(CommonProfileUpdate(userObj: data.value))?.then((value){
                                getProfile();
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone', style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                              SizedBox(height: 24),
                              Text('Birth Day', style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                              SizedBox(height: 24),
                              Text('Email', style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                              SizedBox(height: 24),
                              Text('Gender', style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                              SizedBox(height: 24),
                              Text('NIC/Passport', style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                              SizedBox(height: 24),
                              Text('Shipping Address', style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                              SizedBox(height: 24),
                              Text('Country', style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                              SizedBox(height: 24),
                              Text('Has Insurance', style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1))),
                              SizedBox(height: 24),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(data.value['phone'], style: TypographyStyles.title(16)),
                              SizedBox(height: 24),
                              Text(data.value['birthday'], style: TypographyStyles.title(16)),
                              SizedBox(height: 24),
                              Text(data.value['email'], style: TypographyStyles.title(16)),
                              SizedBox(height: 24),
                              Text(data.value['gender'].toString().toUpperCase(), style: TypographyStyles.title(16)),
                              SizedBox(height: 24),
                              Text(data.value['nic'], style: TypographyStyles.title(16)),
                              SizedBox(height: 24),
                              Text(data.value['address'], style: TypographyStyles.title(16)),
                              SizedBox(height: 24),
                              Text(data.value['country_code'], style: TypographyStyles.title(16)),
                              SizedBox(height: 24),
                              Text( data.value['trainer']['is_insured'] ? 'Yes':'No', style:TypographyStyles.title(16)),
                              SizedBox(height: 24),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Health Data Sync'),
                          CupertinoSwitch(
                            value: authUser.user['health_data'],
                            onChanged: (bool value) async {
                              ready.value = false;
                              if(value){
                                bool hasPermissions = await WatchDataController.requestPermission();
                                if(!hasPermissions){
                                  showSnack('Permission Denied', 'Please allow permission to sync health data');
                                  ready.value = true;
                                } else {
                                  await httpClient.toggleHealthDataConsent();
                                  await authUser.checkAuth();
                                  showSnack('Permission Granted', 'Health data will be synced');
                                  ready.value = true;
                                }
                              } else {
                                await httpClient.toggleHealthDataConsent();
                                await authUser.checkAuth();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: reviewWidget(reviews, data),
                    ),
                    SizedBox(height: 16),

                  ],
                ),
              ],
            ): Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )),
            Divider(thickness: 1),
            SizedBox(height: 20,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: MaterialButton(
                    onPressed: (){
                      Get.to(()=>ContactUsPage());
                    },
                    color: colors.Colors().deepGrey(1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Contact North Star', style: TextStyle(color: Colors.white),),),
              ),
            ),

            SizedBox(height: 10,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
        ),
      ),
    );
  }
}



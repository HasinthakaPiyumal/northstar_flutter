import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/PrivateDoctor/Uploads/UploadSeal.dart';
import 'package:north_star/UI/PrivateDoctor/Uploads/UploadSignature.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../components/Buttons.dart';
import '../../components/Radios.dart';

class DocProfileSettings extends StatelessWidget {
  const DocProfileSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxMap doctor = {}.obs;
    RxBool ready = false.obs;
    TextEditingController _hourlyController = TextEditingController();

    RxString chargeType = 'SESSION'.obs;
    RxBool canPrescribe = false.obs;
    RxString title = 'Dr'.obs;


    void getProfile() async{
      ready.value = false;
      Map res = await httpClient.getMyProfile();
      if (res['code'] == 200) {
        doctor.value = res['data'];
        ready.value = true;
        _hourlyController.text = doctor['doctor']['hourly_rate'].toString();
        chargeType.value = doctor['doctor']['charge_type'];
        canPrescribe.value = doctor['doctor']['can_prescribe'];
        title.value = doctor['doctor']['title'];
      } else {
        print(res);
        ready.value = true;
      }
    }

    getProfile();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
        
      ),
      body: Obx(()=> ready.value ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Signature & Seal',style: TypographyStyles.text(16)),
              SizedBox(height: 8),

              Stack(
                children: [
                  Row(
                    children: [
                      Opacity(
                        opacity: 0.4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            child: Obx(()=> doctor['doctor']['signature'] != null ?
                            CachedNetworkImage(
                              imageUrl: HttpClient.s3DocSignatureBaseUrl + doctor['doctor']['signature'],
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.fitHeight,
                              height: 106,
                              width: (Get.width/2)-20,
                            ):SizedBox()),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            child: Obx(()=> doctor['doctor']['seal'] != null ?
                            CachedNetworkImage(
                              imageUrl: HttpClient.s3DocSignatureBaseUrl + doctor['doctor']['seal'],
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.fitHeight,
                              height: 106,
                              width: (Get.width/2)-20,
                            ):SizedBox()),
                          ),
                        ),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors().getPrimaryColor(reverse: true)),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.accentColor,
                                          borderRadius: BorderRadius.circular(100)
                                      ),
                                      padding: EdgeInsets.all(6),
                                      child: SvgPicture.asset("assets/svgs/upload.svg",width: 32,height: 32,)),
                                  onPressed: () {
                                    Get.to(()=>UploadSignature())?.then((value){
                                      getProfile();
                                    });
                                  },
                                ),
                                Text('Upload Signature'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors().getPrimaryColor(reverse: true)),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.accentColor,
                                          borderRadius: BorderRadius.circular(100)
                                      ),
                                      padding: EdgeInsets.all(6),
                                      child: SvgPicture.asset("assets/svgs/upload.svg",width: 32,height: 32,)),
                                  onPressed: () {
                                    Get.to(()=>UploadSeal())?.then((value){
                                      getProfile();
                                    });
                                  },
                                ),
                                Text('Upload Doctor Seal'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

              ),

              SizedBox(height: 8),

              SizedBox(height: 20),
              TextField(
                controller: _hourlyController,
                onChanged: (value) {
                  if(value.isNotEmpty){
                    doctor['doctor']['hourly_rate'] = double.parse(value.toString());
                    print(doctor['doctor']['hourly_rate']);
                  } else {
                    showSnack('Invalid Hourly Charge', 'Please enter a valid hourly charge');
                  }
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Hourly Rate (' + doctor['currency'] + ')',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text('Charging Method', style: TypographyStyles.title(20)),
              SizedBox(height: 20),
              Obx(()=> Row(
                  children: [
                    InkWell(
                      onTap:  (){
                        chargeType.value = 'SESSION';},
                      splashColor: Colors.transparent,
                      child: Container(
                        height: 50,
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            chargeType.value == 'SESSION'?Radios.radioChecked2():Radios.radio(),
                            SizedBox(width: 10,),
                            Text("Per Session",style: TypographyStyles.text(14),)
                          ],),
                      ),
                    ),
                    InkWell(
                      onTap:  (){chargeType.value = 'TIME';},
                      splashColor: Colors.transparent,
                      child: Container(
                        height: 50,
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            chargeType.value == 'TIME'?Radios.radioChecked2():Radios.radio(),
                            SizedBox(width: 10,),
                            Text("Per Hour",style: TypographyStyles.text(14),)
                          ],),
                      ),
                    ),
                    // Expanded(
                    //   child: Container(
                    //       height: 50,
                    //       child: ElevatedButton(
                    //         style: chargeType.value == 'SESSION' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                    //         onPressed:(){
                    //           chargeType.value = 'SESSION';
                    //         },
                    //         child: Text('Per Session',
                    //           style: TextStyle(
                    //             color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                    //           ),
                    //         ),
                    //       )
                    //   ),
                    // ),
                    SizedBox(width: 16),
                    // Expanded(
                    //   child: Container(
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       style: chargeType.value == 'TIME' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                    //       onPressed:(){
                    //         chargeType.value = 'TIME';
                    //       },
                    //       child: Text('Per Hour',
                    //         style: TextStyle(
                    //           color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text('Are You Authorized to Prescribe?', style: TypographyStyles.title(20)),
              SizedBox(height: 20),
              Obx(()=> Row(
                children: [
                  InkWell(
                    onTap:  (){
                      canPrescribe.value = true;},
                    splashColor: Colors.transparent,
                    child: Container(
                      height: 50,
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          canPrescribe.value?Radios.radioChecked2():Radios.radio(),
                          SizedBox(width: 10,),
                          Text("Yes",style: TypographyStyles.text(14),)
                        ],),
                    ),
                  ),
                  InkWell(
                    onTap:  (){canPrescribe.value = true;},
                    splashColor: Colors.transparent,
                    child: Container(
                      height: 50,
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          !canPrescribe.value?Radios.radioChecked2():Radios.radio(),
                          SizedBox(width: 10,),
                          Text("No",style: TypographyStyles.text(14),)
                        ],),
                    ),
                  ),
                  // Expanded(
                  //   child: Container(
                  //       height: 50,
                  //       child: ElevatedButton(
                  //         style: chargeType.value == 'SESSION' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                  //         onPressed:(){
                  //           chargeType.value = 'SESSION';
                  //         },
                  //         child: Text('Per Session',
                  //           style: TextStyle(
                  //             color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                  //           ),
                  //         ),
                  //       )
                  //   ),
                  // ),
                  SizedBox(width: 16),
                  // Expanded(
                  //   child: Container(
                  //     height: 50,
                  //     child: ElevatedButton(
                  //       style: chargeType.value == 'TIME' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                  //       onPressed:(){
                  //         chargeType.value = 'TIME';
                  //       },
                  //       child: Text('Per Hour',
                  //         style: TextStyle(
                  //           color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              ),
              // Obx(()=>Row(
              //   children: [
              //     Expanded(
              //       child: Container(
              //         height: 50,
              //         child: ElevatedButton(
              //           style: canPrescribe.value ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
              //           onPressed:(){
              //             canPrescribe.value = true;
              //           },
              //           child: Text('Yes',
              //             style: TextStyle(
              //               color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 16),
              //     Expanded(
              //       child: Container(
              //         height: 50,
              //         child: ElevatedButton(
              //           style: !canPrescribe.value ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
              //           onPressed:(){
              //             canPrescribe.value = false;
              //           },
              //           child: Text('No',
              //             style: TextStyle(
              //               color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // )),
              SizedBox(height: 20),
              Text('Title', style: TypographyStyles.title(20)),
              SizedBox(height: 10,),
              Obx(()=>Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ElevatedButton(
                        style: title.value == 'Dr' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          title.value = 'Dr';
                        },
                        child: Text('Dr',
                          style: TextStyle(
                            color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ElevatedButton(
                        style: title.value == 'Mr' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          title.value = 'Mr';
                        },
                        child: Text('Mr',
                          style: TextStyle(
                            color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                          ),),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ElevatedButton(
                        style: title.value == 'Ms' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          title.value = 'Ms';
                        },
                        child: Text('Ms',
                          style: TextStyle(
                            color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                          ),),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ElevatedButton(
                        style: title.value == 'Mrs' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          title.value = 'Mrs';
                        },
                        child: Text('Mrs',
                          style: TextStyle(
                            color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                          ),),
                      ),
                    ),
                  ),
                ],
              ),),
              SizedBox(height: 20),
            ],
          ),
        ),
      ): LoadingAndEmptyWidgets.loadingWidget()),
      bottomNavigationBar: Padding(padding: EdgeInsets.all(16),child: Buttons.yellowFlatButton(onPressed: () async {
        ready.value = false;
        doctor['doctor'].remove('created_at');
        doctor['doctor'].remove('updated_at');
        print(doctor['doctor']);
        Map res = await httpClient.updateDoctor({
          'user_id': doctor['doctor']['user_id'],
          'hourly_rate': _hourlyController.text,
          'title': title.value,
          'charge_type': chargeType.value,
          'can_prescribe': canPrescribe.value,
        });
        print(res);
        if (res['code'] == 200) {
          Get.back();
          showSnack('Success', 'Profile updated successfully');
        } else {
          showSnack('Error', res['message']);
        }
      },label: "Update"),),
    );
  }
}

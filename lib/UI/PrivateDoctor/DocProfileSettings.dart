import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/PrivateDoctor/Uploads/UploadSeal.dart';
import 'package:north_star/UI/PrivateDoctor/Uploads/UploadSignature.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

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
        actions: [
          TextButton(
            child: Text('Save'),
            onPressed: () async {
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
            },
          ),
        ],
      ),
      body: Obx(()=> ready.value ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Signature & Seal',style: TypographyStyles.title(18)),
              SizedBox(height: 8),
              Container(
                child: Obx(()=> doctor['doctor']['signature'] != null ? CachedNetworkImage(
                  imageUrl: HttpClient.s3DocSignatureBaseUrl + doctor['doctor']['signature'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.fitHeight,
                  height: 128,
                  width: Get.width,
                ):SizedBox()),
              ),
              Row(
                children: [
                  Text('Upload Signature'),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.file_upload),
                    onPressed: () {
                      Get.to(()=>UploadSignature())?.then((value){
                        getProfile();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                child: Obx(()=> doctor['doctor']['seal'] != null ? CachedNetworkImage(
                  imageUrl: HttpClient.s3DocSealBaseUrl + doctor['doctor']['seal'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.fitHeight,
                  height: 128,
                  width: Get.width,
                ):SizedBox()),
              ),
              Row(
                children: [
                  Text('Upload Doctor Seal'),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.file_upload),
                    onPressed: () {
                      Get.to(()=>UploadSeal())?.then((value){
                        getProfile();
                      });
                    },
                  ),
                ],
              ),

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
              Obx(()=>Row(
                children: [
                  Expanded(
                    child: Container(
                        height: 50,
                        child: ElevatedButton(
                          style: chargeType.value == 'SESSION' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                          onPressed:(){
                            chargeType.value = 'SESSION';
                          },
                          child: Text('Per Session',
                            style: TextStyle(
                              color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                            ),
                          ),
                        )
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        style: chargeType.value == 'TIME' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          chargeType.value = 'TIME';
                        },
                        child: Text('Per Hour',
                          style: TextStyle(
                            color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
              SizedBox(height: 20),
              Text('Are You Authorized to Prescribe?', style: TypographyStyles.title(20)),
              SizedBox(height: 20),
              Obx(()=>Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        style: canPrescribe.value ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          canPrescribe.value = true;
                        },
                        child: Text('Yes',
                          style: TextStyle(
                            color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        style: !canPrescribe.value ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          canPrescribe.value = false;
                        },
                        child: Text('No',
                          style: TextStyle(
                            color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
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
    );
  }
}

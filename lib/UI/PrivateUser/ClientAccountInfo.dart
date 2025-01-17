import 'package:country_currency_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonProfileUpdate.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../Styles/AppColors.dart';
import '../../components/Buttons.dart';

class ClientAccountInfo extends StatelessWidget {

  const ClientAccountInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    RxBool ready = false.obs;
    var data = {};

    void getProfile() async{
      ready.value = false;
      Map res = await httpClient.getMyProfile();
      if (res['code'] == 200) {
        data = res['data'];
        print(data);
        nameController.text = data['emergency_contact_name'];
        phoneController.text = data['emergency_contact_phone'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }



    getProfile();

    return Scaffold(
      appBar: AppBar(
        title: Text("Account Information"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(()=>ready.value ? Column(
                children: [

                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors().getSecondaryColor(),borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        SizedBox(height: 16,),
                        Row(mainAxisAlignment: MainAxisAlignment.center,children: [SvgPicture.asset("assets/svgs/profile-outline.svg",width: 24,height: 24,),SizedBox(width: 8,),Text("About",style: TypographyStyles.text(16),)],),
                        SizedBox(height: 32,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('User ID', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Phone', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Birthday', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Email', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Gender', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('NIC/Passport', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Country', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Registered Date', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(authUser.id.toString(), style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(data['user']['phone'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(data['user']['birthday'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(data['user']['email'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text("${data['user']['gender'].toString().capitalizeFirst}", style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(data['user']['nic'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(CountryPickerUtils.getCountryByIsoCode(data['user']['country_code']).name! , style: TypographyStyles.text(14)),
                                // Text(CountryPickerUtils.getCountryByIsoCode("ad").name! , style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text( DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(data['user']['created_at']),
                                ) , style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                              ],
                            ),
                          ],
                        ),
                        Buttons.yellowFlatButton(onPressed: (){
                          Get.to(()=>CommonProfileUpdate(userObj: data['user'],))?.then((value){
                          getProfile();
                        });},label: "Edit your information")
                      ],
                    ),
                  ),
                  // SizedBox(height: 16),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('EMERGENCY CONTACT', style: TypographyStyles.title(18)),
                  //     IconButton(
                  //       icon: Icon(Icons.edit, color: Themes.mainThemeColor,),
                  //       onPressed: (){
                  //       },
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors().getSecondaryColor(),borderRadius: BorderRadius.circular(10)),
                    child:Column(
                      children: [
                        SizedBox(height: 16,),
                        Row(mainAxisAlignment: MainAxisAlignment.center,children: [SvgPicture.asset("assets/svgs/contact-emergency-outline.svg",width: 24,height: 24,),SizedBox(width: 8,),Text("Emergency Contact",style: TypographyStyles.text(16),)],),
                        SizedBox(height: 32,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data['emergency_contact_name'], style: TypographyStyles.title(16)),
                            Text(data['emergency_contact_phone'], style: TypographyStyles.title(16)),
                          ],
                        ),
                        SizedBox(height: 26,),
                        Buttons.yellowFlatButton(onPressed: (){
                          Get.defaultDialog(
                              radius: 8,
                              title: 'Emergency Contact',
                              titlePadding: EdgeInsets.only(top: 20, bottom: 20),
                              contentPadding: EdgeInsets.zero,
                              content: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(),
                                    TextField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Name',
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    IntlPhoneField(
                                      showCountryFlag: true,
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(),
                                        ),
                                      ),
                                      initialCountryCode: 'MV',
                                      onChanged: (phone) {
                                        phoneController.text = "${phone.completeNumber}";
                                      },
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              actions: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text('Cancel',
                                          style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade100),
                                        ),
                                        onPressed: (){
                                          Get.back();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Save',
                                          style: TypographyStyles.boldText(14, Themes.mainThemeColor.shade500),
                                        ),
                                        onPressed: () async{

                                          ready.value = false;
                                          Map res = await httpClient.updateClientSubProfile({
                                            'emergency_contact_name': nameController.text,
                                            'emergency_contact_phone': phoneController.text,
                                          });
                                          print(phoneController.text);

                                          if (res['code'] == 200) {
                                            print(res);
                                            Get.back();
                                            getProfile();
                                          } else {
                                            ready.value = true;
                                            showSnack('Something went wrong!', 'please try again',status: PopupNotificationStatus.error);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                          );
                          },label: "Edit emergency contact")
                      ],
                    ),
                  ),
                ],
              ): Center(child: CircularProgressIndicator(),)),
            ],
          ),
        ),
      ),
    );
  }
}
